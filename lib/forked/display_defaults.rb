def config_defaults
  { 
    display: default_display,
    background: default_background,
    heading: default_heading,
    rule: default_rule,
    paragraph: default_paragraph,
    code_block: default_code_block,
    blockquote: default_blockquote,
    blockquote_image: default_blockquote_image,
    button: default_button,
    selected_button: default_selected_button,
    active_button: default_active_button,
    disabled_button: default_disabled_button,
    bold: default_bold_style,
    italic: default_italic_style,
    bold_italic: default_bold_italic_style,
    code: default_code_style,
    image: default_image_style,
    blockquote_bold: default_blockquote_bold_style,
    blockquote_italic: default_blockquote_italic_style,
    blockquote_bold_italic: default_blockquote_bold_italic_style,
    blockquote_code: default_blockquote_code_style,
    callout: default_callout,
    callout_image: default_callout_image,
    callout_bold: default_callout_bold,
    callout_italic: default_callout_italic,
    callout_bold_italic: default_callout_bold_italic,
    callout_code: default_callout_code
  }
end

def default_display
  ml = if ($gtk.orientation == :portrait) ||
          $gtk.platform?(:touch)
         40
       else
         200
       end
  {
    margin_left: ml,
    margin_top: mt = 60,
    margin_right: mr = ml,
    margin_bottom: mb = 40,
    w: $args.grid.w - (ml + mr),
    h: $args.grid.h - (mb + mt)
  }
end

def default_background
  # if $gtk.orientation == :portrait
  #   angle = -90
  #   x = -280
  #   y = 280
  # else
  #   angle = 0
  #   x = 0
  #   y = 0
  # end
  {
    background_color: { r: 229, g: 229, b: 229 },
    # path: 'sprites/background.png',
    # x: x, y: y,
    # w: 1280,
    # h: 720,
    # angle: angle,
  }
end

def default_paragraph
  size_enum = if ($gtk.orientation == :portrait) ||
                 $gtk.platform?(:ios) ||
                 $gtk.platform?(:android)
                4
              else
                0
              end

  {
    font: 'fonts/roboto/roboto-regular.ttf',
    size_enum: size_enum,
    line_spacing: 1, # 1.0 is the height of the font.
    r: 51, g: 51, b: 51,
    spacing_between: 0.6,
    spacing_after: 0.9,
    margin_left: 0,
    margin_right: 0,
    margin_top: 0,
    margin_bottom: 0,
    padding_left: 0,
    padding_right: 0,
    padding_top: 0,
    padding_bottom: 0,
    text_align: :left,
  }
end

def default_box
  {
    padding_left: 0,
    padding_right: 0,
    padding_top: 0,
    padding_bottom: 0,
    margin_left: 0,
    margin_right: 0,
    margin_top: 0,
    margin_bottom: 0,
    min_height: 0,
    min_w: 0,
  }
end

def default_heading
  {
    r: 51, g: 51, b: 51,
    size_enum: $gtk.orientation == :portrait ? 8 : 4,
    font: 'fonts/roboto/roboto-black.ttf',
    spacing_after: 1.5,
    align: 0.5
  }
end

def default_rule
  {
    r: 51, g: 51, b: 51,
    weight: 3,
    spacing_after: 11
  }
end

def default_code_block
  {
    font: 'fonts/roboto_mono/static/robotomono-regular.ttf',
    size_enum: default_paragraph.size_enum,
    line_spacing: 0.85,
    r: 76, g: 51, b: 127,
    spacing_after: 0.9, # 1.0 is line_height.
    background_color: { r: 192, g: 188, b: 204 },
    **default_code_block_box
  }
end

def default_code_block_box
  default_box.merge(
    r: 192, g: 188, b: 204,
    padding_left: 20,
    padding_right: 20,
    padding_top: 10,
    padding_bottom: 10,
    margin_left: 0,
    margin_right: 0,
    margin_top: 10,
    margin_bottom: 12
  )
end

def default_blockquote
  default_paragraph.merge(
    **default_blockquote_box,
    r: 102, g: 76, b: 51,
    size_enum: default_paragraph.size_enum,
    spacing_between: 0.6,
    spacing_after: 0.9
  )
end

