Version 1/120511 of Simple Unit Tests by Dannii Willis begins here.

"Very simple unit tests."

Include Text Capture by Eric Eve.

Chapter - Output capturing

To decide what indexed text is the captured output:
	let the result be an indexed text;
	stop capturing text;
	now the result is "[the captured text]";
	[ Strip whitespace at the beginning and end ]
	replace the regular expression "^\s+|\s+$" in the result with "";
	decide on the result;

Chapter - The assert phrase

The assertion count is a number variable.
The total assertion count is a number variable.
The failures count is a number variable.

To assert that/-- (A - a value) is (B - a value):
	stop capturing text;
	increment the assertion count;
	increment the total assertion count;
	unless A is B:
		increment the failures count;
		if the memory economy option is inactive and the current unit test name is not "":
			say "Failure for test: [the current unit test name], assertion: [the assertion count]. Expected: [B], Got: [A][line break]";
		otherwise:
			say "Failure. Expected: [B], Got: [A][line break]";
	start capturing text;

Chapter - The Unit test rules unindexed

The current unit test address is a number variable.
The current unit test name is an indexed text variable.

Unit test rules is a rulebook.

Running the unit tests is an action out of world.
Understand "run the unit test/tests" and "run unit test/tests" and "unit test/tests" and "unit" as running the unit tests.

[ Manually go through the unit test rules so that we can reset the assertion count for each rule, and capture text automatically. ]
Carry out running the unit tests (this is the run all unit tests rule):
	now the total assertion count is 0;
	now the failures count is 0;
	let i be a number;
	now the current unit test address is the address of unit test rule number i;
	while the current unit test address is not -1:
		[ Find the name of the rule, if we can ]
		now the current unit test name is "[the rule at address the current unit test address]";
		replace the regular expression " rule$|Unit test" in the current unit test name with "";
		now the assertion count is 0;
		[ Start capturing text so that the first assertion can use the captured output if it wants ]
		start capturing text;
		consider the rule at address the current unit test address;
		stop capturing text;
		increment i;
		now the current unit test address is the address of unit test rule number i;
	if the failures count is 0:
		say "Congratulations! ";
	say "[the failures count] of [the total assertion count] assertions failed.";

[ A couple of short phrase to loop through the unit tests ]
To decide what number is the address of unit test rule number (i - a number):
	(- (rulebooks_array-->(+ the unit test rules +) )-->{i} -).

To decide what rule is the rule at address (addr - a number):
	(- {addr} -).

Simple Unit Tests ends here.

---- DOCUMENTATION ----

This extension adds simple support for unit tests. Group tests together in rules added to the Unit test rulebook, and make individual tests with the assert phrase:

	Unit test:
		assert that 5 is 5;
		assert that "happy" is "happy";

Simple Unit Tests uses Text Capture by Eric Eve to capture any text that is said between assertions. You can use "the captured output" to have the captured text automatically stripped of whitespace at its beginning and end. If you need to capture a lot of text then you will need to increase the buffer size used by Text Capture; see that extension for details. If you want your tests to show something to the user then you will have to add "stop capturing text" phrases before doing so.

	Unit test:
		say "happy";
		assert that the captured output is "happy";

If you give the test rules names, those names will be displayed for failures (if you are not using the memory economy option):

	Unit test (this is the failing rule):
		assert that "happy" is "sad";

Produces
	Failure for test: failing, assertion: 1. Expected: sad, Got: happy
	1 of 1 assertions failed.

If you are writing an extension, we suggest you name all your test rules, and that you place your tests under a section titled:
	(not for release) (for use with Simple Unit Tests by Dannii Willis)

Lastly, run the tests by entering the command "run the unit tests" (or just simply "unit"), or use "try running the unit tests" in your code. Happy testing!

Example: * Basic Unit Tests - Passing and Failing

	*: "Basic Unit Tests"
	
	Include Simple Unit Tests by Dannii Willis.

	There is a room.
	
	Unit test (this is the passing rule):
		assert 5 is 5;
		assert {1, 2, 3} is {1, 2, 3};
		assert "happy" is "happy";
		say "hello!";
		assert the captured output is "hello!";

	Unit test (this is the failing rule):
		assert 4 is 5;
		assert {1, 2, 3} is {1, 2, 3, 4};
		assert "happy" is "sad";
		say "hello!";
		assert the captured output is "goodbye";

	When play begins:
		try running the unit tests;