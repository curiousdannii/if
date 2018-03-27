---
layout: default
---

# The Z-Machine Standard 1.2 (draft)

## 1. Introduction

### 1.1 Rationale

This is a draft proposal for a new standard extension of the Z-Machine. The Z-Machine was first formalised by [Graham Nelson, et al. in 1997](http://inform-fiction.org/zmachine/standards/z1point0/index.html). Several attempts were later made to extend the Z-Machine, which were eventually refined down into the [1.1 Standard](http://inform-fiction.org/zmachine/standards/z1point1/index.html).

However, effectively the only Z-Machine extension to ever gain traction was the introduction of the unicode opcodes in the 1.0 standard. The 1.1 standard has rarely been fully implemented, possibly in part because there is no way to detect the new opcodes other than by checking whether the interpreter set the standard revision header to signify 1.1, which it shouldn't do unless it fully implements the standard. There is no way to partially implement the standard.

This proposal is an attempt to rectify this situation. A new `@gestalt` testing opcode will be added, following the syntax of [Glulx's cognate opcode](http://eblong.com/zarf/glulx/glulx-spec_2.html#s.18). This will allow story files to test for interpreter support of new features and opcodes before using them, with the possibility of using alternative code if they are not.

That is the only change which this standard directly makes, although an official registry of selectors and the additions they test for is listed below. Some of the selectors may be used to identify which of several conflicting interpretations of the previous standards has been implemented in an interpreter, but they do not require that one interpretation be implemented over another.

### 1.2 Compliance

An implementation of this standard will set the standard revision header (address `$32`) to `$0102`. It will add the `@gestalt` opcode, as detailed below, and will support the core selectors, as listed in the selector registry.

To comply with this standard an implementation must also comply with the [1.1 standard](http://inform-fiction.org/zmachine/standards/z1point1/index.html), as they are written at the time of the publication of this standard. If you ignore the Z-Machine version 6 then the changes required by the 1.1 standard are quite limited and extending a 1.0 interpreter to both 1.1 and 1.2 should not be a large task. As noted above, there are unfortunately some areas of the previous standards which have been interpreted differently by implementation writers. Because of that some selectors may be used to identify which interpretation has been implemented in the interpreter.

Praxix is a Z-Machine unit test which includes tests for this standard. Implementors should check that their implementation passes all the tests it performs.

 - [praxix.inf](https://github.com/curiousdannii/if/blob/master/tests/praxix.inf), [praxix.z5](https://github.com/curiousdannii/if/blob/master/tests/praxix.z5)

## 2. @gestalt

The `@gestalt` opcode has the following specification:

```
@"EXT:30S" id arg -> (result);
```

This will test for the selector `id`, with the optional argument `arg`, storing the result in the variable specified. If a certain selector does not need the optional argument, set it to `0`.

If a selector is set which the interpreter doesn't recognise, then `0` will be stored. What a selector will do with an argument it doesn't recognise is up to that selector; see the registry for details.

Before using the opcode, ensure that you are using an 1.2 standard interpreter by checking whether the standard revision header (address `$32`) is `$0102` or higher.

## 3. Selector Registry

The following is an official list of selectors and their associated opcodes. Extensions will generally be specified elsewhere (and only a short description given below) although a few from existing interpreters have also been documented. If you would like to reserve a selector or opcode for your own extensions, please contact [Dannii Willis](mailto:curiousdannii@gmail.com).

| Extension title | Selector ID | Associated opcodes, streams | Description |
| --------------- | ----------- | --------------------------- | ----------- |
| Standard version | `$01` | - | **Core**: stores the Z-Machine standard which this interpreter supports. Will be `$0102` or higher. |
| Transcripts Protocol | `$10` | - | Reserved for a proposal for transcript extensions. |
| Parchment | `$20` | EXT:31 | Reserved for extensions for use in Parchment. |
| eval() stream | `$30` | Stream: 5 | Supports the eval() stream. It behaves like the memory stream, except that when it is turned off its contents will be run through the Javascript function eval(), and what that returns will be written back to memory. If they are both enabled then the memory stream takes priority. |
| Vorple | `$31` | Stream: 6 | A stream reserved for [Vorple](http://vorple-if.com). |
| Zoom profiling | `$1000` | EXT:128-131 | Provides opcodes for accessing the system timer. For more details see [Zoom's README](http://www.logicalshift.co.uk/unix/zoom/). |
| Zoom stack dump | `$1001` | EXT:132 | Prints out a stack dump. For more details see Zoom's implementation (src/zmachine.c: `zmachine_dump_stack()`). |
| @set_font 0 | `$2000` | EXT:4 | **Core**: clarification for `@set_font 0`. Set to which of the following is implemented:<ol><li>not supported</li><li>no change, and return the current font</li><li>change to the second last font, and return it</li></ol> |
| Streams 3/4 | `$2001` | - | **Core**: clarification for when streams 3 and 4 are supported. Set to which of the following is implemented:<ol><li>V3 and higher</li><li>V5 and higher</li></ol> |
| @call_vs2 | `$2002` | VAR:224 | **Core**: clarification for how many arguments are allowed in V4 for `@call_vs2`. Set to which of the following is implemented:<ol><li>0-3</li><li>0-7</li></ol> |
| Private use | `$F000-$FFFF` | EXT:133-255 | Selectors in this range will never be specified, and are free for use in custom interpreters. As in previous standards, opcodes EXT:133-255 are available for custom interpreters, and you may use one of these selectors to test whether the story file is being run in your interpreter (pick one at random). Please consider though whether there might be value in standardising your extension for others to use. |