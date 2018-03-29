---
layout: default
---

# Out-of-band messaging

These functions add support for out-of-band logging and error messaging. If provided by the Glk library, they give a way of sending messages outside the normal Glk window display system. They can be safely called before any windows have been created, on platforms which only allow one window to be created, and they should be highly efficient and not depend on receiving a response from the client in a server-client network setup.

Support for these functions can be tested with `gestalt_OutOfBand` (Gestalt code `TBA`). You can also make a preprocessor test for `GLK_MODULE_OUTOFBAND`.

## Message severity levels

```c
#define severity_Log (0)
#define severity_Warning (1)
#define severity_Error (2)
```

Three severity levels are supported.

`severity_Log` is used for informational logging. It will usually be displayed to the user in a secondary window, or in minimal Glk libraries it may not be accessible at all.

`severity_Warning` is used for serious but non-fatal warnings which should be shown to the user. Some Glk libraries may only support showing one warning at a time, with subsequent calls replacing earlier messages. Warnings can be cancelled and hidden.

`severity_Error` is used for fatal errors. Sending an error message will not by itself stop the VM nor does it replace calling `glk_exit`. Sending an error message may hide any previous warning messages.

## Functions

```c
/* Function code: TBA */
void glk_outofband( glui32 severity, char *s );
/* Function code: TBA */
void glk_outofband_uni( glui32 severity, glui32 *s );
```

These functions send a string message of the specified severity.

```c
/* Function code: TBA */
void glk_stream_open_outofband( glui32 severity );
/* Function code: TBA */
void glk_stream_open_outofband_uni( glui32 severity );
```

These functions open an out-of-band stream of the specified severity, allowing you to send dynamic messages. The stream can be written to with all of the regular printing functions. The message is sent once you call `glk_stream_close`.

```c
/* Function code: TBA */
void glk_cancel_outofband_warning( void );
```

Cancels any current warning messages. Glk libraries do not have to support this, but this function can be safely called at all times regardless.