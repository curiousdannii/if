---
layout: default
---

# Gargoyle Glk Extensions

[Gargoyle](https://github.com/garglk/garglk) added some internal extensions to Glk. This page formally defines those extensions so that they can be used by authors, and potentially be added to other Glk implementations.

## Text formatting

These functions allow you to control colours and reverse styling at character granularity. This is needed for fully implementing a Z-Machine interpreter in Glk, as [Glk's style system](http://eblong.com/zarf/glk/glk-spec-075_5.html#s.5) isn't powerful enough. But it could also be used directly by authors.

Support for these functions can be tested with `gestalt_GarglkText` (Gestalt code `0x1100`). You can also make a preprocessor test for `GLK_MODULE_GARGLKTEXT`.

Resources:

 - Test file: [gargoyle-text.inf](https://github.com/curiousdannii/if/blob/master/tests/gargoyle-text.inf), [gargoyle-text.ulx](https://github.com/curiousdannii/if/blob/master/tests/gargoyle-text.ulx)
 - Inform 7 extension: [Glk Text Formatting.i7x](https://github.com/i7/extensions/blob/master/Dannii%20Willis/Glk%20Text%20Formatting.i7x)

### Colours

```c
/* Function code: 0x1100 */
void garglk_set_zcolors(glui32 fg, glui32 bg);
/* Function code: 0x1101 */
void garglk_set_zcolors_stream(strid_t str, glui32 fg, glui32 bg);

#define zcolor_Default (-1)
#define zcolor_Current (-2)
```

These functions set the current text foreground and background colours. Each stream has its own colours (though they will only be used for window streams). Use `garglk_set_zcolors_stream` to specify a stream, or `garglk_set_zcolors` to modify the current stream.

Colour numbers are encoded RGB values in the same way as the [`stylehint_TextColor` style hint](http://eblong.com/zarf/glk/glk-spec-075_5.html#s.5.1).

The negative colour numbers are special codes with the same meanings as those from the [Z-Machine section 8.3.7](http://inform-fiction.org/zmachine/standards/z1point1/sect08.html#three). To change only the foreground colour or only the background colour, pass `zcolor_Current` or `-2` for the other parameter, which will keep the current colour unchanged. Pass `zcolor_Default` or `-1` to reset to the current style's foreground or background colour.

Switching to a style which has a colour stylehint set will not override the colours specified with these functions. These colours will continue to be used until you disable them with `zcolor_Default`, after which the style's colour stylehints will be used.

### Reverse mode

```c
/* Function code: 0x1102 */
void garglk_set_reversevideo(glui32 reverse);
/* Function code: 0x1103 */
void garglk_set_reversevideo_stream(strid_t str, glui32 reverse);
```

These functions set the reverse mode. Pass a non-zero `reverse` parameter to enable reverse mode, and pass 0 to disable reverse mode. Use `garglk_set_reversevideo_stream` to specify a stream, or `garglk_set_reversevideo` to modify the current stream.

Unlike colours, reverse mode stylehints do interact with these functions: reverse mode will be used if either the current style has a stylehint enabling it, or if it has been enabled by these functions. When stylehints enable reverse mode, you cannot call `garglk_set_reversevideo` to disable it; you can only disable reverse mode by switching to another style.

## garglk_fileref_get_name (deprecated)

This function has been deprecated in favour of this glkunix function, with preprocessor macro `GLKUNIX_FILEREF_GET_FILENAME`:

```c
const char *glkunix_fileref_get_filename(frefid_t fref);
```

---------------

This function is required by the Glk ports of several interpreters. It returns a C string of the fileref's internal filename. In most implementations no transformation or sanitation of the filename should be required.

Support for these functions can be tested with `gestalt_FilerefGetName` (Gestalt code `0x1104`). You can also make a preprocessor test for `GLK_MODULE_FILEREF_GET_NAME`.

```c
/* Function code: 0x1104 */
char* garglk_fileref_get_name(frefid_t fref);
```