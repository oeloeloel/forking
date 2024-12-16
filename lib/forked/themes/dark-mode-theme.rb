module DARK_MODE
  NEAR_BLACK = { r: 35,  g: 35,  b: 35  }
  NULL_GRAY  = { r: 102, g: 102, b: 102 }
  OFF_WHITE  = { r: 204, g: 204, b: 204 }

  DARK_RED   = { r: 87,  g: 33,  b: 11  }
  HOT_PINK   = { r: 255, g: 102, b: 102 }
  PINK       = { r: 204, g: 153, b: 153 }

  PALE_BLUE  = { r: 153, g: 179, b: 204 }
  DARK_BLUE  = { r: 51,  g: 63,  b: 87  }

  DARK_GREEN = { r: 63,  g: 67,  b: 51  }
  GREEN      = { r: 153, g: 204, b: 102 }
  PALE_GREEN = { r: 179, g: 204, b: 127 }

  class << self
      def theme
      {
        display: {
          # nothing to see here
        },
        background: {
          background_color: NEAR_BLACK,
        },
        heading: {
          **OFF_WHITE,
        },
        rule: {
          **OFF_WHITE,
        },
        paragraph: p = {
          **OFF_WHITE,
        },
        code_block: {
          **PALE_GREEN,
          background_color: DARK_GREEN,
          padding_top: 10,
          padding_bottom: 14,
        },
        blockquote: bq = {
          **p,
          **PALE_BLUE,
          background_color: DARK_BLUE,
        },
        button: {
          **NEAR_BLACK,
          background_color: OFF_WHITE,
        },
        selected_button: {
          **NEAR_BLACK,
          background_color: PINK,
        },
        disabled_button: {
          **NEAR_BLACK,
          background_color: NULL_GRAY,
        },
        active_button: {
          **NEAR_BLACK,
          background_color: HOT_PINK,
        },
        bold: {
          **OFF_WHITE,
        },
        italic: {
          **OFF_WHITE, 
        },
        bold_italic: {
          **OFF_WHITE, 
        },
        code: {
          **GREEN 
        },
        blockquote_bold: blockquote_bold = {
          **PALE_BLUE,
        },
        blockquote_italic: {
          **PALE_BLUE,
        },
        blockquote_bold_italic: {
          **PALE_BLUE, 
        },
        blockquote_code: {
          **GREEN
        },
        callout: {
          **bq,
          **PINK,
          background_color: DARK_RED,
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
          **PINK,
        },
        callout_italic: {
          **default_italic_style,
          **PINK,
        },
        callout_bold_italic: {
          **default_bold_italic_style,
          **PINK,
        },
        callout_code: {
          **default_code_style,
          **GREEN
        },
      }
    end
  end
end