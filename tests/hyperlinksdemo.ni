"Hyperlinks demo"

Use manual line input echoing.

[ A full replacement command as a text ]

Replacement is a hyperlink tag.

Hyperlink handling rule for a replacement (this is the command replacement rule):
	suspend text input in the main window, without input echoing;
	replace current event with a line event with (hyperlink value as a text);

[ Build up commands word by words ]

Text appendment is a hyperlink tag.
The text appendment value is accessible to Inter as "text_appendment".

To say link append (T - text):
	(- TAGGED_HYPERLINK_TY_New(text_appendment, {-by-reference:T}, TEXT_TY, 1); -).

Hyperlink handling rule for text appendment (this is the text appendment rule):
	suspend text input in the main window, without input echoing;
	set the current line input of the main window to "[current line input of the main window] [hyperlink value as a text]";
	resume text input in the main window;

Object appendment is a hyperlink tag.
The object appendment value is accessible to Inter as "object_appendment".

To say link append (O - object):
	(- TAGGED_HYPERLINK_TY_New(object_appendment, {O}, OBJECT_TY, 1); -).

Hyperlink handling rule for object appendment (this is the object appendment rule):
	suspend text input in the main window, without input echoing;
	set the current line input of the main window to "[current line input of the main window] [hyperlink value as an object]";
	resume text input in the main window;

[ A simple tag for submitting a command ]

Submit is a hyperlink tag.

Hyperlink handling rule for a submit (this is the submit command rule):
	replace current event with a line event glk event;

[ Now to put it together ]

Drop command is always "drop".
Get command is always "get".
Get cat command is always "get cat".
Jump command is always "jump".
Sleep command is always "sleep".

The Lab is a room. "Here are some things you can do with hyperlinks.

Replacement text commands: [link replacement of jump command]JUMP[end link], [link replacement of sleep command]SLEEP[end link], [link replacement of get cat command]GET CAT[end link]

Verbs: [link append get command]GET[end link], [link append drop command]DROP[end link]

Nouns: [link append cat][a cat][end link], [link append book][a book][end link], [link append mobile phone][a mobile phone][end link]

[link submit]Submit command[end link]"

In the lab is a cat, a book, and a mobile phone.