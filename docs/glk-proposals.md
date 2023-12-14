---
layout: default
---

# Glk Extension Proposals

## CSS

[Forum discussion](https://intfiction.org/t/glk-extension-proposal-css/66228)

These functions allow you to set arbitrary CSS styles. While of most use in a HTML-based interpreter, some non-HTML interpreters may supported small text formatting subsets of CSS.

Support for these functions can be tested with `gestalt_CSSBasic` (Gestalt code `TBA`). You can also make a preprocessor test for `GLK_MODULE_CSS_BASIC`.

In these functions buffers refer to UTF-8 byte arrays. Most CSS only needs ASCII, so you usually won't need to worry about UTF-8 encoding. But if you need non-ASCII characters, you can use the [UTF-8 encoding/decoding functions](#utf-8-encodingdecoding).

### Window CSS hints

These functions allow you to set arbitrary CSS styles *before* opening a window, in the manner of the [standard Glk stylehints](https://eblong.com/zarf/glk/Glk-Spec-075.html#stream_style_hints).

```c
// Function code: TBA
void glk_css_hint_set(glui32 wintype, glui32 styl, glui32 par_or_span,
    char *prop, glui32 proplen, char *val, glui32 vallen);
// Function code: TBA
void glk_css_hint_set_num(glui32 wintype, glui32 styl, glui32 par_or_span,
    char *prop, glui32 proplen, glsi32 val);
// Function code: TBA
void glk_css_hint_clear(glui32 wintype, glui32 styl, glui32 par_or_span,
    char *prop, glui32 proplen);

#define CSS_Span (0)
#define CSS_Paragraph (1)
```

These functions allow you to set CSS for entire paragraphs (only being applied if the style is the first style of a paragraph), or span styles for within a paragraph. Note that "paragraph" here refers to blocks of text broken by line break characters, not blank lines.

The `wintype` and `styl` have the same meanings as in the Glk stylehint functions. `par_or_span` specifies whether the style should be set on paragraphs or styles. `prop` and `proplen` specify a buffer giving the text of the CSS property. The value can either be given as another buffer, or as a signed number.

```c
// Function code: TBA
void glk_css_hint_selector_set(char *sel, glui32 sellen,
    char *prop, glui32 proplen, char *val, glui32 vallen);
// Function code: TBA
void glk_css_hint_selector_set_num(char *sel, glui32 sellen,
    char *prop, glui32 proplen, glsi32 val);
// Function code: TBA
void glk_css_hint_selector_clear(char *sel, glui32 sellen,
    char *prop, glui32 proplen);
```

These functions are for manually specifying the selector of a CSS rule. They are still scoped to a window, so send an empty `sel` buffer to target the window itself. If you want to replicate the standard paragraph and span selectors, they are specified as classes for each Glk style, with `_para` appended for paragraph styles. (The capitalisation is unfortunately the opposite of how they are in Glk.) Note that the `.` must be manually included.

| Glk style | Class |
|-------|-------|
| style_Normal | Style_normal |
| style_Emphasized | Style_emphasized |
| style_Preformatted | Style_preformatted |
| style_Header | Style_header |
| style_Subheader | Style_subheader |
| style_Alert | Style_alert |
| style_Note | Style_note |
| style_BlockQuote | Style_blockquote |
| style_Input | Style_input |
| style_User1 | Style_user1 |
| style_User2 | Style_user2 |

### Inline CSS styles

These functions allow you to specify inline CSS styles. They are a generalisation of the [Gargoyle text formatting extensions](gargoyle.md#text-formatting). As these are inline styles it only makes sense to set CSS properties that apply to spans.

```c
// Function code: TBA
void glk_css_inline_set(char *prop, glui32 proplen, char *val, glui32 vallen);
// Function code: TBA
void glk_css_inline_set_num(char *prop, glui32 proplen, glsi32 val);
// Function code: TBA
void glk_css_inline_clear(char *prop, glui32 proplen);
```

### Non-standard CSS properties

A few properties are supported that are not part of CSS. While standard CSS properties could be used, it is recommended that these properties be used for maximum portability. Both of these properties should only be used for spans, they may not have any effect, or may misbehave, if set on paragraphs.

| Property | Function |
|----------|----------|
| monospace | Sets text to be monospaced, by adding the class `monospace` to the span. |
| reverse | Enables reverse mode (as the [reverse functions do](gargoyle.md#reverse-mode)). If you also provide colours, then do not preemptively reverse them. For example: `background-color: #FFF, color: #000, reverse: 1` will be displayed as white text on a black background. |

### Future

Functions for testing and measuring CSS styles may be added in the future.

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

These two functions encode/decode between Glk's UTF-32 arrays, and UTF-8 byte arrays.

Support for these functions can be tested with `gestalt_Utf8` (Gestalt code `TBA`). You can also make a preprocessor test for `GLK_MODULE_UTF8`.

```c
// Function code: TBA
glui32 glk_encode_utf8(glui32 *src, glui32 srclen, char *dest, glui32 destlen);
// Function code: TBA
glui32 glk_decode_utf8(char *src, glui32 srclen, glui32 *dest, glui32 destlen);
```

Each function takes a source buffer and a destination buffer. The source buffer length is the actual length of its text, the destination buffer length is its maximum capacity. Like the standard Glk text conversion functions, it is possible the result might be longer than the destination buffer. If this is the case the result will be truncated to fit in the buffer, and the function will return what the length should have been.