require_relative 'display_text'
require_relative 'display_background'
require_relative 'display_blockquote'
require_relative 'display_button'
require_relative 'display_code_block'
require_relative 'display_heading'
require_relative 'display_image'
require_relative 'display_paragraph'
require_relative 'display_rule'
require_relative 'display_callout'

$gtk.reset

module Forked
  # Display class
  class Display
    attr_gtk

    def initialize(theme = nil)
      # set the current theme if passed
      @theme = theme
    end

    def tick
      defaults unless data.defaults_set
      input
      render
    end

    # stores object data in state
    def data
      args.state.forked.display ||= args.state.new_entity('forked display')
    end

    def defaults
      data.style = config_defaults # display defaults
      data.options = []             # current options (buttons) in chunk
      apply_theme(@theme)           # set the current theme

      # get input defaults (from input.rb)
      data.keyboard_input_defaults = Forked.keyboard_input_defaults
      data.controller_input_defaults = Forked.controller_input_defaults

      data.selected_option = -1 # set the current selection to no selection
      data.mouse_cursor = :arrow # set the default cursor

      data.defaults_set = true # and don't come back
    end

    ########
    # THEMES
    ########

    def apply_theme(theme)
      # "==== apply_theme(#{theme})"
      theme ||= {}

      data.style = config_defaults

      theme = theme.theme if theme.is_a?(Module)

      theme.each do |k, v|
        if data.style[k]
          data.style[k].merge!(v)
        else
          data.style[k] = v
        end
      end

      # TODO: this line might not be needed (seems like it's there
      # to ensure the current selection is highlighted after navigation)
      highlight_selected_option
    end

    #######################
    # PLAYER INPUT HANDLING
    #######################

    ### GET INPUT

    def input
      update_selection
      return if data.options.nil? || data.options.empty?

      if check_keyboard_activation_end ||
         check_controller_activation_end ||
         check_mouse_activation_end

        activate_selected_option
      end
    end

    ### UPDATE SELECTION

    def update_selection(navigated = nil)
      return if data.options.nil? || data.options.empty?

      # check whether input is selecting a button
      select = check_button_selected

      # did we come here from a navigation command?
      # deselect the buttons (the selection is not valid)
      # and return the cursor to arrow
      # otherwise, maintain the same selection (we just executed some code)
      if navigated
        data.selected_option = -1
        next_cursor = :arrow
      end

      # check whether input is activating a button
      activating = true if data.selected_option != -1 && check_activation_start

      # check whether input is deactivating a button
      deactivating = data.selected_option != -1 && check_activation_end

      # button is deactivating? (e.g. key/controller/mouse released)
      # revert to selection highlighting

      highlight_selected_option if deactivating && data.selected_option >= 0

      # check whether input is deactivating a button
      # clicked = true if data.selected_option != -1 && check_activation_end

      if select
        unhighlight_selected_option if data.selected_option >= 0
        data.selected_option = select
        highlight_selected_option if data.selected_option >= 0
        if inputs.last_active == :mouse
          next_cursor = if data.selected_option >= 0
                          # try to change to the hand cursor
                          :hand
                        else
                          # try to change to the arrow cursor
                          :arrow
                        end
        end
      end

      # player clicked the button
      highlight_active_option if activating

      highlight_active_option if select != -1 && check_activation

      # set the cursor when it has changed
      if next_cursor && next_cursor != data.mouse_cursor
        gtk.set_system_cursor(next_cursor)
        data.mouse_cursor = next_cursor
      end
    end

    ### CHECKS

    def check_button_selected
      case inputs.last_active
      when :keyboard
        get_keyboard_selection
      when :controller
        get_controller_selection
      when :mouse
        get_mouse_selection
      end
    end

    def check_activation_start
      case inputs.last_active
      when :keyboard
        check_keyboard_activation_start
      when :controller
        check_controller_activation_start
      when :mouse
        check_mouse_activation_start
      end
    end

    def check_activation
      case inputs.last_active
      when :keyboard
        check_keyboard_activation
      when :controller
        check_controller_activation
      when :mouse
        check_mouse_activation
      end
    end

    def check_activation_end
      case inputs.last_active
      when :keyboard
        check_keyboard_activation_end
      when :controller
        check_controller_activation_end
      when :mouse
        check_mouse_activation_end
      end
    end

    def check_keyboard_activation_start
      kd = inputs.keyboard.key_down
      data.keyboard_input_defaults[:activate].any? { |k| kd.send(k) }
    end

    def check_keyboard_activation
      kh = inputs.keyboard.key_held
      data.keyboard_input_defaults[:activate].any? { |k| kh.send(k) }
    end

    def check_keyboard_activation_end
      ku = inputs.keyboard.key_up
      data.keyboard_input_defaults[:activate].any? { |k| ku.send(k) }
    end

    def check_controller_activation_start
      c1 = inputs.controller_one
      data.controller_input_defaults[:activate].any? { |k| c1.key_down.send(k) } if c1.connected
    end

    def check_controller_activation
      c1 = inputs.controller_one
      data.controller_input_defaults[:activate].any? { |k| c1.key_held.send(k) } if c1.connected
    end

    def check_controller_activation_end
      c1 = inputs.controller_one

      data.controller_input_defaults[:activate].any? { |k| c1.key_up.send(k) } if c1.connected
    end

    def check_mouse_activation_start
      inputs.mouse.down
    end

    def check_mouse_activation
      inputs.mouse.held
    end

    def check_mouse_activation_end
      inputs.mouse.up
    end

    ### GET PLAYER SELECTION

    def get_mouse_selection
      rollover = -1
      data.options.each_with_index do |option, idx|
        next if option.action.empty?

        if option.intersect_rect?(inputs.mouse.point)
          rollover = idx
          break
        end
      end

      rollover if rollover != data.selected_option
    end

    def get_keyboard_selection
      kd = inputs.keyboard.key_down

      if data.keyboard_input_defaults[:next].any? { |k| kd.send(k) }
        return relative_to_absolute_selection(1)
      elsif data.keyboard_input_defaults[:prev].any? { |k| kd.send(k) }
        return relative_to_absolute_selection(-1)
      end

      nil
    end

    def get_controller_selection
      c1 = inputs.controller_one

      if c1.connected
        if data.controller_input_defaults[:next].any? { |k| c1.key_down.send(k) }
          return relative_to_absolute_selection(1)
        elsif data.controller_input_defaults[:prev].any? { |k| c1.key_down.send(k) }
          return relative_to_absolute_selection(-1)
        end
      end

      nil
    end

    ### DISPLAY SELECTION CHANGES

    def highlight_selected_option
      return unless data.options && data.selected_option && data.selected_option >= 0

      opt = data.options[data.selected_option]
      return unless opt

      opt.force_status_change(:focused)
    end

    def unhighlight_selected_option
      return unless data.selected_option >= 0

      return if data.selected_option >= data.options.count

      data.options[data.selected_option].force_status_change(:enabled)
    end

    def highlight_active_option
      return unless data.options && data.selected_option && data.selected_option >= 0

      opt = data.options[data.selected_option]
      return unless opt

      opt.force_status_change(:active)
    end

    ### PERFORM OPTION

    def activate_selected_option
      return unless data.selected_option >= 0

      $story.follow(args, data.options[data.selected_option])
    end

    ### HELPER

    def relative_to_absolute_selection(index)
      sel_opt = data.selected_option
      if data.selected_option.negative? || data.selected_option.nil?
        sel_opt = index.positive? ? data.options.size - 1 : 0
      end
      sel_opt += index
      sel_opt.clamp_wrap(0, data.options.size - 1)
    end

    ################
    # UPDATE DISPLAY
    ################

    def update(content, navigated)
      update_selection(navigated)

      data.primitives = []
      data.options = []

      y_pos = data.style.display.margin_top.from_top
      next_y_pos = y_pos

      content.each_with_index do |item, i|
        previous_element_type = content[i - 1][:type]
        @last_element_type = content[i - 1][:type]
        @last_printed_element_type ||= :none

        case item[:type]
        when :heading
          next_y_pos = display_heading(y_pos, item, previous_element_type)
        when :rule
          next_y_pos = display_rule(y_pos, item, previous_element_type)
        when :paragraph
          next_y_pos = display_paragraph(y_pos, item)
        when :code_block
          next_y_pos = display_code_block(y_pos, item, previous_element_type)
        when :blockquote
          # next_y_pos = display_blockquote(y_pos, item, previous_element_type, content, i)
          next_y_pos = display_blockquote(y_pos, item)
        when :button
          next_y_pos = display_button(y_pos, item, content, i)
          highlight_selected_option
        when :image
          next_y_pos = display_image(y_pos, item)
        when :blank
          # nothing
        when :hidden
          # nothing
        when :callout
          next_y_pos = display_callout(y_pos, item)
        end

        if !(next_y_pos - y_pos).zero? ||
           item[:type] == :blank
          @last_printed_element_type = item[:type]
        end
        y_pos = next_y_pos
      end
    end

    ###############
    # TEXT HANDLING
    ###############

    def wrap_lines_code_block(str, font, size_px, width)
      wrapped_text = []
      str.lines.map do |l|
        l += ' ' # <== It's a hack :)
        fixed_width_line = ''
        frag = ''
        sp = 0 # index of first space
        while sp
          sp = l.index(' ')
          if sp
            if sp.zero?
              # space is the first character?
              # check width of line so far (fixed_width_line + frag)
              test_w = args.gtk.calcstringbox(fixed_width_line + frag, size_px, font)[0]
              # we're still inside the boundary?
              if test_w < width
                # add the current fragment to the line
                fixed_width_line += frag
                # add the current character (a space) to the line
                frag = ' '
              else # the next frag will push us over the line so soft wrap
                wrapped_text << fixed_width_line

                # empty the line and add the non-fitting frag to it
                fixed_width_line = frag.delete_prefix!(' ')
                # empty the frag but add a space
                frag = ' '
              end

              # empty frag and add a space

              # All hell will break loose if this line is removed
              # removes the found space, whether or not if goes in the
              # current soft line
              l.delete_prefix!(' ')

            else # space is not the first character. Add the previous word to frag
              ret = l.slice!(0, sp)
              frag += ret
            end
          else # there are no more spaces left in this line
            # add the remnant to frag
            frag += l
            # at the end of the line so add it to fwl
            fixed_width_line += frag
            # and add that to the wrapped text array
            wrapped_text << fixed_width_line
          end
        end
      end

      wrapped_text
    end

    def wrap_lines_code_block_slow(str, font, size_px, width)
      wrapped_text = []
      str.lines.map do |l|
        fixed_width_line = ''

        c = 0
        frag = ''
        while c < l.length

          if l.chars[c] == ' '
            # check w of frag + fixed_width_line
            test_w = args.gtk.calcstringbox(fixed_width_line + frag, size_px, font)[0]
            # if it fits display w

            if test_w < width
              # add frag to line
              fixed_width_line += frag
              # empty frag and add the matched space
              frag = ' '
            else # the line is too long to add the frag
              # add the line to the wrapped text array

              wrapped_text << fixed_width_line
              # empty the line and add the non-fitting frag to it
              fixed_width_line = frag
              # empty the frag
              frag = ' '
            end
          else # any character that is not a space
            # add char to frag
            frag += l.chars[c]
          end

          # we got to the end of the line
          if c == l.length - 1
            fixed_width_line += frag
            wrapped_text << fixed_width_line
          end
          c += 1
        end
      end

      # TODO: Small wrinkle with this code: a word can happily sit at the end of a line
      # but when another word is added after, the word will shift to the next line.
      # This might be due to the word having a space added to the width calculation?
      wrapped_text
    end

    def wrap_lines(str, font, size_px, width)
      wrapped_text = []
      str.lines.map do |l|
        fixed_width_line = ''

        words = l.strip.split(" ")

        until words.empty?
          line_next = fixed_width_line + words[0]
          if args.gtk.calcstringbox(line_next, size_px, font)[0] < width
            fixed_width_line = line_next + ' '
            words.shift
          else
            wrapped_text << fixed_width_line
            fixed_width_line = ''
          end

          wrapped_text << fixed_width_line if words.empty?
        end
      end

      wrapped_text
    end

    ## split string (str) on space
    ## preserve a maximum of one consecutive space
    def split_preserve_one_space(str)
      arr = []
      while str.length > 0
        if (idx = str.index(' '))
          capture = str[0...idx + 1]
          # prevent runs of spaces
          arr << capture unless capture == ' ' && arr[-1]&.end_with?(" ")
          str = str [idx + 1..-1]
        else
          # the string does not or no longer contains a space
          arr << str
          str = ''
        end
      end
      arr
    end

    ## split string (str) on space
    ## preserve spaces
    def split_preserve_space(str)
      arr = []
      while str.length > 0
        idx = str.index(' ')
        if idx
          cap = str[0...idx + 1]
          arr << cap
          str = str [idx + 1..-1]
        else
          arr << str
          str = ''
        end
      end
      arr
    end

    def size_enum_to_size_px(size_enum)
      size_enum * 2 + 22
    end

    # converts label size_px to size_enum
    # rounds down (so size_px 22 and 23 are bothe size_enum 0)
    def size_px_to_size_enum(size_px)
      (size_px - 22).div(2)
    end

    ########
    # RENDER
    ########

    def render
      background = data.style.background
      if background.path
        outputs.sprites << {
          **background.sprite!
        }
      elsif background.background_color
        outputs.background_color = background.background_color
      end

      args.outputs.primitives << data.primitives
    end
  end
end
