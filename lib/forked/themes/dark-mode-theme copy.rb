DARK_MODE = {
  display: {
    # nothing to see here
  },
  background: {
    background_color: { r: 35, g: 35, b: 35 },
  },
  heading: {
    r: 204, g: 204, b: 204,
  },
  rule: {
    r: 204, g: 204, b: 204,
  },
  paragraph: p = {
    r: 204, g: 204, b: 204,
  },
  code_block: {
    r: 179, g: 204, b: 127,
  },
  code_block_box: {
    r: 63, g: 67, b: 51,
  },
  blockquote: bq = {
    **p,
    r: 153, g: 179, b: 204,
  },
  blockquote_box: {
    r: 51, g: 63, b: 87,
  },
  button: {
    r: 51, g: 51, b: 51,
  },
  button_box: {
    r: 204, g: 204, b: 204,
  },
  selected_button: {
    r: 51, g: 51, b: 51, 
  },
  selected_button_box: {
    r: 204, g: 153, b: 153, 
  },
  disabled_button: {
    r: 51, g: 51, b: 51,
  },
  disabled_button_box: {
    r: 102, g: 102, b: 102, 
  },
  active_button: {
    r: 51, g: 51, b: 51,
  },
  active_button_box: {
    r: 255, g: 102, b: 102,
  },
  bold: {
    r: 204, g: 204, b: 204,
  },
  italic: {
    r: 204, g: 204, b: 204, 
  },
  bold_italic: {
    r: 204, g: 204, b: 204, 
  },
  code: {
    r: 153, g: 204, b: 102,
  },
  blockquote_bold: blockquote_bold = {
    r: 153, g: 179, b: 204,
  },
  blockquote_italic: {
    r: 153, g: 179, b: 204,
  },
  blockquote_bold_italic: {
    r: 153, g: 179, b: 204, 
  },
  blockquote_code: {
    r: 153, g: 204, b: 102,
  },
  callout: {
    **bq,
    r: 204, g: 179, b: 153,
  },
  callout_box: {
    **default_blockquote_box,
    r: 87, g: 33, b: 11,
    padding_top: 10,
    padding_right: 10,
    padding_left: 10,
    padding_bottom: 10,
    margin_top: 0,
    margin_left: 100,
    margin_right: 100,
    margin_bottom: 20,
    min_height: 100,
  },
  callout_image: {
    w: 80, h: 80,
    margin_left: 10,
    margin_top: 10,
    margin_right: 10,
    margin_bottom: 10,
  },
  callout_paragraph: cp = {
    **bq,
    margin_left: 130,
    margin_right: 110,
    r: 255, g: 0, b: 0
  },
  callout_bold: {
    **default_bold_style,
    **blockquote_bold,
    r: 204, g: 179, b: 153,
  },
  callout_italic: {
    **default_italic_style,
    r: 204, g: 179, b: 153,
  },
  callout_bold_italic: {
    **default_bold_italic_style,
    r: 204, g: 179, b: 153,
  },
  callout_code: {
    **default_code_style,
    r: 153, g: 204, b: 102,
  },
}