#!/bin/bash

#  bashlint.sh - script to check the syntax of other Bash scripts
#
#  Copyright (C) 2015  Dirk Stolle
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


# print Bash version to see which version is used for syntax check
bash --version
echo
echo

# find all .sh files and run them through Bash's syntax check
find ./ -name '*.sh' -print0 | xargs -0 -i bash -n {}
if [[ $? -ne 0 ]]
then
  echo "Some scripts contain syntax errors!"
  echo "You should do something about it."
  echo 'And do it "soon(TM)".'
  exit 1
else
  echo "Syntax seems to be correct."
  echo "Please take this happy smilie with you.  :)"
  exit 0
fi
