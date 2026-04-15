---
layout: default
---

# Miscellaneous Glk Extensions

## Additional styles

[Forum discussion](https://intfiction.org/t/glk-extension-proposals-extra-styles-and-open-url/79698)

Glk is limited to 11 styles, but there is little technical reason for this. This extension raises that number to 255. Additional styles are referred to with their number, so style 11 is `style_User11` (or `Style_user11` in GlkOte), not `style_User3`.

Support for additional styles can be tested with `gestalt_ExtraStyles` (Gestalt code `0x1102`). You can also make a preprocessor test for `GLK_MODULE_EXTRA_STYLES`.

Affected functions: `glk_set_style`, `glk_set_style_stream`, `glk_style_distinguish`, `glk_style_measure`, `glk_stylehint_clear`, `glk_stylehint_set`.

## Stylehints gestalt selector

To check whether stylehints are supported you can test the gestalt selector `gestalt_Stylehints` (code `0x1101`.) As the stylehints functions are always present this should only return true if the interpreter actually applies stylehints.