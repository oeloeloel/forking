module Forked
  # parses the story file
  class Parser
    DEFAULT_TITLE = 'A Forked Story'.freeze

    class << self
      def parse(story_file)
        raise 'FORKED: The story file is missing.' if story_file.nil?
        raise 'FORKED: The story file is empty.' if story_file.empty?

        # used when parsing inline styles
        @style_marks = make_style_marks

        # Empty story
        story = make_story_hash

        context = [:title] # we're looking for a title and nothing else right now
        style_context = [] # tracking inline styles

        # Elements understood by the parser:
        # [x] :blockquote (physical div)
        # [x] :condition block (logical div)
        # [x] :action_block (multiline code)
        # [x] :code_block (present code style, multiline)
        # [x] :trigger text (button display text)
        # [x] :trigger action (button action)
        # [x] :title (story title)
        # [x] :heading text (chunk heading)
        # [x] :chunk_id (chunk identifier)
        # [x] :paragraph (plain text)
        # [x] preformatted line (do not parse line and present as text)
        # [x] c-style line comments (stripped and ignored)
        # [x] html-style comments (stripped and ignored)
        # [x] :rule (horizontal rule)
        # [x] :action (single line code)
        # [x] :code (present with code format < 1 line)
        # [x] :bold (inline strong style)
        # [x] :italic (inline emphasis style)
        # [x] :bold italic (inline strong + emphasis style)
        # :inline trigger
        # [ ] :image

        story_lines = story_file.lines
        line_no = -1

        while(line = story_lines.shift)
          line_no += 1
          # puts "#{line_no + 1}: #{line.strip}"

          ### PREFORMATTED LINE (^@@) and stop parsing it
          result = parse_preformatted_line(line, context, story, line_no)
          next if result

          ### STRIP C COMMENT (//) and continue parsing line
          result = parse_c_comment(line, context)
          line = result if result

          ### HTML COMMENTS (<!-- -->)
          result = parse_html_comment(line, context, line_no)
          next unless result

          line = result

          ### TITLE
          result = parse_title(line, context, story, line_no)
          next if result

          # Forked wants the first non-blank, non comment line of
          # the story file to be the title. The exception was
          # removed here to allow for different behaviour here
          # (possible secret title page behaviour)

          ### BLOCKQUOTE
          result = parse_blockquote(line, context, story, line_no)
          next if result

          ### HEADING LINE
          result = parse_heading(line, context, story, line_no)
          next if result

          ### RULE
          result = parse_rule(line, context, story, line_no)
          next if result

          ### CODE FENCE
          result = parse_code_fence(line, context, story, line_no)
          next if result

          ### TRIGGER
          # currently works for newstyle colon and old-style backtick trigger actions
          result = parse_trigger(line, context, story, line_no)
          next if result

          ### IMAGE
          result = parse_image(line, context, story, line_no)
          next if result

          ### CONDITION BLOCK
          result = parse_condition_block(line, context, story, line_no, story_lines)
          if result == :interpolation
            line = '@#$%INTERPOLATION@#$%'
          elsif result
            next
          end

          ### CODE BLOCK
          result = parse_code_block(line, context, story, line_no)
          next if result

          ### ACTION BLOCK
          result = parse_action_block(line, context, story, line_no)
          next if result

          # PARAGRAPH
          parse_paragraph(line, context, story, line_no)

          # MEANINGFUL BLANK LINE
          result = parse_blank(line, context, story, line_no)
          next if result
        end # while

        story
      end

      # check to see whether it is safe to proceed based on
      # context rules
      def context_safe?(context, prohibited, mandatory)
        context_prohibited = array_intersect?(context, prohibited)
        context_mandatory = mandatory.empty? ||  array_intersect?(context, mandatory)

        context_mandatory && !context_prohibited
      end

      # true when arr1 and arr2 contain any overlapping elements
      def array_intersect?(arr1, arr2)
        arr1.intersection(arr2).any?
      end

      # draws a horizontal line
      def parse_rule(line, context, story, line_no)
        return unless line.strip.start_with?('---')

        prohibited_contexts = [:title, :code_block]
        mandatory_contexts = []
        return unless context_safe?(context, prohibited_contexts, mandatory_contexts)

        story[:chunks][-1][:content] << make_rule_hash

        # this content is conditional? add the condition to the current element
        if context.include?(:condition_block)  || context.include?(:condition_block)
          condition = story[:chunks][-1][:conditions][-1]
          story[:chunks][-1][:content][-1][:condition] = condition
        end

        true
      end

      # when a line is totally blank, add it as a `:blank` element
      # only add one :blank - runs of blanks are not meaningful
      # display will ignore the blank
      # display will not treat two of the same block level
      # elements as contiguous if they are separated by a blank
      def parse_blank(line, context, story, line_no)
        # apply to blank lines and NO CONTEXT IS OPEN
        return if !line.strip.empty? ||
                  !context.empty?
        
        # check last element type
        prev_type = story&.[](:chunks)[-1][:content]&.[](-1)[:type]

        # blank is meaningful after last element? add it
        # for now, blank is only meaningful after button
        story[:chunks][-1][:content] << make_blank_hash if prev_type == :button
      end

      # Force a line to display as plain, unformatted text, ignoring any further markup
      # Used for troubleshooting, not part of the specification
      def parse_preformatted_line(line, context, story, _line_no)
        return unless line.strip.start_with?('@@')

        prohibited_contexts = [:title, :code_block]
        mandatory_contexts = []
        return unless context_safe?(context, prohibited_contexts, mandatory_contexts)

        line.delete_prefix!('@@')
        para = make_paragraph_hash
        atm = make_atom_hash
        atm[:text] = line.chomp
        para[:atoms] << atm
        story[:chunks][-1][:content] << para

        true
      end

      def parse_paragraph(line, context, story, line_no) 

        # check credentials
        prohibited_contexts = [:title, :codeblock, :heading]
        mandatory_contexts = []
        return unless context_safe?(context, prohibited_contexts, mandatory_contexts)
        
        conditional = false

        # strip
        line.strip!

        # anything that comes here is either a paragraph or a blank line.
        # handle context open/opening/closing
        context_state = handle_paragraph_context(line, context)
        # if the line ends with `\`, hard wrap
        if line.strip[-1] == '\\'
          # terminate the line with a newline
          # add an nbsp to prevent empty lines from collapsing
          line = line.delete_suffix('\\') + " \n"
        end

        # new paragraph condition:
        # context was closed, now open
        if context_state == :opening
          story[:chunks][-1][:content] << make_paragraph_hash
          context_state = :open
        end

        return if line.strip.empty?

        # new atom condition
        # context is open
        if context_state == :open
          # if text is a placeholder for interpolation, blank it

          atoms = []
          if line == '@#$%INTERPOLATION@#$%'
            conditional = true
            line = ''
            atoms << make_atom_hash()
          end

          ######
          # APPLY INLINE STYLES HERE
          ######

          
          while !line.empty?
            first_idx1 = 10000000
            first_idx2 = first_idx1
            first_mark = {}
            
            @style_marks.each do |m|
              next unless idx1 = line.index(m.mark)
              next unless idx1 < first_idx1
              next unless idx2 = line.index(m.mark, idx1 + 1)

              first_idx1 = idx1
              first_idx2 = idx2
              first_mark = m
            end

            if first_mark.empty?
              atoms << make_atom_hash(line)
              line = ''
            else
              left_text = line[0...first_idx1]
              marked_text = line[first_idx1 + first_mark[:mark].length...first_idx2]

              line = line[first_idx2 + first_mark[:mark].length..-1]

              atoms << make_atom_hash(left_text) unless left_text.empty?
              atoms << make_atom_hash(marked_text, [first_mark[:symbol]])
            end
          end

          ######
          # INLINE STYLES DONE
          ######
          
          # if prev item is not a paragraph, make a new paragraph
          prev_item = story[:chunks][-1][:content][-1]
          unless prev_item[:type] == :paragraph
            story[:chunks][-1][:content] << make_paragraph_hash
          end
          # add a space to the last new atom
          atoms[-1].text += ' ' unless atoms.empty? || atoms[-1].text.end_with?("\n")
          story[:chunks][-1][:content][-1][:atoms] += atoms
        end
        
        # apply conditions to paragraph atoms
        if context.include?(:condition_block) || conditional
          condition = story[:chunks][-1][:conditions][-1]
          prev_item = story[:chunks][-1][:content][-1]
          if prev_item[:atoms]
            if !prev_item[:atoms].empty?
              prev_item[:atoms][-1][:condition] = condition
              prev_item[:atoms][-1][:condition_segment] = @condition_segment_count
            else
              prev_item[:atoms] << make_atom_hash('', [], condition, @condition_segment_count)
            end
          else
            prev_item[:condition] = condition
          end
        end
      end

      def handle_paragraph_context(line, context)
        if line.empty? && context.include?(:paragraph)
          # capture context closing
          context.delete(:paragraph) if context.include?(:paragraph)
          context_state = :closing
        elsif !context.include?(:paragraph) && !line.empty?
          # capture context opening
          context << :paragraph
          context_state = :opening
        elsif context.include?(:paragraph)
          context_state = :open
        else
          # blank line probably 
        end

        return context_state
      end

      # strip comments from line (comments begin with //)
      def parse_c_comment(line, context)
        return unless line.include?('//')

        prohibited_contexts = [:code_block]
        mandatory_contexts = []
        return unless context_safe?(context, prohibited_contexts, mandatory_contexts)

        if line.strip.start_with?('//')
          return ''
        elsif line.include?(' //')
          index = line.index(' //')
          return line[0...index]
        end

        nil
      end

      def parse_html_comment(line, context, line_no)
        prohibited_contexts = [:code_block]
        mandatory_contexts = []
        return line unless context_safe?(context, prohibited_contexts, mandatory_contexts) 

        left_mark = '<!--'
        right_mark = '-->'

        # catch inline or single line html comment

        if line.include?(left_mark) && line.include?(right_mark)
          line = (pull_out(left_mark, right_mark, line))[0]
          
          return line unless line.empty?

          return nil
        end

        # start html comment (return non-comment part of line)
        if line.include?(left_mark)
          context << (:comment)
          line = left_of_string(line, left_mark)
          return nil if line.strip.empty?
        end

        # end html comment (return non-comment part of line)
        if line.include?(right_mark)
          context.delete(:comment)
          line = right_of_string(line, right_mark)
          return nil if line.strip.empty?
        end

        # while comment is open
        if context.include?(:comment)
          return nil
        end

        return line
      end

      def parse_blockquote(line, context, story, _line_no)
        prohibited_contexts = [:code_block, :trigger_action]
        mandatory_contexts = []
        return unless context_safe?(context, prohibited_contexts, mandatory_contexts)

        # blockquotes must begin the line with >
        # The blockquote will continue until there
        # is a line that does not begin with >
        if line.strip.start_with?('>')
          line.strip!
          line.delete_prefix!('>')
          line.strip!
          
          unless line.empty?
            blq = make_blockquote_hash
            blq[:text] = line
            story[:chunks][-1][:content] << blq
          end

          # if this content is conditional, add the condition to the current element
          if context.include?(:condition_block) || context.include?(:condition_block)
            condition = story[:chunks][-1][:conditions][-1]
            story[:chunks][-1][:content][-1][:condition] = condition
          end

          return true
        end
      end

      def parse_code_fence(line, context, story, line_no)
        return unless line.include?('```') 

        if line.include?('\```')
          line.gsub!('\```', '```')
          return false
        end

        return true
      end

      # Code blocks format code for display
      # They begin with three tildes (~~~) on a blank line
      # and end with three ticks on a blank line
      def parse_code_block(line, context, story, line_no)
        if line.include?('~~~') & !line.include?('\~~~')
          if context.include?(:code_block)
            context.delete(:code_block)
          else
            context << (:code_block)
            story[:chunks][-1][:content] << make_code_block_hash

            # if this content is conditional, add the condition to the current element
            if context.include?(:condition_block) || context.include?(:condition_block)
              condition = story[:chunks][-1][:conditions][-1]
              story[:chunks][-1][:content][-1][:condition] = condition
            end

          end
          true
        elsif context.include?(:code_block)
          # if the line contains escaped fencing, strip the backslash and present it as-is
          line.delete_prefix!('\\') if line.strip.start_with?('\~~~')
          story[:chunks][-1][:content][-1].text += line
          true
        end
      end

      # action blocks contain executable code
      # action block markers are a beginning and ending pair of colons ::
      # action block markers can be block level or line level but not inline

      # Block level:
      # ::
      # # block level
      # code()
      # ::

      # Line level:
      # :: code() ::

      # Inline not supported
      # NO! This will display as text :: code() ::

      # Mixing levels not supported
      # :: no!()
      # ::

      # ::
      # no!() ::

      def parse_action_block(line, context, story, line_no)
        prohibited_contexts = [:code_block, :trigger_action, :condition_block, :condition_block]
        mandatory_contexts = []
        return unless context_safe?(context, prohibited_contexts, mandatory_contexts)

        if line.include? '::'
           # capture single line action
          if line.strip.start_with?(':: ') && line.strip.end_with?(' ::') && line.length > 3
            line.strip!
            line.delete_prefix!(':: ')
            line.delete_suffix!(' ::')
            line.strip!
            if story[:chunks][-1]
              story[:chunks][-1][:actions] << line
            else # different behaviour for code that comes between the title and the first chunk
              story[:actions] ||= []
              story[:actions] << line
            end

            return true
          end

          # capture action block end/start (close/open context)
          if context.include?(:action_block)
            context.delete(:action_block)
          elsif story[:chunks][-1] 
            context << (:action_block)
            story[:chunks][-1][:actions] << ''
          else # different behaviour for code that comes before the first chunk
            context << (:action_block)
          end
          return true

        # capture action block content
        elsif context.include?(:action_block)
          
          if story[:chunks][-1] 
            destination = story[:chunks][-1][:actions][-1]
            
            if destination.nil?
              raise "FORKED: An action block is open but no action exists in the current chunk.\n"\
                    "Check for an unterminated action block (::) around or before line #{line_no + 1}."
            end
            story[:chunks][-1][:actions][-1] += line
          else # different behaviour for code that comes before the first chunk
            story[:actions] ||= []
            story[:actions] << line
          end
          return true
        end
      end

      # condition blocks allow for conditional text
      # NEW SYNTAX
      # They begin with a left angle bracket followed by a colon
      # and end with a colon followed by a right angle bracket
      # The current functionality is to conditionally include text
      # returned from the block as a string
      def parse_condition_block(line, context, story, line_no, story_lines)

        prohibited_contexts = [:code_block]
        mandatory_contexts = []
        return unless context_safe?(context, prohibited_contexts, mandatory_contexts)

        # todo: detect and split *inline* condition into multi-line

        # detect and split single line condition into multi-line
        result = expand_single_line_condition(line, context, story, line_no, story_lines)
        line = story_lines.shift if result

        # DETECT OPENING CONDITION BLOCK
        # opening condition block context and condition code context
        if line.strip.end_with?('<:')
          # open condition block context
          context << :condition_block
          # open condition code block context
          context << :condition_code_block
          # add a new condition to the chunk
          story[:chunks][-1][:conditions] << ''
          # stop processing this line (ignore any following text)
          return true
        end


        # closing both condition code context and condition block context
        if line.strip.start_with?(':>')
          
          # if the last element is a paragraph and
          # if the paragraph context is open, add to it
          # only for interpolation
          if  story[:chunks][-1][:content][-1].type == :paragraph && 
              context.include?(:paragraph) &&
              context.include?(:condition_code_block)
            # most recent element is a paragraph and the paragraph context is open
            # FIXME: this is creating a bogus extra entry.
            # It's supposed to be able to continue a paragraph but it's
            # getting triggered for new paragraphs in addition to the
            # correct code.

            atm = make_atom_hash
            atm[:condition] = story[:chunks][-1][:conditions][-1]
            # story[:chunks][-1][:content][-1][:atoms] << atm

            # story[:chunks][-1][:content][-1][:atoms]
