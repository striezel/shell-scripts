shell-scripts
=============


General file(s):
----------------

  readme.txt - this file

  readme.md - the same, but with markdown syntax

Script files:
-------------

  For every script there are two distinct files in the repository.
  Assume the script itself is named foo.sh, then the associated files
  are as follows:

    foo.sh          - This is the actual script, the file you are
                      looking for.

    version-foo.txt - A file containing the version information about the
                      latest version of foo.sh. You won't need this, it's
                      just here to provide information for the update
                      script. (See information below.)


  Currently three basic scripts are available in the repository:

    crusher.sh - A utility script to ease use of pngcrush for multiple
                 PNG files in a certain directory. It invokes pngcrush
                 to decrease the file size of all PNG files in a given
                 directory.

    git-author-lines.sh - A utility script to get the number of lines changed
                          by a given author in a git repository

    sql-dump-extract-db.txt - A utility script to extract the SQL statements
                              for one database from an SQL dump of multiple
                              databases

  Special purpose script:

    update.sh   - That is the update script that can be used to (you guessed
                  it) update any of the above scripts by downloading the latest
                  version of it. If you want to update foo.sh, just invoke

                    ./update.sh foo.sh

                  Purely optional, you won't need it very often, but it might
                  come in useful.

Copyright and license:
----------------------

Copyright 2013, 2014, 2015  Dirk Stolle

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see <http://www.gnu.org/licenses/>.
