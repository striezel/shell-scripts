shell-scripts
=============


General file(s):
----------------

  readme.txt - this file

Script files:
-------------

  For every script there are three distinct files in the repository.
  Assume the script itself is named foo.sh, then the associated files
  are as follows:

    foo.sh          - This is the actual script, the file you are
                      looking for.

    update-foo.sh   - That is the update script that can be used to (you
                      guessed it) update foo.sh by downloading the latest
                      version of foo.sh. Optional, you won't need it very
                      often, but it might come in useful.

    version-foo.txt - A file containing the version information about the
                      latest version of foo.sh. You won't need this, it's
                      just here to provide information for the update
                      script.


   Currently only one basic script is available in the repository:

     crusher.sh - A utility script to ease use of pngcrush for multiple
                  PNG files in a certain directory. It invokes pngcrush
                  to decrease the file size of all PNG files in a given
                  directory.

     git-author-lines.sh - A utility script to get the number of lines changed
                           by a given author in a git repository
