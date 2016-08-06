#!/bin/bash

#  update-check-forced-update.sh - script to check the update mechanism of
#                                  update.sh for outdated scripts
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


TMP_FILE=$(mktemp --tmpdir updatecheck.XXXXXX)
# check update of crusher.sh
echo "This should not be here." >> crusher.sh
./update.sh crusher.sh > "$TMP_FILE"
LINES=$(grep -c --fixed-strings "Copying latest version of" "$TMP_FILE")
if [[ $LINES -ne 1 ]]
then
  echo "The forced update for crusher.sh failed!"
  unlink "$TMP_FILE"
  exit 1
fi
echo "Info: The update for crusher.sh succeeded."

# check update of git-author-lines.sh
echo "This should not be here." >> git-author-lines.sh
./update.sh git-author-lines.sh > "$TMP_FILE"
LINES=$(grep -c --fixed-strings "Copying latest version of" "$TMP_FILE")
if [[ $LINES -ne 1 ]]
then
  echo "The forced update for git-author-lines.sh failed!"
  unlink "$TMP_FILE"
  exit 1
fi
echo "Info: The update for git-author-lines.sh succeeded."

# check update of sql-dump-extract-db.sh
echo "This should not be here." >> sql-dump-extract-db.sh
./update.sh sql-dump-extract-db.sh > "$TMP_FILE"
LINES=$(grep -c --fixed-strings "Copying latest version of" "$TMP_FILE")
if [[ $LINES -ne 1 ]]
then
  echo "The forced update for sql-dump-extract-db.sh failed!"
  unlink "$TMP_FILE"
  exit 1
fi
echo "Info: The update for sql-dump-extract-db.sh succeeded."

# clean up
unlink "$TMP_FILE"
# all done and succeded here
echo "Smile. :)"
exit 0
