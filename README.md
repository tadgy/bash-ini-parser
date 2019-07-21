Bash INI File Parser
====================
This is my attempt at a Bash INI File Parser.  It's probably not elegant,
certainly not fast, but it does implement a large set of options and features.

I started work on this parser simply because I couldn't find an existing example
that wasn't just a hack, incomplete or didn't have the features I expected from
a decent parser.  I hope I've come up with something helpful for other people,
but it's scratched a personal itch and I'll be using it in my future projects.

Features of the parser include:
  * Global properties section.
  * Unlimited custom section names to contain any number of properties.
  * Section and keys can be case sensitive, or converted to upper/lower case.
  * Line comments.
  * Duplicate key handling - duplicate keys can be handled in 2 different ways.
  * Custom bound delimiter.
  * Booleans.
  * ... and more!


Usage
=====
The basic usage of the parser is: `parse_ini [options] <INI file>`.
The `[options]` can be seen using `parse_ini --help` and have detailed
descriptions.

The parser outputs Bash syntax associative array declarations, and array
element definitions to `stdout`.  These Bash commands can be `eval`ed into
a script to provide access to every element in the INI file.  For example,
using `eval "$(parse_ini test.ini)"` in your script would define a set of
arrays whose values can be accessed in the Bash standard method, using the keys
from the INI file.

The functions from the `parse_ini` script can be included in your own scripts to
provide INI file parsing abilities.


INI File Format
===============
The INI file format is a very loose format - there are many options and features
which can be supported.  I've tried to implement the widest set of features I
can, but there may be functionality missing.  Some features are only available
by enabling them as a `--option`.  See the output of `parse_ini --help` for the
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
* Sections can be duplicated in different parts of the INI file - their keys
  and values will be merged as long as the keys are unique.  If the keys are
  not unique they may overwrite or append values (depending upon CLI options).

Keys
----
* Key names are case sensitive, unless one of the `--lowercase` or `--uppercase` 
  options is used.
* Keys can be comprised of any character.
* Keys should not be quoted in any way.
* Keys are delimited from the values by an `=`, unless the `--bound` option is
  used.
* If duplicate keys are defined in the same section, the latter definition takes
  presedence, unless the `--duplicates-merge`option is used.

#........1.........2.........3.........4.........5.........6.........7.........8
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


TODO
====
* Specific section parsing: only parse specified section(s) given on the command
  line (separate by commas?).  For the global section, use `.`.  For every
  section but global, use `*`.
* Allow changing the characters accepted as comments in the INI file.
* Allow the key/value deliminator to be more than one character.