def default_blockquote_box
  default_box.merge(
    background_color: { r: 204, g: 192, b: 168 },
    padding_left: 20,
    padding_right: 20,
    padding_top: 10,
    padding_bottom: 10,
    margin_left: 0,
    margin_right: 0,
    margin_top: 10,
    margin_bottom: 12,
    min_height: 0,
  )
end

def default_blockquote_image
  {
    **default_image_style,
    w: 80,
    h: 80,
    path: 'sprites/haunted.png',
    margin_right: 10,
  }
end

def default_button
  default_paragraph.merge(
    **default_button_box,
    font: 'fonts/roboto/roboto-bold.ttf',
    r: 204, g: 204, b: 204,
    spacing_after: 0.7,
    spacing_between: 0.25
  )
end

def default_button_box
  default_box.merge(
    padding_left: 15,
    padding_top: 6,
    padding_right: 15,
    padding_bottom: 6,
    background_color: { r: 51, g: 51, b: 51 }
  )
end

def default_selected_button
  default_button.merge(
    **default_selected_button_box,
    r: 204, g: 204, b: 204
  )
end

def default_selected_button_box
  default_button_box.merge(
    r: 51, g: 102, b: 102
  )
end

def default_active_button
  default_button.merge(
    **default_active_button_box,
    r: 204, g: 204, b: 204
  )
end

def default_active_button_box
  default_button_box.merge(
    r: 76, g: 51, b: 127
  )
end

def default_disabled_button
  default_button.merge(
    **default_disabled_button_box,
    r: 204, g: 204, b: 204
  )
end

def default_disabled_button_box
  default_button_box.merge!(
    r: 153, g: 153, b: 153
  )
end

# styles
def default_bold_style
  default_paragraph.merge(
    font: 'fonts/roboto/roboto-bold.ttf'
  )
end

def default_italic_style
  default_paragraph.merge(
    font: 'fonts/roboto/roboto-italic.ttf'
  )
end

def default_bold_italic_style
  default_paragraph.merge(
    font: 'fonts/roboto/roboto-bolditalic.ttf'
  )
end

def default_code_style
  default_paragraph.merge(
    font: 'fonts/roboto_mono/static/robotomono-regular.ttf',
    r: 102, g: 51, b: 153
  )
end

def default_blockquote_bold_style
  default_blockquote.merge(
    font: 'fonts/roboto/roboto-bold.ttf'
  )
end

def default_blockquote_italic_style
  default_blockquote.merge(
    font: 'fonts/roboto/roboto-italic.ttf'
  )
end

def default_blockquote_bold_italic_style
  default_blockquote.merge(
    font: 'fonts/roboto/roboto-bolditalic.ttf'
  )
end

def default_blockquote_code_style
  default_blockquote.merge(
    font: 'fonts/roboto_mono/static/robotomono-regular.ttf',
    r: 102, g: 51, b: 153
  )
end

def default_image_style
  {
    margin_left: 0,
    margin_right: 0,
    margin_top: 0,
    margin_bottom: 0,
    spacing_after: 20,
    anchor_x: 0.5,
    x: $args.grid.w.half
  }
end

def default_callout
  {
    **default_blockquote,
    **default_callout_box,
    r: 255 - 204, g: 255 - 179, b: 255 - 153,
  }
end

def default_callout_box
  {
    **default_blockquote_box,
    background_color: { r: 168, g: 222, b: 244 },
    padding_top: 10,
    padding_right: 10,
    padding_left: 10,
    padding_bottom: 10,
    margin_top: 0,
    margin_left: 100,
    margin_right: 100,
    margin_bottom: 20,
    min_height: 100,
  }

end

def default_callout_image
  {
    **default_image_style,
    w: 80, h: 80,
    margin_left: 10,
    margin_top: 10,
    margin_right: 10,
    margin_bottom: 10,
  }
end

def default_callout_bold
  {
    **default_bold_style,
    r: 51, g: 76, b: 102,
  }
end

def default_callout_italic
  {
    **default_italic_style,
    r: 51, g: 76, b: 102,
  }
end

def default_callout_bold_italic
  {
    **default_bold_italic_style,
    r: 51, g: 76, b: 102,
  }
end

def default_callout_code
  {
    **default_code_style,
  }
end

$gtk.reset
$display = nil
