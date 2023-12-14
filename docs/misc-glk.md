---
layout: default
---

# Miscellaneous Glk Extensions

## Stylehints gestalt selector

To check whether stylehints are supported you can test the gestalt selector `gestalt_Stylehints` (code `0x1101`.) As the stylehints functions are always present this should only return true if the interpreter actually applies stylehints.