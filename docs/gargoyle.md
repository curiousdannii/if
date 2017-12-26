---
layout: default
---

# Gargoyle Glk Extensions

[Gargoyle](https://github.com/garglk/garglk) added some internal extensions to Glk. This page formally defines those extensions so that they can be used by authors, and potentially be added to other Glk implementations.

## Text formatting

These functions allow you to control colours and reverse styling at character granularity. This is needed for fully implementing a Z-Machine interpreter in Glk, as [Glk's style system](http://eblong.com/zarf/glk/glk-spec-075_5.html#s.5) isn't powerful enough. But it could also be used directly by authors.

Support for these functions can be tested with `gestalt_garglktext` (Gestalt code `0x1100`).

### Colours

```c
/* Call selectors: 0x1100, 0x1101 */
extern void garglk_set_zcolors( glui32 fg, glui32 bg );
extern void garglk_set_zcolors_stream( strid_t str, glui32 fg, glui32 bg );
```