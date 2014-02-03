#!/bin/bash

# Collect arguments to pass to the script's shell, via appending to
# the shebang (which will be interpreted when we `eval` it)
shargs=()
while [[ x${1:0:1} = "x-" ]]; do
  shargs+=("$1")
  shift
done

# Get the name of the script to download and run
scriptname=$1
shift

# Get any other arguments to run the script with
initargs="$@"

# Name a local path for this script.
scriptfile="/tmp/meta.sh/$scriptname"

# Create the hierarchy to the script location
mkdir -p `dirname "$scriptfile"`

# Attempt to download the script
curl http://meta.sh/$1 > "$scriptfile"

# If we found and downloaded the script
if [[ $? -eq 0 ]]; then

  # Create a file to edit and approve this script
  editfile=`mktemp "$scriptfile.EDITXXXXXXXXXX"`
  cat > "$editfile" << EOF

# Enter a memo above this line to run the script below, or leave it
# empty to abort. Any text between these lines and the first line of
# the script (starting with "#!") will be passed on the command line
# as arguments.

EOF

  # Include any args passed on the command line
  if [[ -n $initargs ]]; then
    echo -e "$initargs\n" >> "$editfile"
  fi

  # If no hyphenated args for the shell preceded the script name
  if [[ -z $shargs ]]; then
    # Simply append the script verbatim
    cat "$scriptfile" >> "$editfile"
  # If args for the shell were provided
  else
    # Get the first line of the script
    read -r shebangline < "$scriptfile"
    # Append it with the shell arguments provided
    echo "$shebangline $shargs" >> "$editfile"
    # Append the rest of the script as normal
    tail -n+2 "$scriptfile" >> "$editfile"
  fi

  # The memo that approves the script for execution
  # Used in the name of the executed file
  memo=()

  # Any arguments to pass when evaluating the script
  evalargs=()

  # Whether we've encountered a comment, and as such are now parsing
  # arguments rather than memo components
  parseargs=""

  # A filename to output the content of the final script
  # (will be set once the shebang'd first line of the script is found)
  finalscript=""

  # Launch the editor to prompt the user to edit the script
  ${EDITOR:-nano} "$editfile"

  # For every line of the resulting file
  while read line; do

    # If we're processing the script itself
    if [[ $finalscript ]]; then
      # Pass this line directly to the output script location
      echo "$line" >> "$finalscript"

    # If no memo text has been found yet
    elif [[ -z $memo ]]; then

      # If we're encountering a comment line
      if [[ x${line:0:1} = "x#" ]]; then
        # Memo is blank
        echo "No text found before first comment, aborting."
        # Clean up the edit file
        rm "$editfile"
        # Abort
        exit

      # If this line isn't empty
      elif [[ -n $line ]]; then
        # Start saving the memo content
        memo+=($line)
      fi

    # If this line starts with a hashbang
    elif [[ x${line:0:2} = "x#!" ]]; then
      # Save the shell command to run
      shebang=${line:2}
      # Set the output filename
      finalscript="$scriptfile.run.${runname[@]}"
      # Start our output script with this first line
      echo "$line" > "$finalscript"

    # If we're encountering a comment line in memo mode
    elif [[ -z $parseargs && x${line:0:1} = "x#" ]]; then
      # Set that we're now post-comment and parsing arguments
      parseargs=1

    # If this line isn't blank or a comment
    elif [[ -n $line && x${line:0:1} != "x#" ]]; then

      # If we're in argument-gathering mode
      if [[ -n $parseargs ]]; then
        # Gather this argument
        evalargs+=($line)

      # If we're in memo mode
      else
        # Append this to the memo
        memo+=($line)
      fi
    fi
  done < "$editfile"

  # Clean up the editing file
  rm "$editfile"

  # If we found and wrote a script
  if [[ $finalscript ]]; then
    # Run it with the interpreter and arguments we found
    eval $shebang $(printf '%q' "$finalscript") ${evalargs[@]}
  # If we never hit a hashbang
  else
    # Explain why nothing is happening
    echo "No script (starting with '#!') found, aborting."
  fi

# If the script download failed
else
  # Report this failure to the user
  echo "meta.sh/$scriptname not found"
fi
