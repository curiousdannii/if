---
layout: default
---

# Glk Extension Proposals

## CSS

[Forum discussion](https://intfiction.org/t/glk-extension-proposal-css/66228)

These functions allow you to set arbitrary CSS styles. While of most use in a HTML-based interpreter, some non-HTML interpreters may supported small text formatting subsets of CSS.

Support for these functions can be tested with `gestalt_CSSBasic` (Gestalt code `0x1110`). You can also make a preprocessor test for `GLK_MODULE_CSS_BASIC`.

In these functions buffers refer to UTF-8 byte arrays. Most CSS only needs ASCII, so you usually won't need to worry about UTF-8 encoding. But if you need non-ASCII characters, you can use the [UTF-8 encoding/decoding functions](#utf-8-encodingdecoding).

### Window CSS hints

These functions allow you to set arbitrary CSS styles *before* opening a window, in the manner of the [standard Glk stylehints](https://eblong.com/zarf/glk/Glk-Spec-075.html#stream_style_hints).

```c
// Function code: 0x1110
void glk_css_hint_set(glui32 wintype, glui32 csstarget, glui32 style,
    const char *prop, glui32 proplen, const char *val, glui32 vallen);
// Function code: 0x1111
void glk_css_hint_set_num(glui32 wintype, glui32 csstarget, glui32 style,
    const char *prop, glui32 proplen, glsi32 val);
// Function code: 0x1112
void glk_css_hint_clear(glui32 wintype, glui32 csstarget, glui32 style,
    const char *prop, glui32 proplen);

#define CSS_Span (0)
#define CSS_Paragraph (1)
#define CSS_Hyperlink (2)
#define CSS_Image (3)
#define CSS_Input (4)
#define CSS_Window (5)
```

The `wintype` and `style` have the same meanings as in the Glk stylehint functions. `prop` and `proplen` specify a buffer giving the text of the CSS property. The value can either be given as another buffer, or as a signed number.

`csstarget` specifies how this style should be applied: `CSS_Paragraph` means an entire paragraph (only being applied if the style is the first style of a paragraph), or `CSS_Span` specifies styles for within a paragraph. Note that "paragraph" here refers to blocks of text broken by line break characters, not blank lines.

`csstarget` can also specify something more unusual: the window itself, or the hyperlinks, images, or input it contains. The `style` argument is ignored for `CSS_Input` and `CSS_Window`.

### Inline CSS styles

```c
// Function code: 0x1113
void glk_css_inline_set(glui32 csstarget, const char *prop, glui32 proplen,
    const char *val, glui32 vallen);
// Function code: 0x1114
void glk_css_inline_set_num(glui32 csstarget, const char *prop, glui32 proplen,
    glsi32 val);
// Function code: 0x1115
void glk_css_inline_clear(glui32 csstarget, const char *prop, glui32 proplen);
```

These functions allow you to specify inline CSS styles. They are a generalisation of the [Gargoyle text formatting extensions](gargoyle.md#text-formatting). Inline paragraph styles will be applied after the next line break is output. The `csstarget` can be set to `CSS_Hyperlink` or `CSS_Image` and will apply to the next hyperlink or image.

### Clearing styles en masse

```c
// Function code: 0x1116
void glk_css_hint_clear_all_by_style(glui32 wintype, glui32 style);
// Function code: 0x1117
void glk_css_hint_clear_all_by_window(glui32 wintype);
// Function code: 0x1118
void glk_css_hint_clear_all_inline();
```

These functions allow you to clear styles en masse. Note that they will also clear stylehints set with `glk_stylehint_set`. `glk_css_hint_clear_all_by_window` will clear all styles for a window type. `glk_css_hint_clear_all_inline` will clear the styles set with the [Gargoyle text formatting extensions](gargoyle.md#text-formatting).

### Properties with special behaviour

A few properties may be interpreted specially by the library.

| Property | Values | Function |
|----------|--------|----------|
| `font-family` | `monospace` (or `monospace, monospace`), `unset` | Sets text to be monospaced, possibly with additional processing. If you set additional font families with `monospace` as a fallback, or if you set `monospace` in a shorthand `font` style, the additional processing may not be performed. |
| `-iftf-reverse-video` | `reverse`, `none` | Enables reverse mode (as the [reverse functions do](gargoyle.md#reverse-mode)). If you also provide colours, then do not preemptively reverse them. For example: `background-color: #FFF, color: #000, -iftf-reverse-video: reverse` will be displayed as white text on a black background. |

### Future

Functions for testing and measuring CSS styles may be added in the future.

## External hyperlinks

[Forum discussion](https://intfiction.org/t/glk-extension-proposals-extra-styles-and-open-url/79698)

Many authors would like to be able to share a URL from their games. Some interpreters will autolinkify a URL that has been printed, but not all, and that necessitates printing the entire URL. These functions allows authors to make hyperlinks to external websites. Interpreters should make it possible for players to see the URL before they click on the link, such as with a tooltip.

Support for these functions can be tested with `gestalt_ExternalHyperlinks` (Gestalt code `TBA`). You can also make a preprocessor test for `GLK_MODULE_EXTERNAL_HYPERLINKS`.

```c
// Function code: TBA
void glk_set_hyperlink_external(const char *url, glui32 urllen);
// Function code: TBA
void glk_set_hyperlink_external_stream(strid_t str, const char *url, glui32 urllen);
```

The URL must be ASCII (pre-encode any higher character codes). Like standard hyperlinks only one can be active at a time, so calling any hyperlink function will end this hyperlink. Clicking on an eternal hyperlink will not generate a Glk event.

## Pixel Ratio

[Forum discussion](https://intfiction.org/t/glk-extension-proposal-pixel-ratio/59550)

Many devices now come with very high resolution screens but act as if they have a lower resolution, so that application user interfaces will still be useable by people with normal eyesights. While text will usually be automatically displayed sharply using the advantages of the high resolution, images may not be; applications usually have to be aware of the possibility of this virtual-to-physical pixel ratio in order to display images at the native physical resolution.

Until now a Glk application has not been able to take full advantage of higher pixel ratios. When an image is displayed at smaller than full-size then the Glk library may display the image using the extra pixels so that it looks better than it would on a 1:1 screen, but if you display an image at full-size then each virtual pixel will cover multiple physical pixels. If the pixel ratio is non integer then a full-size image will actually have to be stretched and distorted.

This Glk extension exposes the device's pixel ratio and adds a function to switch a window to use physical pixel values. You can make a C preprocessor test for this extension with `GLK_MODULE_PIXELRATIO`.

To measure the device's pixel ratio, use the gestalt selector `gestalt_PixelRatio` (gestalt code `TBA`). If the interpreter is able to calculate the pixel ratio, then this gestalt call will return the ratio multiplied by 1 million. So a non-high-DPI screen will return `1000000`. A Windows laptop set to 150% screen scaling will return `1500000`. An iPhone 12 would return `3000000` and a Pixel 5 would return `2750000`. A device with a ratio of 4:3 would return `1333333`. If the extension is not supported then it will return `0`.

By default a Glk window uses virtual pixels for everything. This function call will switch a window to use physical pixels, pass `1` to enable, and `0` to return to virtual pixels:

```c
// Function code: TBA
void glk_window_use_physical_pixels(winid_t win, glui32 val);
```

What precise effect this has depends on type of window:

 - Buffer windows: `glk_image_draw` and `glk_image_draw_scaled` will draw images using physical pixels, the former at full-size, the latter with the given height and width.

 - Graphics windows: All the standard graphics window functions will use physical pixel coordinates: `glk_window_erase_rect`, `glk_window_fill_rect`, `glk_image_draw`, `glk_image_draw_scaled`. In addition `glk_window_get_size` will return the physical size of the canvas.

Calling `glk_window_use_physical_pixels` on any other window type has no effect.

Note that window arrangements *cannot* use physical pixels. If you have switched a graphics window to physical pixels, both `glk_window_get_arrangement` and `glk_window_set_arrangement` will continue to use virtual pixel sizes. So be careful to ensure that if you measure a window using `glk_window_get_size` that you account for the pixel ratio before passing any value derived from it to `glk_window_set_arrangement`.

## UTF-8 Encoding/decoding

[Forum discussion](https://intfiction.org/t/glk-extension-proposal-css/66228)

These two functions encode/decode between Glk's UTF-32 arrays, and UTF-8 byte arrays.

Support for these functions can be tested with `gestalt_UTF8` (Gestalt code `TBA`). You can also make a preprocessor test for `GLK_MODULE_UTF8`.

```c
// Function code: TBA
glui32 glk_encode_utf8(const glui32 *src, glui32 srclen, char *dest, glui32 destlen);
// Function code: TBA
glui32 glk_decode_utf8(const char *src, glui32 srclen, glui32 *dest, glui32 destlen);
```

Each function takes a source buffer and a destination buffer. The source buffer length is the actual length of its text, the destination buffer length is its maximum capacity. Like the standard Glk text conversion functions, it is possible the result might be longer than the destination buffer. If this is the case the result will be truncated to fit in the buffer, and the function will return what the length should have been. If there was an encoding/decoding error, then the function will return `-1` and the destination buffer's contents will be undefined.
