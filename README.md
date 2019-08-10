Bash INI File Parser
====================
This is my attempt at a Bash INI File Parser.  It's probably not elegant,
certainly not as fast as in other languages (but it did process a >3k line file
in under 1 second), but it does implement a large set of options and features.

I started work on this parser simply because I couldn't find an existing example
that wasn't just a hack, incomplete or didn't have the features I expected from
a decent parser.  I hope I've come up with something helpful for other people,
but it has scratched a personal itch and I'll be using it in my future projects.

Features of the parser include:
  * Global properties section.
  * Unlimited custom section names to contain any number of properties.
  * Section and keys can be case sensitive, or converted to upper/lower case.
  * Line comments.
  * Duplicate key handling - duplicate keys can be handled in 2 different ways.
  * Custom bound delimiter.
  * Booleans.
  * ... and more!


Using the Parser
================
The basic usage of the parser is: `/path/to/parse-ini [options] <INI file>`.
The `[options]` can be seen using `/path/to/parse-ini --help` and have detailed
descriptions.

The parser outputs Bash syntax associative array declarations, and array
element definitions to `stdout`.  These Bash commands can be `eval`ed into
a script to provide access to every element in the INI file.  For example,
using `eval "$(/path/to/parse-ini example.ini)"` in your script would define a
set of arrays whose values can be accessed in the Bash standard method, using the
keys from the INI file.

The functions from the `parse-ini` script can be included in your own scripts to
provide INI file parsing abilities without the need to call an external command.
In this usage, all that is required is a call to the `parse-ini` function within
an `eval` with the desired `[options]` and an INI file name to parse.


Using The Arrays
================
Once the parser has finished its job (assuming you ran it within an `eval`), the
arrays defined by the parse-ini script will become available to usage within
your own script.

To access the arrays depends upon the options used to call the script.
For all the examples below, assume that the `example.ini` referenced in the
command line is a simple ini file, with contents:
```
Global Key = Global Value

[ Section 1 ]
Section 1 Key = Section 1 Value
```
In this example, there is one key/value property in the 'global' section of the
INI, and a section named "section 1", which itself has 1 key/value property
associated with it.  Note the case of the key names as this is important when
the arrays are defined.

For these examples, the `parse-ini` script will be called directly so the output
of the parser can be examined - the same commands demonstrated here can be used
within an `eval` in a script.

Basic usage - no options:
```
$ /path/to/parse-ini example.ini
declare -g -A INI_global
INI_global['Global Key']='Global Value'
declare -g -A INI_Section_1
INI_Section_1['Section 1 Key']='Section 1 Value'
```
Here we can see that the parser has declared an associative array named
`INI_global` (line 1), followed by an element in that array named `Global Key`
(line 2).  It then declares a new array called `INI_Section_1` (line 3) which
has it's own element, `Section 1 Key` (line 4).

To use the arrays (once `eval`ed into your script) would be as simple as
accessing any associative array element:
```
printf "%s\\n" "${INI_global['Global Key']}"
printf "%s\\n" "${INI_Section_1['Section 1 Key']}"
```

The way to understand what array names and element names are created by the
parser it is necessary to understand the format the parser uses to construct the
array declarations (assuming no options are used at this point).  The format is:
```
<prefix><delimiter><section name>['<key name>']='<value>'
```
Where `<prefix>` is the prefix given to every array/element created by the
parser (the default is `INI`, but can be changed with `--prefix` - demonstrated
below).  `<delimiter>` is the delimiter character(s) used in every array/element
declared by the parser (the default is `_`, but can be changed with `--delim` -
example below).  `<section name>` is the name of the section taken from the
section header definition in the INI file.  `<key name>` is the name of the key
as defined in the section of the INI file.  And finally, `<value>` is the value
taken from the key/value property in the INI file.

