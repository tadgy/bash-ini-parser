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
#........1.........2.........3.........4.........5.........6.........7.........8

General File Format
-------------------
* Blank lines are ignored and can be used to separate sections/properties for
  easy reading.
* After leading whitespace removal, lines beginning with `#` or `;` are treated
  as comments and ignored during parsing.  Comments must appear on a line on
  their own.
* Escaping of shell special characters is not required.


[section] format
----------------
* Section names must only be comprised of alphanumeric characters, plus _.-+
* The .-+ characters in section names will be converted to _
* Section names are case sensitive (unless --ignore-case? is used), so 'Foo' and 'foo' are different sections.
* Whitespace is ignored before and after the section name.
* Section names should not be quoted in any way.

Keys
----
* Keys must only be comprised of alphanumeric characters, plus _.-+
* Keys should not be quoted in any way.

Values
------
Values can optionally be bookmarked with single or double quotes.
  - If quotes are to be used, they must be the first and last characters of the value
  - Whitespace within the quotes is retained verbatim.
  - Backslash line continuation is supported within quotes (but leading whitespace on subsequent lines is removed).
Values can be continued by use of \ in the last column.
  - Subsequent lines are subject to leading whitespace removal as normal.
  - Comments are not recognised on subsequent lines - they are treated as part of the value.

Booleans
--------
* no_<option> sets it to 0/false, else 1/true.
* Later settings of the same key override previous ones - last one wins.

Quotes
------
* Quotes are not required for section names, keys or values.  However, in some cases, quotes around the value may be required; for example, when the value begins or ends with whitespace which should be retained in the value - a set of quotes (either "..." or '...') should be used around the value.
* Quotes are not required and should not be used around section names or keys.
* If the value is within quotes ("" or ''), any use of the same quote character (either " or ') must be backslash escaped.


# http://en.wikipedia.org/wiki/INI_file:
#  * Provides a good explanation of the ini format - use this for docs *
#  * INI's have 'sections' and 'properties'.  Properties have key = value format *
#
#  Case insensitivity:  Case is not changed, unless option used to covert to lower/upper case.
#  Comments:            Allow ; and # for comments.  Must be on their own line.
#  Blank lines:         Blank lines are ignored.
#  Escape chars:        \ at the end of a line will continue it onto next (leading whitespace is removed per normal)
#  Ordering:            GLOBAL section must be at the top, sections continue until next section or EOF.

#  Duplicate names:     Duplicate property values overwrite previous values.
#                       Provide an option to abort/error is duplicate is found?
#                       Add option to merge duplicates separated by octal byte (\036 ??)
#                       Duplicate sections are merged.  Option to error if dup.
#  Global properties:   Support.  Add to a GLOBAL section?
#  Hierarchy:           No hierarchy support.  Each section is own section.
#  Name/value delim:    Use = by default.  Allow : via option?
#  Quoted values:       Allow values to be within " and ' to keep literal formatting.
#  Whitespace:          Whitespace around section labels and []s is removed.
#                       Whitespace within section labels is kept / translated.
#                       Whitespace around property names is removed.
#                       Whitespace within property names is kept as is (spaces squashed - option to override).
#                       Property values have whitespace between = and data removed.
#                       Property values are kept as is (no squashing)
#  http://www.regular-expressions.info/posixbrackets.html
#  http://ajdiaz.wordpress.com/2008/02/09/bash-ini-parser/
#  https://github.com/rudimeier/bash_ini_parser/blob/ff9d46a5503bf41b3344af85447e28cbaf95350e/read_ini.sh
# http://tldp.org/LDP/abs/html/
# Specs:
#  [section]            Can be upper/lower/mixed case (set by options)
#                       Can only include: '-+_. [:alnum:]'
#                       # Any single or consecutive occurance of '-+_. ' are converted to a *single* _
#                       # eg:  [foo -+_. bar] becomes [foo_bar] ??
#                       Any leading/trailing spaces/tabs between the []s and name will be removed.


TODO
====
* Specific section parsing: only parse specified section(s) given on the command
  line (separate by commas?).  For the global section, use `.`.  For every
  section but global, use `*`.
* Allow changing the characters accepted as comments in the INI file.
* Allow the key/value deliminator to be more than one character.
