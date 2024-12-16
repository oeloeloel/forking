module Forked
  # Display class
  class Display
    # TODO: prevent buttons from being instantiated if object already exists
    # TODO: wrap up button generation code and put it in the button module

    def display_button(y_pos, item, _content, __i)
      button = data.style.button
      display = data.style.display
      # button_box = data.style.button_box

      button.size_px = args.gtk.calcstringbox('X', button.size_enum, button.font)[1]

      # previous element is also a button? use spacing_between instead of spacing_after
      if @last_printed_element_type == :button
        y_pos += button.spacing_after * button.size_px
        y_pos -= button.spacing_between * button.size_px
      end

      if item.action.empty?
        button = data.style.disabled_button
        # button_box = data.style.disabled_button_box
      end

      text_w, button.size_px = args.gtk.calcstringbox(item.text, button.size_enum, button.font)
      text_w = text_w.to_i
      button_h = (button.size_px + button.padding_top + button.padding_bottom)

      x = display.margin_left
      y = (y_pos - button_h).to_i
      w = text_w + button.padding_left + button.padding_right
      h = (button.size_px + button.padding_top + button.padding_bottom).to_i

      pill_button_base = { x: x, y: y, w: w, h: h, text: item.text, action: item.action }

      enabled = Effed.pill_button_layer(
        args,
        rect: pill_button_base,
        color: { r: button.r, g: button.g, b: button.b, a: button.a || 255 },
        bg: { 
          r: button.background_color.r, 
          g: button.background_color.g, 
          b: button.background_color.b, 
          a: button.a || 255
        },
        font: button.font,
        size_enum: button.size_enum
      )
      focused = Effed.pill_button_layer(
        args,
        rect: pill_button_base,
        color: {
          r: data.style.selected_button.r,
          g: data.style.selected_button.g,
          b: data.style.selected_button.b,
          a: data.style.selected_button.a || 255
        },
        bg: {
          r: data.style.selected_button.background_color.r,
          g: data.style.selected_button.background_color.g,
          b: data.style.selected_button.background_color.b,
          a: data.style.selected_button.background_color.a || 255
        },
        font: data.style.selected_button.font,
        size_enum: data.style.selected_button.size_enum
      )
      active = Effed.pill_button_layer(
        args,
        rect: pill_button_base,
        color: {
          r: data.style.active_button.r,
          g: data.style.active_button.g,
          b: data.style.active_button.b,
          a: data.style.active_button.a || 255
        },
        bg: {
          r: data.style.active_button.background_color.r,
          g: data.style.active_button.background_color.g,
          b: data.style.active_button.background_color.b,
          a: data.style.active_button.a || 255
        },
        font: data.style.active_button.font,
        size_enum: data.style.active_button.size_enum
      )
      disabled = Effed.pill_button_layer(
        args,
        rect: pill_button_base,
        color: {
          r: data.style.disabled_button.r,
          g: data.style.disabled_button.g,
          b: data.style.disabled_button.b,
          a: data.style.disabled_button.a || 255
        },
        bg: {
          r: data.style.disabled_button.background_color.r,
          g: data.style.disabled_button.background_color.g,
          b: data.style.disabled_button.background_color.b,
          a: data.style.disabled_button.background_color.a || 255
        },
        font: data.style.disabled_button.font,
        size_enum: data.style.disabled_button.size_enum
      )

      option = Effed::FButton.new(
        rect: pill_button_base,
        enabled: enabled,
        focused: focused,
        active: active,
        disabled: disabled
      )

      option.force_status_change(:disabled) if item.action.empty?

      data.options << option if item&.action && !item.action.empty?
      data.primitives << option

      y_pos - (button.padding_top +
               button.padding_bottom +
               button.size_px +
               button.size_px * button.spacing_after)
    end
  end
end