Using options, the format of the array declarations can be changed.
Options exist to:
* Change the `<prefix>` of the arrays declared (the value may be empty),
* Change the `<delimiter>` between the `<prefix>` and `<section name>` (the
  value may be empty),
* Change the name of the implied section at the beginning of the file, known as
  the 'global' section,
* Covert the `<prefix>`, `<delimiter>` and `<section name>` to upper or
  lowercase before declaring the arrays,
* No squash multiple consecutive blanks into a single "_", as normally happens
  during processing.

Manipulating the options allows the arrays to be declared in different ways.

If, for example, you don't like the `<prefix>` used by the parser ("INI" by
default), you can change it with `--prefix` (or `-p` if you prefer short
options):
```
$ /path/to/parse-ini --prefix "Foo" example.ini
declare -g -A Foo_global
Foo_global['Global Key']='Global Value'
declare -g -A Foo_Section_1
Foo_Section_1['Section 1 Key']='Section 1 Value'
```
In this example, the prefix used is now "Foo".  Note that the prefix is mixed
case - this is important since the array names are case sensitive and will need
to be accessed using their case sensitive names (see below for options to change
the case of declared arrays).

To access this array (once `eval`ed into your script, you would use:
```
printf "%s\\n" "${Foo_global['Global Key']}"
printf "%s\\n" "${Foo_Section_1['Section 1 Key']}"
```

Equally, the `<delimiter>` can be changed either with or independently of the 
prefix:
```
$ /path/to/parse-ini --delim "X" example.ini
declare -g -A INIXglobal
INIXglobal['Global Key']='Global Value'
declare -g -A INIXSection_1
INIXSection_1['Section 1 Key']='Section 1 Value'
```
```
$ /path/to/parse-ini --prefix "Foo" --delim "X" example.ini
declare -g -A FooXglobal
FooXglobal['Global Key']='Global Value'
declare -g -A FooXSection_1
FooXSection_1['Section 1 Key']='Section 1 Value'
```
Accessed with:
```
printf "%s\\n" "${FooX_global['Global Key']}"
printf "%s\\n" "${FooX_Section_1['Section 1 Key']}"
```

We also have the option of changing the name of the 'global' section name used
when declaring the arrays:
```
$ /path/to/parse-ini --global-name "Head" example.ini
declare -g -A INI_Head
INI_Head['Global Key']='Global Value'
...
```
Again, note that the name is mixed case, and this will need to be taken into
account when accessing the array.


Say you want to access the arrays using all capitals or all lowercase names.
There's an option for that too!  Note the combination of options from above:
```
$ /path/to/parse-ini --prefix "Foo" --global-name "Head" --lowercase example.ini
declare -g -A foo_head
foo_head['Global Key']='Global Value'
declare -g -A foo_section_1
foo_section_1['Section 1 Key']='Section 1 Value'
```
Or:
```
$ /path/to/parse-ini --prefix "Foo" --global-name "Head" --uppercase example.ini
declare -g -A FOO_HEAD
FOO_HEAD['Global Key']='Global Value'
declare -g -A FOO_SECTION_1
FOO_SECTION_1['Section 1 Key']='Section 1 Value'
```
In these examples you can see that the array declarations have been made lower
and upper case accordingly.  When using the `--lowercase` or `--uppercase`
options, each of the `<prefix>`, `<delimiter>` and `<section name>` are
affected.  But the `<key name>` remains in the case from the INI file.


You can even tell `parse-ini` to not use any `<prefix>` or `<delimiter>`:
```
$ /path/to/parse-ini --prefix "" --delim "" example.ini
declare -g -A global
global['Global Key']='Global Value'
declare -g -A Section_1
Section_1['Section 1 Key']='Section 1 Value'
```
Which you would access using:
```
printf "%s\\n" "${global['Global Key']}"
printf "%s\\n" "${Section_1['Section 1 Key']}"
```
Note that there are some extra rules that come into play when leaving out the
`<prefix>` and `<delimiter>` - section names cannot begin with numbers, for
example.


Using these options allows you to access the arrays in your preferred style -
mixed case, all lowercase or all uppercase, and with any prefix or delimiter
you prefer.

Finally, the arrays may be declared as local (using the `--local` option, or as
exported to the environment (using the `--export` option).  These should need
little explanation to a bash programmer ;)


INI File Format
===============
The INI file format is a very loose format - there are many options and features
which can be supported.  I've tried to implement the widest set of features I
can, but there may be functionality missing.  Some features are only available
by enabling them as a `--option`.  See the output of `parse-ini --help` for the
options.

The main features of the supported INI file format are as follows:

General File Format
-------------------
* Blank lines are ignored and can be used to separate sections/properties for
  easy reading.
* After leading whitespace removal, lines beginning with `#` or `;` are treated
  as comments and ignored during parsing.  Comments must appear on a line on
  their own.
* Escaping of shell special characters is not required.
* Using `\`as the last character on a line allows continuation of that line
  onto a subsequent line.  Leading whitespace is removed from the continuation
  lines.  Comments are not recognised between continuation lines.
* Whitespace is ignored wherever possible.
* The first section (before the first explicit section definition) of the INI
  file is known as the "global" section, and it continues until the first
  explicit definition of a section (or until EOF).  The "global" section is
  optional.

[Section] Format
----------------
* Sections run from one section definition until the next (or EOF).
* Sections are optional.  The "global" section can be the only section used.
* Section names can only be comprised of alphanumeric characters, plus `_`, `.`,
  `-`, and `+`.
* Section names are case sensitive, unless one of the options `--lowercase` or
  `--uppercase` is used.
* The characters `.`, `-`, and `+` will be converted to `_` when defining the
  bash arrays.
* Whitespace is ignored before and after the section name.
* Section names should not be quoted in any way.
* Unless an option is used sections cannot be duplicated in different parts of
  the INI file - the properties are ignored.  With the option
  `--repeat-sections` the keys and values will be merged as long as the keys are
  unique.  If the keys are not unique, they may overwrite or append values
  (depending upon CLI options).

Keys
----
* Key names are case sensitive, unless one of the `--lowercase` or `--uppercase` 
  options is used.
* Keys can be comprised of any character.
* Keys should not be quoted in any way.
* Keys are delimited from the values by an `=`, unless the `--bound` option is
  used.
* If duplicate keys are defined in the same section, the latter definition takes
  precedence, unless the `--duplicates-merge` option is used.

Values
------
* Values are used verbatim - there is no conversion to upper or lower case.
* Values can be surrounded by quotes in order to maintain whitespace.  Quotes
  must be the first and last characters on the line (after whitespace removal).

Booleans
--------
* Keys with no value are taken as boolean options and are set on or off depending
  on how the key is defined.  Keys which do not start with a `no_` are taken as
  a boolean true and the value is set to `1`.  If the key begins with a `no_` it
  is taken as a boolean false and set to `0`.  The textual form `true` and
  `false` can be used with an option.
* Later settings of the same key override previous ones - the last one wins.


Error/Return Codes
==================
The parser will return an error code depending upon the success or failure of
processing the INI file.  The return codes are as follows:

* **0** - Successful processing of the INI file with no warnings, or the help or
  version text was displayed.
* **1** - Complete failure to process the INI file.  This could be because:
  * Incorrect version of Bash.
  * Incorrect command line options, or invalid arguments.
  * INI file does not exist, or access permission issue.
* **2** - Partial failure to process the INI file.  The parser emitted some
  errors during the processing of the INI file - a partial set of array
  definitions was written to `stdout`, while the errors were written to `stderr`.


TO-DO
=====
* Specific section parsing: only parse specified section(s) given on the command
  line (separate by commas?).  For the global section, use `.`.  For every
  section but global, use `*`.
* Allow changing the characters accepted as comments in the INI file.
* Allow the key/value deliminator to be more than one character.
