module Forked
  # Display class
  class Display
    def display_code_block(y_pos, item, _previous_element_type)
      code_block = data.style.code_block
      display = data.style.display
      # code_block_box = data.style.code_block_box

      text_array = wrap_lines_code_block(
        item.text, code_block.font, code_block.size_enum,
        display.w - (code_block.padding_left + code_block.padding_right)
      )
      code_block.size_px = args.gtk.calcstringbox('X', code_block.size_enum, code_block.font)[1]

      box_height = text_array.count * (code_block.size_px * code_block.line_spacing) +
                   code_block.padding_top + code_block.padding_bottom

      temp_y_pos = y_pos

      rect = {
        x: display.margin_left,
        y: y_pos - box_height.to_i,
        w: display.w,
        h: box_height.to_i,
        r: code_block.background_color.r,
        g: code_block.background_color.g,
        b: code_block.background_color.b
      }
      bg = Effed.rounded_panel(rect: rect)
      data.primitives << bg

      temp_y_pos -= code_block.padding_top
      data.primitives << text_array.map do |line|
        label = {
          x: display.margin_left + code_block.padding_left,
          y: temp_y_pos.to_i,
          text: line
        }.label!(code_block)

        temp_y_pos -= code_block.size_px * code_block.line_spacing

        label
      end

      y_pos -= box_height
      y_pos - code_block.margin_bottom
    end
  end
end
