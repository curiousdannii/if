---
layout: default
---

# Gargoyle Glk Extensions

[Gargoyle](https://github.com/garglk/garglk) added some internal extensions to Glk. This page formally defines those extensions so that they can be used by authors, and potentially be added to other Glk implementations.

## Text formatting

These functions allow you to control colours and reverse styling at character granularity. This is needed for fully implementing a Z-Machine interpreter in Glk, as [Glk's style system](http://eblong.com/zarf/glk/glk-spec-075_5.html#s.5) isn't powerful enough. But it could also be used directly by authors.

Support for these functions can be tested with `gestalt_GarglkText` (Gestalt code `0x1100`).

Resources:

 - Test file: [gargoyle-text.inf](https://github.com/curiousdannii/if/blob/master/tests/gargoyle-text.inf), [gargoyle-text.ulx](https://github.com/curiousdannii/if/blob/master/tests/gargoyle-text.ulx)

### Colours

```c
/* Function code: 0x1100 */
void garglk_set_zcolors( glui32 fg, glui32 bg );
/* Function code: 0x1101 */
void garglk_set_zcolors_stream( strid_t str, glui32 fg, glui32 bg );

#define zcolor_Default     (-1)
#define zcolor_Current     (-2)
#define zcolor_Cursor      (-3)
#define zcolor_Transparent (-4)
```

These functions set the current text foreground and background colours. Each stream has its own colours (though they will only be used for window streams). Use `garglk_set_zcolors_stream` to specify a stream, or `garglk_set_zcolors` to modify the current stream.

Colour numbers are encoded RGB values in the same way as the [`stylehint_TextColor` style hint](http://eblong.com/zarf/glk/glk-spec-075_5.html#s.5.1).

The negative colour numbers are special codes with the same meanings as those from the [Z-Machine section 8.3.7](http://inform-fiction.org/zmachine/standards/z1point1/sect08.html#three). So to change only the foreground colour or only the background colour, pass `-2` for the other parameter, which will keep the current colour unchanged.

### Reverse mode

```c
/* Function code: 0x1102 */
void garglk_set_reversevideo( glui32 reverse );
/* Function code: 0x1103 */
void garglk_set_reversevideo_stream( strid_t str, glui32 reverse );
```

These functions set the reverse mode. Pass a non-zero `reverse` parameter to enable reverse mode, and pass 0 to disable reverse mode. Use `garglk_set_reversevideo_stream` to specify a stream, or `garglk_set_reversevideo` to modify the current stream.