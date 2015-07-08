#!/bin/bash

#  crusher.sh - utility script to ease use of pngcrush for multiple PNG files
#               version: 0.7  (2015-07-09)
#               For the most up-to-date version check
#                 <https://github.com/Thoronador/shell-scripts>.
#
#  Copyright (C) 2013, 2014  Thoronador
#
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <http://www.gnu.org/licenses/>.


# exit status / error codes
E_INVALID_ARGS=1       # invalid or insufficient arguments given
E_NO_CRUSHER=2         # pngcrush not found
E_CHOWN_FAILED=3       # unable to set proper owner and group of file
E_INVALID_DIRECTORY=4  #given directory does not exist

#default value for limit
cDefaultLimit=10
declare -i cDefaultLimit

#shows help/usage message for scripts
usage_info ()
{
  echo "Usage: $(basename "$0") [options] DIRECTORY"
  echo
  echo "  options:"
  echo "    --limit <number>, -l <number>"
  echo "        Process no more than <number> PNG images."
  echo "        The default value is $cDefaultLimit."
  echo "    --help, -?, /?"
  echo "        Show this message and exit."
  echo "    --license, --licence"
  echo "        Print a short (as in 'shorter than the license') notice about"
  echo "        the script's license and exit."
  echo "    --exit-codes"
  echo "        Show a list of known exit codes of the script and exit."
}

error_codes()
{
  echo "Known exit codes of $(basename "$0"):"
  echo
  echo "    0: no error"
  echo "    $E_INVALID_ARGS: invalid or insufficient arguments"
  echo "    $E_NO_CRUSHER: pngcrush not found"
  echo "    $E_CHOWN_FAILED: unable to set proper owner and group of file"
  echo "    $E_INVALID_DIRECTORY: given directory does not exist"
}

# shows GPL3 license, if found, or short note otherwise
license_info()
{
  #gpl3=/usr/share/common-licenses/GPL-3
  #if [[ -f $gpl3 ]]
  #then
  #  less $gpl3
  #else
    echo "utility script to ease use of pngcrush for multiple PNG files"
    echo "Copyright (C) 2013, 2014  Thoronador"
    echo
    echo "This program is free software: you can redistribute it and/or modify"
    echo "it under the terms of the GNU General Public License as published by"
    echo "the Free Software Foundation, either version 3 of the License, or"
    echo "(at your option) any later version."
    echo
    echo "This program is distributed in the hope that it will be useful,"
    echo "but WITHOUT ANY WARRANTY; without even the implied warranty of"
    echo "MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the"
    echo "GNU General Public License for more details."
    echo
    echo "You should have received a copy of the GNU General Public License"
    echo "along with this program.  If not, see <http://www.gnu.org/licenses/>."
  #fi
}

# path to pngcrush binary
crusher=/usr/bin/pngcrush

# check for presence of pngcrush, before we proceed
if [[ ! -f $crusher ]]
then
  echo "$(basename "$0"): $crusher not found!"
  echo "Try to install pngcrush via apt-get install pngcrush."
  exit $E_NO_CRUSHER
fi

if [[ ! -x $crusher ]]
then
  echo "$(basename "$0"): $crusher is not executable!"
  exit $E_NO_CRUSHER
fi

#pngcrush found and executable, proceed :)

numargs=$#
declare -i numargs #declare numargs as integer

#Script needs at least one argument (the directory) to work.
if [[ $numargs -eq 0 ]]
then
  usage_info
  exit $E_INVALID_ARGS
fi

i=1
declare -i i #declare i as integer
limit=$cDefaultLimit
declare -i limit
directory=''

# loop through arguments
while [[ $i -le $numargs ]]
do
  # i-th parameter is ${!i}
  case ${!i} in
    # show license
    license|licence)
        license_info
        exit 0
    ;;
    # show help
    usage|"--help"|"-?"|"/?")
        usage_info
        exit 0
    ;;
    "--error"|"--error-codes"|"--exit-codes"|"-e")
        error_codes
        exit 0
    ;;
    "--limit"|"-l")
      #set limit
      let n=i+1
      if [[ $n -gt $numargs ]]
      then
        echo -n "$(basename "$0"): Not enough parameters! "
        echo    "You need to give a positive number after --limit!"
        exit $E_INVALID_ARGS
      fi
      limit=${!n}
      if [[ $limit -le 0 ]]
      then
        echo "Parameter after limit must be a positive, integral number!"
        exit $E_INVALID_ARGS
      fi
      i+=1 #skip one additional parameter, because next parameter was already consumed
      echo "Info: limit was set to $limit."
    ;;
    *)
      # should be directory
      if [[ -n $directory ]]
      then
        echo "Error: Directory was already set!"
        exit $E_INVALID_ARGS
      fi
      directory=${!i}
      #check if directory does not exist
      if [[ ! -d $directory ]]
      then
        echo "Error: \"$directory\" is not a directory!"
        exit $E_INVALID_DIRECTORY
      fi
      echo "Info: directory was set to \"$directory\"."
    ;;
  esac
  i+=1
done

if [[ -z $directory ]]
then
  echo "Error: Directory was not set!"
  exit $E_INVALID_ARGS
fi

#Add slash at end of directory
lastChar=${directory:(-1)}
if [[ $lastChar != "/" ]]
then
  echo "Info: adding missing trailing slash to directory path."
  directory="$directory/"
fi

#process stuff
processed=0
declare -i processed
# get list of .png files
files="$directory*.png"
suffix="_crushed"

orig_size=0
declare -i orig_size
new_size=0
declare -i new_size

echo "Crushing files. This may take a while..."
for currentFile in $files
do
  if [[ -f $currentFile ]]
  then
    if [[ $processed -lt $limit  && ! -e "$currentFile$suffix" ]]
    then
      #ready to crush
      $crusher -oldtimestamp -reduce -m 0 "$currentFile" "$currentFile$suffix" &>/dev/null
      processed+=1
      if [[ -f "$currentFile$suffix" ]]
      then
        chown --reference="$currentFile" "$currentFile$suffix" &>/dev/null
        if [[ $? != 0 ]]
        then
          echo "Could not set proper owner + group for \"$currentFile$suffix\"!"
          exit $E_CHOWN_FAILED
        fi
        orig_size+=$(stat --print="%s" "$currentFile")
        new_size+=$(stat --print="%s" "$currentFile$suffix")
        mv "$currentFile$suffix" "$currentFile"
        echo "Crushed file $currentFile"
      fi
    fi
  fi
done

# show info / size statistics
if [[ $processed -ge $limit ]]
then
  echo "Info: stopped processing, because limit ($limit) was reached."
fi
echo "Done. Processed $processed PNG files."
echo "Total size of processed files before crushing: $orig_size bytes"
echo "Total size of processed files after  crushing: $new_size bytes"
let "saved=$orig_size-$new_size"
if [[ $orig_size -ne 0 ]]
then
  let "percentage=($saved*100)/$orig_size"
else
  percentage=0
fi
echo "Saved disk space: $saved bytes ($percentage%)"
exit 0
