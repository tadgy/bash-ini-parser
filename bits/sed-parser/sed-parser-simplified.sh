#!/bin/bash

# Notes:
#  Cannot use any of the deliminators in the key name
# Todo:
#  Lines beginning with #; within " .. " blocks on new lines will be stripped.
#  Allow merging of multiple sections with the same name
#  Change case of variables:  \L \U \E
#  export SECLIST="SECTIONS"
#  Allow delims to be specified in a var - don't assume =:

export VARPREFIX="INI_"
export SECPREFIX="SECTION_"
export SECCNAMEKEY="%cannonical name%"
export TOPSEC="global"
initest() {
  echo "declare -A ${VARPREFIX}${SECPREFIX}${TOPSEC}=("
  echo "[${SECCNAMEKEY}]=\"${TOPSEC}\""
  cat $1 | sed -r "{
    # Ignore blank lines and comments
    /^[[:blank:]]*(#|;|$)/ d
    # Handle [section] lines
    /^[[:blank:]]*\[.*\][[:blank:]]*$/ {
      i )
      s/(^[[:blank:]]*\[[[:blank:]]*|[[:blank:]]*\][[:blank:]]*$)//g
      h
      s/([[:blank:]]+|[^[:alnum:]])/_/g
      s/(.*)/declare -A ${VARPREFIX}${SECPREFIX}\1=(/p
      g
      s/(.*)/  \[${SECCNAMEKEY}\]=\"\1\"/
      b
    }
# FIXME: This needs to pick up escaped =:s
    /^([[:blank:]]*[^[:blank:]]+[[:blank:]]*)+[=:].*$/ {
      # Escape any ] characters within key name - bash <4.3 can't handle them
      s/^(([^\]]*)\[+)*([=:].*)$/\2\\\\\]\3/
      # Escape any ' characters within the key name
      s/^[[:blank:]]*/  \[\'/
      s/[[:blank:]]*[=:][[:blank:]]*(.*)$/\']=\1/
########s/([\"]+)/\\\\\1/g
#s/^(\[')([']+)('\].*)/\1X\3/g
#      s/[[:blank:]]*[=:][[:blank:]]*[\"\'\`]?(.*)$/\]=\'\1/
#      s/^[[:blank:]]*([[:print:]]+)[[:blank:]]*[=:][[:blank:]]*/\[\1\]=/
      b
    }
    q
  }"
  echo ")"
}

; initest

# Join lines ending in \ :
sed ':x; /\\$/ { N; s/\\\n//; tx }' textfile

echo 'ao ao ao | ao' | sed 'h; s/.*|/|/; x; s/|.*//; s/o/x/g; G; s/\n//'


 # if a line ends with a backslash, append the next line to it
 sed -e :a -e '/\\$/N; s/\\\n//; ta'


# 4.0 needs the backslash escaped AND the ] when referencing the element
06:09 <Tadgy> 40# declare -A FOOF=( ['test\]test']="test" ) ; declare -p FOOF ; printf "<%s>" "${FOOF['test\]test']}"
06:09 <shbot> declare -A FOOF='([test\\\]test]="test" )'
06:09 <shbot> <>
06:11 <Tadgy> 40# declare -A FOOF=( ['test\]test']="test" ) ; declare -p FOOF ; printf "<%s>" "${FOOF['test\\\]test']}"
06:11 <shbot> declare -A FOOF='([test\\\]test]="test" )'
06:11 <shbot> <test>

