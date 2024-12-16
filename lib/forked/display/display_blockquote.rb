module Forked
  # Display class
  class Display
    ### BLOCKQUOTE

    def display_blockquote(y_pos, item)
      display = data.style.display
      blockquote = data.style.blockquote

      next_y_pos = y_pos - blockquote.padding_top
      labels = []

      # return y_pos
      item.content.each do |para|
        result = display_blockquote_paragraph(next_y_pos, para)
        @last_printed_element_type = :blockquote_paragraph
        next_y_pos = result[0]
        labels << result[1]
      end

      next_y_pos += blockquote.size_px * blockquote.spacing_after

      next_y_pos -= blockquote.padding_bottom
      box_height = y_pos - next_y_pos

      rect = {
        x: display.margin_left + blockquote.margin_left,
        y: next_y_pos.to_i,
        w: display.w - blockquote.margin_left - blockquote.margin_right,
        h: box_height,
        a: 25,
        r: blockquote.background_color.r,
        g: blockquote.background_color.g,
        b: blockquote.background_color.b
      }

      bg = Effed.rounded_panel(rect: rect)
      data.primitives << [bg, labels]

      next_y_pos -= blockquote.margin_bottom

      next_y_pos
    end

    def display_blockquote_paragraph(y_pos, item)
      blockquote = data.style.blockquote
      display = data.style.display
      blockquote.size_px = args.gtk.calcstringbox('X', blockquote.size_enum, blockquote.font)[1]
      output_labels = []

      left_margin = blockquote.margin_left + blockquote.padding_left
      w = display.w - blockquote.margin_right - blockquote.padding_right

      x_pos = left_margin
      new_y_pos = y_pos

      if @last_printed_element_type == :blockquote_paragraph
        # paragraph follows paragraph, so undo the added 'spacing after'
        new_y_pos += blockquote.size_px * blockquote.spacing_after
        # paragraph follows paragraph, so add 'spacing between'
        new_y_pos -= blockquote.size_px * blockquote.spacing_between
      end

      args.state.forked.forked_display_last_element_empty = false

      empty_paragraph = true # until proven false

      item.atoms.each_with_index do |atom, i|
        # when we're at the end of the paragraph and no atoms have had any text
        # mark it as empty so we know not to remove added 'spacing after'
        empty_paragraph = false if atom[:text].strip != ''
        if i == item.atoms.size - 1 && empty_paragraph
          args.state.forked.forked_display_last_element_empty = true
          # previous element was a paragraph? remove the between spacing
          new_y_pos += blockquote.size_px * blockquote.spacing_between
          # add 'spacing after'. Next element might not be a paragraph.
          new_y_pos -= blockquote.size_px * blockquote.spacing_after
        end

        font_style = get_blockquote_font_style(atom.styles)
        font_style.size_px = args.gtk.calcstringbox('X', font_style.size_enum, font_style.font)[1]

        words = split_preserve_one_space(atom.text)
        line_frag = ''
        until words.empty?
          word = words[0]

          new_frag = line_frag + word
          new_x_pos = x_pos + gtk.calcstringbox(new_frag, font_style.size_enum, font_style.font)[0]
          if new_x_pos > w
            loc = { x: x_pos.to_i + display.margin_left, y: new_y_pos.to_i }
            lab = loc.merge(make_blockquote_label(line_frag, font_style))
            output_labels << lab
            line_frag = ''
            x_pos = left_margin

            # line space after soft wrap
            new_y_pos -= blockquote.size_px * blockquote.line_spacing
          else
            ### CHANGED
            line_frag = new_frag # + ' '
            words.shift
          end

          next unless words.empty?

          loc = { x: x_pos.to_i + display.margin_left, y: new_y_pos.to_i }
          lab = loc.merge(make_blockquote_label(line_frag, font_style))
          output_labels << lab
          x_pos = new_x_pos # + default_space_w
          line_frag = ''
          if atom.text[-1] == "\n"
            x_pos = left_margin

            # line space after hard wrap
            new_y_pos -= blockquote.size_px * blockquote.line_spacing
          end

          # we made it this far and this is the last atom? add
          # line spacing and 'spacing after'
          if i == item.atoms.size - 1
            new_y_pos -= blockquote.size_px * blockquote.line_spacing
            new_y_pos -= blockquote.size_px * blockquote.spacing_after
          end
        end

        # this is the last atom and it's empty but the paragraph is not empty?
        # (interpolation will do this), apply paragraph spacing now because
        # we won't get there otherwise
        if  atom[:text] == '' &&
            !empty_paragraph &&
            i == item.atoms.size - 1
          new_y_pos -= blockquote.size_px * blockquote.line_spacing
          new_y_pos -= blockquote.size_px * blockquote.spacing_after
        end
      end

      # return the y_pos for the next element
      y = empty_paragraph ? y_pos : new_y_pos
      [y, output_labels]
    end

    # make a one line label in the specified style
    def make_blockquote_label(text, font_style)
      {
        text: text
      }.label!(data.style.blockquote).merge!(font_style)
    end

    def get_blockquote_font_style(styles)
      if styles.include?(:bold) && styles.include?(:italic)
        data.style.blockquote_bold_italic
      elsif styles.include? :bold_italic
        data.style.blockquote_bold_italic
      elsif styles.include? :bold
        data.style.blockquote_bold
      elsif styles.include? :italic
        data.style.blockquote_italic
      elsif styles.include? :code
        data.style.blockquote_code
      else
        data.style.blockquote
      end
    end
  end
end