if context.include?(:condition_code_block)
   
            context.delete(:condition_block)
          context.delete(:condition_code_block)
          return :interpolation
end
          elsif context.include?(:condition_code_block)
            context.delete(:condition_block)
          context.delete(:condition_code_block)
          return :interpolation
          end

          # close conditon block and condition code block contexts
          context.delete(:condition_block)
          context.delete(:condition_code_block)
          context.delete(:condition_segment)
          return true
        end

        # NOTE: The above code appends an atom to the previous paragraph
        # if it is the last added element, or creates a new paragraph for the atom.
        # The atom contains only a condition and if the result of the condition
        # is a string, Forked will add the string to the atom text at runtime.

        # If the condition contains content between the closing code fence
        # and the closing condition, that doesn't happen. The following code runs
        # instead.

        # This is important because it's not decided if Forked should display a
        # returned string AND the following conditional content. Right now,
        # it won't do both but only because that's how it happens to be.


        # closing only condition code block context
        if line.strip == '::'
          if context.include? :condition_code_block
            context.delete(:condition_code_block)
            context << (:condition_segment)
            @condition_segment_count = 0
            return true
          elsif context.include? :condition_segment
            @condition_segment_count += 1
          return true
          end
        end

        # capture contents of condition code block
        if context.include?(:condition_code_block)
          story[:chunks][-1][:conditions][-1] += line
          return true
        end

        # nil return allows conditional content to be handled by other parsers
      end

      def expand_single_line_condition(line, context, story, line_no, story_lines)
        if line.strip.start_with?('<: ') && line.strip.end_with?(' :>')
          line.strip!
          line.delete_prefix!('<:').delete_suffix!(':>')
          line.strip!
          return if line.empty?
          
          arr = ['<:']
          line_split = line.split(' :: ')
          line_split.each_with_index do |seg, i|
            next_element = i < line_split.size - 1 ? "::\n" : ":>\n"
            arr += [seg + "\n", next_element]
          end

          story_lines.insert(0, *arr)

          return true
        end
      end

      # The title is required. No content can come before it.
      # The Title line starts with a single #
      def parse_title(line, context, story, _line_no)
        prohibited_contexts = []
        mandatory_contexts = [:title]
        return unless context_safe?(context, prohibited_contexts, mandatory_contexts)

        if line.strip.start_with?('#') && !line.strip.start_with?('##')
          line.strip!
          line.delete_prefix!('#').strip!
        elsif !line.strip.empty?
          raise "FORKED: CONTENT BEFORE TITLE.

