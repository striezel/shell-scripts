#!/bin/bash

#  update-check-no-op.sh - script to check the update mechanism of update.sh
#                          -> variant with no required update operations
#
#  Copyright (C) 2015  Thoronador
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
./update.sh crusher.sh > "$TMP_FILE"
LINES=$(grep --fixed-strings "You already have the latest version" "$TMP_FILE" | wc -l)
if [[ $LINES -ne 1 ]]
then
  echo "The no-op update for crusher.sh failed!"
  unlink "$TMP_FILE"
  exit 1
fi
echo "Info: No-op update for crusher.sh succeeded."

# check update of git-author-lines.sh
./update.sh git-author-lines.sh > "$TMP_FILE"
LINES=$(grep --fixed-strings "You already have the latest version" "$TMP_FILE" | wc -l)
if [[ $LINES -ne 1 ]]
then
  echo "The no-op update for git-author-lines.sh failed!"
  unlink "$TMP_FILE"
  exit 1
fi
echo "Info: No-op update for git-author-lines.sh succeeded."

# check update of sql-dump-extract-db.sh
./update.sh sql-dump-extract-db.sh > "$TMP_FILE"
LINES=$(grep --fixed-strings "You already have the latest version" "$TMP_FILE" | wc -l)
if [[ $LINES -ne 1 ]]
then
  echo "The no-op update for sql-dump-extract-db.sh failed!"
  unlink "$TMP_FILE"
  exit 1
fi
echo "Info: No-op update for sql-dump-extract-db.sh succeeded."

# clean up
unlink "$TMP_FILE"
# all done and succeded here
exit 0
