module Forked

  # manages the story data
  class Story
    attr_gtk
    attr_accessor :display

    def initialize sf
      @story_file = sf
      @theme = THEME
    end

    def data
      state.forked ||= state.new_entity('forked')
    end

    def tick
      state.forked.dynamic.tick_count ||= -1
      state.forked.dynamic.tick_count += 1
      defaults unless state.forked.defaults_set
      # navigated is passed to display to determine whether to reset
      # the keyboard selection during an update
      # set to false every tick and set to true if navigation happens later
      state.forked.navigated = false

      # process player input (mouse, keyboard, controller)
      check_input

      # create and feed the display object
      @display ||= Display.new(@theme)
      @display.args = args
      @display.tick

      check_and_handle_orientation_change

      # make the display hash and send it to the display object
      present args

      # create the Author object. Author mode provides tools for the developer.
      @author ||= Author.new(self)
      @author.args = args
      @author.tick
    end

    def defaults
      # state.forked.defaults = forked_defaults
      state.forked.defaults = Forked.forked_defaults
      @refresh = true
      @hashed_display = 0
      args.state.forked.dynamic.forked_counter = {}

      @story_file = get_story_from_argv || @story_file
      load_story(@story_file)

      state.forked.defaults_set = true
    end

    def load_story(story_file)
      if story_file.end_with?('.json')
        state.forked.story = Forked.import_story_from_json(story_file)
      else
        story_text = fetch_story(args, story_file)
        state.forked.story = Parser.parse(story_text)
      end

      state.forked.root_chunk = state.forked.story[:chunks][0]
      state.forked.title = state.forked.story[:title]
      state.forked.story_id = state.forked.title.hash

      # $gtk.set_window_title is (re)added in DR 5.20
      major, minor = $gtk.version.split(".").map { _1.to_i }
      $gtk.set_window_title(state.forked.title) if ((major >= 5 && minor >= 20) || major > 5)

      # allow story to run one-time setup code that needs to be
      # setup regardless of where we start the story after a reload
      if state.forked.story.actions
        evaluate args, state.forked.story.actions.join
      end

      follow args

      load_dynamic_state
      state.forked.dynamic.forked_history ||= [] 
      if state.forked.dynamic&.forked_history.count > 0
        navigate state.forked.dynamic.forked_history[-1]
      else
        navigate(0)
      end
    end

    def get_story_from_argv
      split = $gtk.argv.split(' --')
      split.each do |p|
        if p.start_with? "story "
          file = p.split(' ')[1]
          puts "Forked: Loading story file #{file} from command line argument"
          return file
        elsif p.start_with? "ftest "
          file = '/lib/forked/forked-tests/' + p.split(' ')[1]
          puts "Forked: Loading test file #{file} from command line argument"
          return file
        end
      end
      nil
    end

    def restart_story
      clear_dynamic_data
      clear_save_data
      load_story(@story_file)
    end

    ##################
    # INPUT PROCESSING
    ##################

    ## input for Forked
    def check_input
      # toggle author mode
      if  inputs.keyboard.key_held.f &&
          inputs.keyboard.key_down.u
        state.forked.author_mode = !state.forked.author_mode
        puts "Forked Author Mode is " + (state.forked.author_mode ? "on. Hold Q to display the sidebar." : "off")
      end
    end

    ############
    # NAVIGATION
    ############

    ### Navigation

    def get_current_chunk_idx
      state.forked.story.chunks.find_index { |c| c == state.forked.current_chunk }
    end

    def find_chunk_index_from_id(chunk_id)
      # find chunk by ID when it exists
      ind = state.forked.story.chunks.index { |i| i[:id] == chunk_id }
      return ind if ind
      
      # when ID does not exist, remove # and find slug if it exists
      ci = chunk_id.delete_prefix('#')
      ind = state.forked.story.chunks.index { |i| i[:slug] == ci }
      return ind if ind

      #  ID does not exist and slug does not exist, make some noise
      raise "FORKED: Broken link. Unable to find the chunk `#{chunk_id}`"
    end

    # accepts chunk ID, finds the chunk index and calls navigate()
    def navigate_id(chunk_id)
      idx = find_chunk_index_from_id(chunk_id)
      if idx.nil?
        raise "FORKED: TARGET NOT FOUND.\n"\
        "Cannot navigate to the specified chunk.\n"\
        "Attempted to navigate to: #{chunk_id}"
      end 
      navigate(idx)
    end

    # accepts an int relative to the current chunk index and calls navigate()
    def navigate_relative(relative_idx)
      next_index = (get_current_chunk_idx + relative_idx).clamp(0, state.forked.story.chunks.size - 1)
      navigate(next_index)
    end

    # navigates to the chunk with the provided index number
    def navigate(idx)
      if idx.nil?
        raise "FORKED: TARGET NOT FOUND. "\
        "Cannot navigate to the specified chunk."
      end 

      target = state.forked.story.chunks[idx]

      # return when the next chunk is the same as the current chunk

      # WEIRD CODE WARNING
      # slug may not exist in state
      # attempting to access the value of slug for comparison using [:slug]
      # results in a massive warning message from DragonRuby
      # Use dot access and DragonRuby won't complain
      return if state.forked.current_chunk.slug == target[:slug]

      if target.nil?
        raise "FORKED: TARGET NOT FOUND. "\
        "Cannot navigate to the specified chunk."
      end

      history_add(idx)

      # set the current chunk
      state.forked.current_chunk = target
      # update the current heading
      @heading = state.forked.current_chunk[:content][0][:text]
      state.forked.current_heading = @heading || '' 
      # set the current content
      state.forked.current_lines = state.forked.current_chunk[:content]
      # clear the options array
      state.forked.options = []

      state.forked.navigated = true
      process_new_chunk
    end

    # Jump to a specified label
    def jump param = nil
      if param.is_a?(Integer)
        navigate_relative(param)
      elsif param.is_a?(String)
        # TODO: Check that label exists
        navigate_id(param)
      elsif param.is_a?(NilClass)
        raise "`jump` must be given a parameter."
      end
    end

    # jump to a label by it's indexed position in the story file
    # jump_to(1) goes to the first label
    # jump_to(-1) goes to the last label
    def jump_to(idx)
      navigate(idx)
    end

    # includes a specified chunk in the current chunk (appends)
    def include_chunk(id)
      idx = find_chunk_index_from_id(id)
      included = data.story.chunks[idx].content
      data.current_lines += included[1..]
    end

    ####################
    # NAVIGATION HISTORY
    ####################

    def history_get
      state.forked.dynamic.forked_history ||= [] 
      state.forked.dynamic.forked_history.map do |h|
        [
          h,
          state.forked.story.chunks[h][:id],
          state.forked.story.chunks[h][:content].find {|c| c.type == :heading }.text
        ]
      end
    end

    def history_add(target)
      state.forked.dynamic.forked_history ||= [] 
      state.forked.dynamic.forked_history << target
    end

    def history(idx = nil)
      history = state.forked.dynamic.forked_history
      return history unless idx

      history[idx]
    end

    def history_clear
      state.forked.dynamic.forked_history = []
    end

    ###################
    # CORE PROCESSING 
    # - LOAD STORY
    # - PROCESS ACTIONS
    # - PROCESS CHUNK
    # - PREPARE FOR PRESENTATION
    ###################

    def process_action(args, action)
      if action.is_a?(String)
        if action == '#'
          navigate_relative(1)
        elsif action.start_with?('#')
          navigate_id(action)
        else
          eval_action = action.delete_prefix('@@@@')
          evaluate(args, eval_action.to_s)
        end
      else
        raise "Forked: Unexpected action value. Expecting String or Integer. #{action.to_s}"
      end

      save_dynamic_state if state.forked.defaults[:autosave]
    end

    def process_new_chunk
      unless state.forked.current_chunk.actions.empty?
        state.forked.current_chunk.actions.each do |a|
          
          evaluate args, a
        end
      end
      if state.forked.current_lines.nil?
        raise "FORKED Display: The story chunk does not exist.
