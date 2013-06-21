#!/bin/bash

#  git-author-lines.sh - utility script to get the number of lines changed by
#                        a given author in a git repository
#                        version: 0.1  (2013-06-22)
#                        For the most up-to-date version check
#                        <https://github.com/Thoronador/shell-scripts>.
#
#  Copyright (C) 2013  Thoronador
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
E_INVALID_ARGS=1   # invalid or insufficient arguments given
E_NO_GIT=2         # git not found
E_NO_REPOSITORY=3 #not a git repository

#shows help/usage message for scripts
usage_info ()
{
  echo "Usage: `basename $0` [options] AUTHOR"
  echo
  echo "  options:"
  echo "    --help, -?, /?"
  echo "        Show this message"
  echo "    --license, --licence"
  echo "        Print a short (as in 'shorter than the license') notice about"
  echo "        the script's license."
  echo
  echo "    AUTHOR"
  echo "        name of the author whose commits shall be counted"
}

error_codes()
{
  echo "Known exit codes of `basename $0`:"
  echo
  echo "    0: no error"
  echo "    $E_INVALID_ARGS: invalid or insufficient arguments"
  echo "    $E_NO_GIT: git not found"
  echo "    $E_NO_REPOSITORY: directory is not a git repository"
}

# shows short license note
license_info()
{
  echo "utility script to get the number of lines changed by a given author"
  echo " in a git repository"
  echo "Copyright (C) 2013  Thoronador"
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
}

# path to git binary
git=/usr/bin/git

# check for presence of git, before we proceed
if [[ ! -f $git ]]
then
  echo "`basename $0`: git not found!"
  echo "Try to install git via apt-get install git."
  exit $E_NO_GIT
fi

if [[ ! -x $git ]]
then
  echo "`basename $0`: $git is not executable!"
  exit $E_NO_GIT
fi

numargs=$#
declare -i numargs #declare numargs as integer

#Script needs at least one argument (the author) to work.
if [[ numargs -eq 0 ]]
then
  usage_info
  exit $E_INVALID_ARGS
fi


author=''

i=1
declare -i i #declare i as integer

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
    *)
      # should be author name
      if [[ -n $author ]]
      then
        echo "Error: Author was already set!"
        exit $E_INVALID_ARGS
      fi
      author=${!i}
      echo "Info: author was set to \"$author\"."
    ;;
  esac
  i+=1
done

if [[ -z $author ]]
then
  echo "Error: Author was not set!"
  exit $E_INVALID_ARGS
fi

$git log -1 &>/dev/null
ret=$?
if [[ $ret -ne 0 ]]
then
  echo "This directory does not seem to be a git repository!"
  exit $E_NO_REPOSITORY
fi

added=`$git log --oneline --pretty=tformat: --numstat --author="$author" | awk ' { print $1 } '`
added_lines=0
declare -i added_lines #declare added_lines as integer
for count in $added
do
  # Changes in binary files do not produce a number but just a dash.
  # We can't add them the normal way, so filter them out.
  if [[ $count != "-" ]]
  then
    added_lines+=count
  fi
done

removed=`$git log --oneline --pretty=tformat: --numstat --author="$author" | awk ' { print $2 } '`
removed_lines=0
declare -i removed_lines #declare removed_lines as integer
for count in $removed
do
  # Changes in binary files do not produce a number but just a dash.
  # We can't add them the normal way, so filter them out.
  if [[ $count != "-" ]]
  then
    removed_lines+=count
  fi
done

echo "Line count statistics for \"$author\":"
echo "  added lines: $added_lines, removed lines: $removed_lines"
removed_lines+=added_lines
echo "  total: $removed_lines line(s) changed"
exit 0
