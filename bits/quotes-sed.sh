{ echo "keyname1 = line without quotes"
  echo "keyname2 = line with 1 \" double quote"
  echo "keyname3 = line with \" 2 double \" quotes"
  echo "keyname4 = line \\"
  echo "with continuation \\"
  echo "at end"
  echo "keyname5 = \"double quoted text, single line\""
  echo "keyname6 = 'single quoted text, single line'"
  echo "keyname7 = \"double quoted text"
  echo "over 1"
  echo "2"
  echo "3"
  echo "4 \""; } |
  sed -re "{
  # Insert [ at beginning of key
  s/^[[:blank:]]*/['/
  # Insert ] at end of key
  s/[[:blank:]]*=/']=/
  # Branch if there's a =<quote> ...
  /^.*[^\\]=[[:blank:]]*['\"]/ {
p
      :x
    # Branch if there is no <quote> at end of line ...
    /.*['\"][[:blank:]]*\$/ ! {
      # Read new line
      N
      # Insert a \n
      s/\\\n//
      # Continue loop if s/ above was successful
      tx
    }
  }
  s/(^|$)/#/g
}"