Check that the chunk_id you are linking to exists and is typed correctly.
Tell Akz to write a better error message."
      end
      if state.forked.current_lines.empty?
        raise "No lines were found in the current story chunk. Current chunk is #{state.current_chunk}"
      end
    end

    def follow(args, option = nil)
      if option&.action
        process_action(args, option.action) 
      end
    end

    ### DEPRECATED
    def fall
      puts "`fall` is deprecated. Please use `jump(1)` instead."
      navigate_relative(1)
    end

    ### DEPRECATED
    def rise
      puts "`rise` is deprecated. Please use `jump(-1)` instead."
      navigate_relative(-1)
    end

    def present(args)
      display_lines = state.forked.current_lines.copy
      display_lines.each do |element|
        # deal first with content that contains atoms
        if element[:atoms]
          element[:atoms].each_with_index do |atom, j|
            next unless (atom[:condition] &&
                        atom[:condition].is_a?(String) &&
                        !atom[:condition].empty?)
            result = evaluate(args, atom[:condition])
            # when it's a non-empty string, display the result
            if result.is_a?(String) && !result.empty?
              # String Interpolation
              
              # string interpolation may include newlines
              # zap them and add a space to ensure separation between words
              if result.include?("\n")
                result.gsub!("\n", " ")
              end

              ### CONTROVERSIAL
              # Add space after the result
              result += ' '
              element[:atoms][j][:text] = "#{result}"
            elsif [true, false].include? result
              display_segment = false
              if atom[:condition_segment].to_i == 0 && result == true
                display_segment = true
              elsif atom[:condition_segment].to_i == 1 && result == false
                display_segment = true
              end

              element[:atoms][j][:text] = '' if display_segment != true
            else
              # don't display
              element[:atoms][j][:text] = '' #j > 0 ? ' ' : ''
            end
          end
        else
          # the element does not contain atoms
          next unless element && element[:condition]

          result = evaluate(args, element[:condition])

          if [true, false].include? result
              display_element = false
              if element[:condition_segment].to_i == 0 && result == true
                display_element = true
              elsif element[:condition_segment].to_i == 1 && result == false
                display_element = true
              end

              element[:type] = :hidden if display_element != true
            else
              # don't display
              element[:type] = :hidden
            end
        end
      end

      new_hash = display_lines.hash
      if @hashed_display == new_hash && !@refresh
        return
      else 
        $second_hash ||= @hashed_display unless $first_hash.nil?
        $first_hash ||= @hashed_display
        @display.update(display_lines, state.forked.navigated)
        @hashed_display = new_hash
        @refresh = false
      end
    end

    def fetch_story args, story_file
      # story_text = gtk.read_file STORY_FILE
      story_text = gtk.read_file(story_file)

      if story_text.nil?
        raise "The file #{story_file} failed to load. Please check the filename and path."
      end

      story_text
    end

    #####################
    # RUBY EXECUTION
    #####################

    def evaluate(args, command)
      # don't evalulate empty commands
      return if command.strip == ("\"\"")

      # puts "Evaluating: #{command}"
      begin
        result = eval(command)
      rescue Exception => e
        line_no = e.to_s.split[1].chop.to_i

        log " "
        log "FORKED: Error in story file. #{e}"
        log "Cannot execute Ruby code:"
        command.each_line.with_index do |l, i|
          str = ""
          if line_no == i + 1
            str += "> "
          else
            str += "  "
          end
          log "#{str}Line #{i + 1}: #{l}"
        end
        log "Original error message follows."
        log " "
        raise e
      end
    end

    #################
    # Commands
    #################

    ### Theme

    def change_theme theme
      if @display
        @display.apply_theme(theme)
        @refresh = true
      else
        @theme = theme
      end
    end

    def check_and_handle_orientation_change
      if @orientation != $gtk.orientation
        @orientation = $gtk.orientation
        @display.apply_theme(@theme)
        @refresh = true
      end
    end

    ### Chunk content

    def heading
      state.forked.current_chunk[:content][0][:text]
    end

    def heading_set new_heading
      state.forked.current_chunk[:content][0][:text] = new_heading
    end

    ### BAG (player inventory)

    # adds an item to the player inventory
    def bag_add item
      bag << item unless bag_has? item
    end

    # removes an item from the player inventory
    def bag_remove item
      bag.delete item
    end

    # returns true if the player inventory includes item
    def bag_has? item
      bag.include? item
    end

    # the player inventory
    def bag
      state.forked.dynamic.forked_bag ||= []
    end

    # empties the player inventory
    def bag_clear
      state.forked.dynamic.forked_bag = []
    end

    def bag_sentence
      return "nothing" unless state.forked.dynamic.forked_bag

      return "nothing" if state.forked.dynamic.forked_bag.empty?

      state.forked.dynamic.forked_bag.join(', ') + "."
    end

    ### Background
    # Sets the background image to a 1280x720 png file (run from a condition)
    def background_image(path)
      outputs.sprites << {
        x: 0,
        y: 0,
        w: grid.w,
        h: grid.h,
        path: path
      }
    end

    ### Counters

    def counter
      state.forked.dynamic.forked_counter ||= {}
    end

    def counter_up name, value = 1
      state.forked.dynamic.forked_counter[name] += value
    end

    def counter_down name, value = 1
      state.forked.dynamic.forked_counter[name] -= value
    end

    def counter_add name, value = 0
      state.forked.dynamic.forked_counter[name] = value
    end

    def counter_remove name
      state.forked.dynamic.forked_counter.delete(name)
    end

    def counter_check name
      state.forked.dynamic.forked_counter[name]
    end

    def counter_text name
      state.forked.dynamic.forked_counter[name].to_s
    end

    def counter_clear
      state.forked.dynamic.forked_counter = {}
    end

    ### Memos
    # stores information that can be checked later
    def memo
      state.forked.dynamic.forked_memo ||= {}
    end

    # adds a memo
    def memo_add name, value
      memo[name] = value
    end

    # deletes a memo
    def memo_remove name
      memo.delete(name)
    end

    # clears all memos
    def memo_clear
      state.forked.dynamic.forked_memo = {}
    end

    # returns true if a memo exists
    def memo_exists? name
      memo.has_key?(name)
    end

    # returns the value of a memo
    def memo_check name
      return unless memo_exists?(name)

      memo[name]
    end

    ### Wallet
    # Keeps track of the player's finances (gold coins, dollars, anything you like)
    def wallet
      state.forked.dynamic.forked_wallet ||= 0
    end

    def wallet_text(prefix = '', suffix = '')
      "#{prefix}#{state.forked.dynamic.forked_wallet}#{suffix}"
    end

    # adds money to the wallet
    def wallet_plus num
      state.forked.dynamic.forked_wallet += num
    end

    # removes money from the wallet
    def wallet_minus num
      state.forked.dynamic.forked_wallet -= num
    end

    # removes all money from the wallet
    def wallet_clear
      state.forked.dynamic.forked_wallet = 0
    end

    ### Timers
    # lets you create timers
    def timer
      state.forked.dynamic.forked_timer ||= {}
    end

    def timer_exist? name
      timer.keys.include? name
    end

    # creates a new, named timer with the provided duration
    def timer_add name, duration
      timer[name] = {
        start_time: state.forked.dynamic.tick_count,
        duration: duration
      }
    end

    # removes a named timer
    def timer_remove name
      timer.delete(name)
    end

    # checks how much time is left for a timer (will be negative when duration is up)
    def timer_check name
      return unless timer_exist?(name)
      timer[name][:duration] - ($args.tick_count - timer[name][:start_time])
    end

    # returns true if the named timer is complete
    def timer_done? name
      return unless timer_exist?(name)
      timer_check(name) <= 0
    end

    # returns timer value as seconds, minimum 0
    def timer_seconds(name)
      return unless timer_exist?(name)

      ticks = timer_check(name)
      (ticks / 60).ceil.greater(0)
    end

    ### Dice Roll
    def roll dice
      result = 0
      num_dice, num_sides = dice.split('d', 2)
      num_dice.to_i.times { result += rand(num_sides.to_i) + 1 }
      result
    end

    ##############
    # DATA STORAGE
    ##############
    
    def clear_dynamic_data
      state.forked.dynamic = state.new_entity('dynamic')
    end


    ##########
    # SAVE
    ##########

    def autosave_off
      state.forked.defaults.autosave = false
    end

    def autosave_on
      state.forked.defaults.autosave = true
    end

    def save_game
      save_dynamic_state
    end

    def clear_save_data
      clear_saved_dynamic_state
    end

    def save_dynamic_state
      $gtk.serialize_state(save_path_get(:dynamic), state.forked.dynamic)
    end

    def clear_saved_dynamic_state
      $gtk.delete_file_if_exist(save_path_get(:dynamic))
    end

    def load_dynamic_state
      parsed_state = gtk.deserialize_state(save_path_get(:dynamic))
      if parsed_state
        state.forked.dynamic = parsed_state
      else
        history_clear
      end
    end

    def save_path_get(save_type)
      devmode = gtk.production ? '' : '-dev'
      "data/#{save_type.to_s}-#{state.forked.story_id}#{devmode}.txt"
    end

    ################
    # FORKED TESTING
    ################

    def forked_test(expect: nil, print_subject: false)
      test_mark = []
      outputs.primitives.each_with_index do |prim, i|
        if prim&.text && prim&.text&.strip == "<! start test !>"
          test_mark << i + 1
        elsif prim&.text && prim&.text&.strip == "<! end test !>"
          test_mark << i - 1
        end
      end
      return "Test does not contain two marks" if test_mark.count < 2

      subject = outputs.primitives[test_mark[0]..test_mark[1]]
      subject_hash = subject.to_s.hash

      if expect != subject_hash 
        puts "Subject:\n#{subject_hash}"
        putz ["Subject:\n#{subject}"] if print_subject
        return "Test failed"
      end

      "Test passed"
    end
  end
end

$gtk.reset