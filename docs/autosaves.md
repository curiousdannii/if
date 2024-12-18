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
    "webglkote": 1
}
```

These versions indicate that the VM is Git, the Glk library is RemGlk-rs, and the GlkOte library is WebGlkOte.

The version numbers do not refer to the versions of the components, but instead the version of each component's autosave data. If an autosave can be maintained in a backwards compatible manner then it should be kept at version 1; higher version numbers are only to be used when a component needs to add something to its autosaves that mean it cannot load older autosaves. In this example RemGlk-rs is at version 2, indicating that something major in its autosave data was changed, perhaps for example the way it stores open streams.

Components are free to add whatever other chunks they need. They could put all their data in one chunk, or in multiple chunks if that is simpler. Except that chunks probably need to be unique. We will keep a registry here of known chunk IDs. But the main thing will be for different layers not to use the same chunks, so we could use prefixes like `VM**`, `Gl**` and `GO**`.

The filename of an autosave should be based on some unique data extracted from the storyfile, typically from its header, and often including a checksum. The file extension of an autosave is `.asv`.

## Loading an autosave

Zarf originally wrote about [the process of loading and writing autosaves](https://www.eblong.com/zarf/glk/terp-saving-notes.html). This proposal requires the process to be changed, as each layer needs more control over it.

- Multi-interpreters might inspect an autosave in order to determine which VM to use (ex, Glulxe vs Git)
- The main VM checks if there is an autosave
- VM checks if it is the right VM and that its version is compatible
- Hands over to the Glk library
  - Glk checks that it is the right library and that its version is compatible
  - (If applicable) Hands over to GlkOte library
    - GlkOte checks that it is the right library and that its version is compatible
    - Loads its data and returns success
  - If GlkOte succeeded, then Glk loads its data and returns success, otherwise returns fail
- If Glk succeeded, then the VM loads its data

When saving, each layer would have to be called, to add its data into the autosave file.

## Questions

1. Probably there should be a C/JS API for reading/writing autosave chunks, so what should it look like?
1. Should there be a single way of naming autosave files that doesn't depend on the storyfile format? For example, we could do a md5 of the first 128(?) bytes of the storyfile. This would assist multi-interpreters locate an autosave. Alternatively, seeing as multi-interpreters already need to have a system for detecting storyfile formats, that system could also include how to name an autosave.
1. How should remote GlkOte's autosave data be obtained? Instead of having a function (which for remote GlkOte would need its own HTTP request), should we just send the autosave data in a normal GlkOte output? It won't typically be very much, just graphics window background colours (why?), window line input history, and transcript recorder session.
1. Likewise for restoring, how should it work with remote GlkOte? Maybe there should be a little local GlkOte layer on the server (as part of the Glk library) which handles checking the version, and loading its autosave data.