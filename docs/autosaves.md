---
layout: default
---

# Versioned autosaves

Some IF interpreters support autosaves, but each one does it a little differently, and their handling of old autosaves is a bit brittle. This is a proposal for handling all autosaves in a consistent single file format, with version information.

## Autosave file format

An autosave has to store data from several sources, typically including a snapshot of the interpreter's memory, other interpreter state, as well as data from Glk and GlkOte. Quixe stores this data in two files, as the memory snapshot can be stored as binary data, while the rest is typically text (JSON). Some interpreters would want to store more than just the memory snapshot as binary data, while having two keep two or more files in sync is a low-level risk. Single files would be simpler (at the cost of some interior complexity.)

As is common in the IF world, it is proposed that we store autosaves as an [IFF](https://en.wikipedia.org/wiki/Interchange_File_Format) file. The FORM type would be `IFAS`.

The one essential chunk of an autosave is the versions chunk (id: `Vers`.) This chunk stores the version information of each layer involved in an autosave, as JSON. For example:

```json
{
    "git": 1,
    "remglk-rs": 2,
    "asyncglkote": 1
}
```

These versions indicate that the VM is Git, the Glk library is RemGlk-rs, and the GlkOte library is AsyncGlk's GlkOte. Layer names must be ASCII.

The version numbers do not refer to the versions of the components, but instead the version of each component's autosave data. If an autosave can be maintained in a backwards compatible manner then it should be kept at version 1; higher version numbers are only to be used when a component needs to add something to its autosaves that mean it cannot load older autosaves. In this example RemGlk-rs is at version 2, indicating that something major in its autosave data was changed, perhaps for example the way it stores open streams.

Components are free to add whatever other chunks they need. They could put all their data in one chunk, or in multiple chunks if that is simpler. Chunks IDs need to be unique, so we will keep a registry here of known chunk IDs. But the main thing will be for different layers not to use the same chunk IDs, so we could use prefixes like `VM**`, `Gl**` and `GO**`.

The filename of an autosave should be based on some unique data extracted from the storyfile, typically from its header, and often including a checksum. The file extension of an autosave is `.asv`.

## Loading an autosave

Zarf originally wrote about [the process of loading and writing autosaves](https://www.eblong.com/zarf/glk/terp-saving-notes.html). This proposal alters the process, as each layer needs more control.

The first step is that the VM tells the autosave library its name, current version, and lowest supported version. Versions must be positive integers (not `0`).

```c
void autosave_set_vm(const char* name, glui32 current_version, glui32 lowest_version);
```

It is the VM's responsibility to locate and open the autosave file into a readable binary byte stream. Then give the stream to `autosave_load`. If the versions in the autosave are compatible with the Glk library and what the VM provided, then it will set the `version` and `autosave` out parameters, to the actual VM version number of this autosave and an opaque identifier for this autosave. (If there is any issue reading the autosave then they will be set to `0`.) Before returning the Glk library loads its own data from the autosave, so the VM cannot later decide that the autosave is invalid. This is why it is important to use reliable version numbers for each layer.

```c
void autosave_load(strid_t str, glui32 *version, autosave_t *autosave);
```

The VM can find its chunks using `autosave_find_chunk`. If a chunk exists then the `addr` and `len` out parameters will be set, otherwise `addr` will be `0`. The `addr` is a position within the original stream for the beginning of the chunk's content, which can be read with `glk_get_buffer_stream`.

```c
void autosave_find_chunk(autosave_t autosave, glui32 id, glui32 *addr, glui32 *len);
```

Once the VM has finished reading its chunks it calls `autosave_destroy` and then can close the stream.

```c
void autosave_destroy(autosave_t autosave);
```

## Writing an autosave

To write an autosave first open a writable binary byte stream. Then call `autosave_write_begin`, which will write the file header, the `Vers` chunk, and any Glk (and GlkOte) chunks.

```c
void autosave_write_begin(strid_t str);
```

You can then write chunks using `autosave_write_chunk`, or you can write directly to the stream (if for example you had a FORM chunk you wanted to write in full), but you would need to be careful that you are creating valid IFF chunks. Don't forget the padding bytes!

```c
void autosave_write_chunk(strid_t str, glui32 id, const char *buf, glui32 len);
```

When the VM has finished writing all its chunks, call `autosave_write_finalise`, and then you can close the stream.

```c
void autosave_write_finalise(strid_t str);
```

## Questions

1. Should there be a single way of naming autosave files that doesn't depend on the storyfile format? For example, we could do a md5 of the first 128(?) bytes of the storyfile. This would assist multi-interpreters locate an autosave. Alternatively, seeing as multi-interpreters already need to have a system for detecting storyfile formats, that system could also include how to name an autosave.
1. How should remote GlkOte's autosave data be obtained? Instead of having a function (which for remote GlkOte would need its own HTTP request), should we just send the autosave data in a normal GlkOte output? It won't typically be very much, just graphics window background colours (why?), window line input history, and transcript recorder session.
1. Likewise for restoring, how should it work with remote GlkOte? Maybe there should be a little local GlkOte layer on the server (as part of the Glk library) which handles checking the version, and loading its autosave data.
1. How to handle embedded FORM chunks? I think the Blorb functions return the content of most chunks, aside from FORM chunks which they return in full? It's quirky, but probably makes sense to copy this behaviour.
1. Should Zarf's original hook functions be changed at all? Is the VM storing Glk state, or its own state? (What does "Push the glk_select() argument onto the stack. (This is available as an argument of the select hook function.)" mean?)