# 4.1, 4.2, 4.3 are consistent with this syntax
06:06 <Tadgy> 41# declare -A FOOF=( ['test\]test']="test" ) ; declare -p FOOF ; printf "<%s>" "${FOOF['test\]test']}"
06:06 <shbot> declare -A FOOF='(["test\\]test"]="test" )'
06:06 <shbot> <test>
06:08 <Tadgy> 42# declare -A FOOF=( ['test\]test']="test" ) ; declare -p FOOF ; printf "<%s>" "${FOOF['test\]test']}"
06:08 <shbot> declare -A FOOF='(["test\\]test"]="test" )'
06:08 <shbot> <test>
06:09 <Tadgy> 43# declare -A FOOF=( ['test\]test']="test" ) ; declare -p FOOF ; printf "<%s>" "${FOOF['test\]test']}"
06:09 <shbot> declare -A FOOF='(["test\\]test"]="test" )'
06:09 <shbot> <test>
#Works without escapes in 4.3:
06:08 <Tadgy> 43# declare -A FOOF=( ['test]test']="test" ) ; declare -p FOOF ; printf "<%s>" "${FOOF['test]test']}"
06:08 <shbot> declare -A FOOF='(["test]test"]="test" )'
06:08 <shbot> <test>



       [       [        invalid-section###3   ] $$    ]                    $
[        invalid-section###3   ] $$X
# Squash multiple blanks and invalid chars to single _ --  s/[^[:alnum:]]+/_/g
_invalid_section_3_
# Blanks and invalid chars replaced with _ no sqash --  s/[^[:alnum:]]/_/g
_________invalid_section___3_______
# Squash multiple blanks to single _ and replace invalid chars with _ --  s/([[:blank:]]+|[^[:alnum:]])/_/g
__invalid_section___3_____


#s/[[:blank:]]*\][[:blank:]]*[^[:alnum:]]+/_/g
#    s/^[[:blank:]]*\[[[:blank:]]*/declare -A ${VAR}_/
#    s/[[:blank:]]*\][[:blank:]]*$/=(/

#    s/(^[[:blank:]]*\[[[:blank:]]*)|([[:blank:]]*\][[:blank:]]*$)/X/g
#    s/[[:blank:]]+/ /g
#    s/^[[:blank:]]*\[[[:blank:]]*([[:graph:]]*)[[:blank:]]*\][[:blank:]]*$/[\1]/
l 120
#    s/^[[:blank:]]*(\[|\]) [[:blank:]]*$/\1/g
#    s/([^[:alnum:]]|_+)/_/g
  }
}"

    s/[[:blank:]]*(\[|\])[[:blank:]]*/\1/g
    s/([^[:alnum:]]|_+)/_/g


label regex jump back if s was done


#    s/\[_*([^]]*)/declare -A ${VAR}_\1=(/
#    s/\[_*(.*)_*\].*/declare -A ${VAR}_\1=(/
#    s/[[:blank:]]*\[(.*)\].*/declare -A ${VAR}_\1=(/
  }
#  /^(\)|declare -A)/ ! {
#    s/^[[:blank:]]*/\[/
#    s/[[:blank:]]*=[[:blank:]]*/\]=\"/
#    s/$/\"/g
#  }
}"


# Variables:
#  INI_ENV_PREFIX="INI_"
#  INI_GLOBAL_??="GLOBAL"
#  INI_SECTION_??="SECTION"
# Options:
#  

exit

  /^[[:blank:]]*\[.*\]/ {
    s/[[:blank:]]*\[/)\n/g
    # s/(.*)\]/declare -A ${VAR}_\1=(/g
  }



  -e "/^[[:blank:]]*\[.*\]/ s/[[:blank:]]*\[/)\n/g; s/(.*)\]/declare -A ${VAR}_\1=(/g"

  -e 's/^[[:blank:]]*\</[


sed -r \
  -e '/^[[:blank:]]*(#|;|$)/ d' \
  -e "1 ideclare -A ${VAR}_${TOP}=(" \
  -e "/^[[:blank:]]*\[.*\]/ s/[[:blank:]]*\[/)\n/g; s/(.*)\]/declare -A ${VAR}_\1=(/g"

  -e 's/^[[:blank:]]*\</[



  -e "1 s/^/declare -A ${VAR}_${TOP}=(\n/" \

 # if a line ends with a backslash, append the next line to it
 sed -e :a -e '/\\$/N; s/\\\n//; ta'

 # print the line immediately before a regexp, but not the line
 # containing the regexp
 sed -n '/regexp/{g;1!p;};h'

 # print the line immediately after a regexp, but not the line
 # containing the regexp
 sed -n '/regexp/{n;p;}'

 # print section of file from regular expression to end of file
 sed -n '/regexp/,$p'

 # print section of file between two regular expressions (inclusive)
 sed -n '/Iowa/,/Montana/p'             # case sensitive


# Option (-r) to make all variables read only.
# Option (-x) to export all variables.

# Option parsing.
# http://mywiki.wooledge.org/BashFAQ/035

