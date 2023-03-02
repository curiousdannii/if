---
layout: default
---

# Miscellaneous Glk Extensions

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