The first line of the story file is expected to be the title.
Please add a title to the top of the Story File. Example:

`# The Name of this Story`
"
        end

        story[:title] = line
        context.delete(:title) # title is found
        context << :heading # second element must be a heading
      end

      # The heading line starts a new chunk
      # The heading line begins with a double #
      def parse_heading(line, context, story, line_no)
        return unless line.strip.start_with?('##') && !line.strip.start_with?('###')

        prohibited_contexts = [:code_block]
        mandatory_contexts = []
        return unless context_safe?(context, prohibited_contexts, mandatory_contexts)

        context.delete(:heading)
        context.clear

        line.strip!
        line.delete_prefix!('##').strip!

        gfm_slug = make_slug(line) # GFM style header navigation

        if line.include?('{') && line.include?('}')
          line = pull_out('{', '}', line)
        else
          line = [line]
        end

      
        
        heading, chunk_id = line
            if heading.empty? && chunk_id.nil?
              raise "Forked: Expected heading and/or ID on line #{line_no + 1}."
            end

            heading = story.title.delete_prefix("#").strip if heading.empty?
            chk = make_chunk_hash
            chk[:id] = chunk_id
            chk[:slug] = gfm_slug

            hdg = make_heading_hash
            hdg[:text] = heading

            rul = make_rule_hash
            rul[:weight] = 3

            chk[:content] << hdg
            chk[:content] << rul

            story[:chunks] << chk
            true
      end

      def parse_trigger(line, context, story, line_no)
        prohibited_contexts = [:code_block]
        mandatory_contexts = []
        return unless context_safe?(context, prohibited_contexts, mandatory_contexts)

        # first identify trigger, capture button text and action
        if line.strip.start_with?('[') && 
           line.include?('](') &&
          #  line.strip.end_with?(')')

          # check for existence of `)` after `](` and 
          # return if `)` does not end the line

          line = line.strip.delete_prefix!('[')

          line.split(']', 2).then do |trigger, action|
            trigger.strip!
            action.strip!
            trg = make_trigger_hash
            trg[:text] = trigger
            story[:chunks][-1][:content] << trg

            # if this content is conditional, add the condition to the current element

            if context.include?(:condition_block) || context.include?(:condition_block)
              condition = story[:chunks][-1][:conditions][-1]
              story[:chunks][-1][:content][-1][:condition] = condition
              story[:chunks][-1][:content][-1][:condition_segment] = @condition_segment_count
            end

            ### identify and catch chunk id action (return)
            if action.end_with?(')')
              action.delete_prefix!('(')
              action.delete_suffix!(')')

              if action.start_with?('#') || action.strip.empty?
                # capture simple navigation
                story[:chunks][-1][:content][-1].action = action
                return true
              elsif action.start_with?(': ') && action.end_with?(' :')
                # capture single line trigger action
                action.delete_prefix!(': ')
                action.delete_suffix!(' :')
                # a kludge that identifies a Ruby trigger action from a normal action 
                # so actions that begin with '#' are not mistaken for navigational actions
                action = '@@@@' + action
                story[:chunks][-1][:content][-1].action = action
                return true
              else
                # not navigation, not a single line action, not a multiline action
                raise("UNCLEAR TRIGGER ACTION in line #{line_no + 1}")
              end

            # identify action block and open context (keep parsing)
            elsif action.end_with?('(:')
              context << :trigger_action
            # elsif action.end_with?('(```')
            #   context << :trigger_action
            end
          end
 

        # identfy action block close and close context, if open (return)
        elsif line.strip.start_with?(':)') && context.include?(:trigger_action)
          context.delete(:trigger_action)
          return true
        # elsif line.strip.start_with?('```)') && context.include?(:trigger_action)
        #   context.delete(:trigger_action)
        #   return true

        # if context is open, add line to trigger action (return)
        elsif context.include?(:trigger_action) || context.include?(:trigger_action)
          if story[:chunks][-1][:content][-1].action.size.zero?
            # a kludge that identifies a Ruby trigger action from a normal action 
            # so actions that begin with '#' are not mistaken for navigational actions
            line = '@@@@' + line
          end
          story[:chunks][-1][:content][-1].action += line
          return true
        end
      end 

      def parse_image(line, context, story, line_no)
        prohibited_contexts = [:code_block]
        mandatory_contexts = []
        return unless context_safe?(context, prohibited_contexts, mandatory_contexts)

        # first identify image, capture alt text and path
        if line.strip.start_with?('![') && 
           line.include?('](') &&
           line.strip.end_with?(')')

          line = line.strip.delete_prefix!('![')

          line.split(']', 2).then do |alt, path|
            alt.strip!
            path.strip!

            # this content is conditional? add the condition to the current element

            if context.include?(:condition_block) || context.include?(:condition_block)
              condition = story[:chunks][-1][:conditions][-1]
              story[:chunks][-1][:content][-1][:condition] = condition
              story[:chunks][-1][:content][-1][:condition_segment] = @condition_segment_count
            end

            ### identify and catch url (return)
            path.delete_prefix!('(')
            path.delete_suffix!(')')
            
            img = make_image_hash
            img[:path] = path
            story[:chunks][-1][:content] << img
          end
        end
      end 

      def l_split(line, delimiter)
        return unless idx = line.index(delimiter)
        
        [line[0...idx], line[idx + delimiter.length...line.length]]
      end

      def make_blank_hash
        {
          type: :blank
        } 
      end

      def make_slug(line)
        # make slug for GFM compatibility
        l = line.downcase.gsub(' ', '-')
        slug = ''
        l.chars.each do |c|
          o = c.ord
          if (o >= 97 && o <= 122) || (o >= 48 && o <= 57) || o == 45 || o == 95
           slug += c
          end
        end
        slug
      end

      def make_story_hash
        {
          title: DEFAULT_TITLE,
          chunks: []
        }
      end

      def make_chunk_hash
        {
          id: '',
          actions: [],
          conditions: [],
          content: []
        }
      end

      def make_rule_hash
        {
          type: :rule,
          weight: 1
        }
      end

      def make_paragraph_hash
        {
          type: :paragraph,
          atoms: []
        }
      end

      def make_atom_hash(text = '', styles = [], condition = [], condition_segment = '')
        {
          text: text,
          styles: styles,
          condition: condition,
          condition_segment: condition_segment
        }
      end

      def make_blockquote_hash
        {
          type: :blockquote,
          text: '',
        }
      end

      def make_code_block_hash
        {
          type: :code_block,
          text: ''
        }
      end

      def make_heading_hash
        {
          type: :heading,
          text: ''
        }
      end

      def make_trigger_hash
        {
          type: :button,
          text: '',
          action: ''
        }
      end

      
      def make_image_hash
        {
          type: :image,
          path: ''
        }
      end

      def make_style_marks
        [
          { symbol: :bold_italic, mark: "***" },
          { symbol: :bold_italic, mark: "___" },
          { symbol: :bold, mark: "**" },
          { symbol: :bold, mark: "__"},
          { symbol: :italic, mark: "*" },
          { symbol: :italic, mark: "_" },
          { symbol: :code, mark: "`" }
        ]
      end

      # given a string str and string delimiters left and right
      # returns an array containing
      # [0] the content of the string to the left of the left delimiter + the content of the string to the right of the right delimiter
      # [1] the content of the string between the left and right delimiters
      # If either or both delimiters are not found, [0] will be an empty string and [1] will contain the original str
      def pull_out left, right, str
        left_index = str.index(left)

        if left_index
          right_index = str.index(right, left.length)
        end
        return unless left_index && right_index

        pulled = str.slice!(left_index + left.size..right_index - 1)
        str.sub!(left + right, '')
        [str.strip, pulled.strip]
      end

      # given a string str and a string delimiter
      # returns the portion of str preceding the delimiter
      # returns nil if the delimiter is not found
      def left_of_string str, delimiter
        return unless index = str.index(delimiter)

        str.slice(0, index)
      end

      # given a string str and a string delimiter
      # returns the portion of str following the delimiter
      # returns nil if the delimiter is not found
      def right_of_string str, delimiter
        return unless index = str.index(delimiter)

        index += delimiter.length
        str.slice(index, str.length)
      end
    end
  end
end

$gtk.reset
$story = nil
