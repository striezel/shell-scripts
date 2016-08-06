#!/bin/bash

#  sql-dump-extract-db.sh - utility script to extract the SQL statements
#                           for one database from an SQL dump of multiple
#                           databases
#                           version: 0.3.1  (2016-08-06)
#                           For the most up-to-date version check
#                             <https://github.com/striezel/shell-scripts>.
#
#  Copyright (C) 2014, 2015  Dirk Stolle
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
E_INVALID_ARGS=1         # invalid or insufficient arguments given
E_NO_SOURCE=2            # no source dump found
E_SOURCE_NOT_READABLE=3  # source dump cannot be read
E_DEST_EXISTS=4          # destination file aready exists
E_SED_FAILED=5           # sed returned a non-zero exit code
E_NO_DATA=6              # script could not find any data for the given DB


#shows help/usage message for scripts
usage_info ()
{
  echo "Usage: $(basename "$0") [options] DB_NAME SOURCE_DUMP OUTPUT_DUMP"
  echo
  echo "  options:"
  echo "    --help, -?, /?"
  echo "        Show this message and exit"
  echo "    --license, --licence"
  echo "        Print a short (as in 'shorter than the license') notice about"
  echo "        the script's license and exit."
  echo "    --exit-codes"
  echo "        Show a list of known exit codes of the script and exit."
  echo
  echo "  DB_NAME"
  echo "      name of the database that shall be extracted from the dump"
  echo "  SOURCE_DUMP"
  echo "      name of the (longer) SQL dump to extract from"
  echo "  OUTPUT_DUMP"
  echo "      name of the destination file that will hold all extracted statements"
  echo "      (will be created by the script)"
  echo
  echo "  Example:"
  echo "    $(basename "$0") db_foo long_dump.sql db_foo_only.sql"
}

error_codes()
{
  echo "Known exit codes of $(basename "$0"):"
  echo
  echo "    0: no error"
  echo "    $E_INVALID_ARGS: invalid or insufficient arguments"
  echo "    $E_NO_SOURCE: the given source file does not exist or is no regular file"
  echo "    $E_SOURCE_NOT_READABLE: source dump cannot be read"
  echo "    $E_DEST_EXISTS: destination file already exists"
  echo "    $E_SED_FAILED: error during sed execution"
  echo "    $E_NO_DATA: script could not find any data for the given DB"
}

# shows short note about GPL3 license
license_info()
{
  echo "utility script to extract the SQL statements for one database from an"
  echo "SQL dump of multiple databases"
  echo "Copyright (C) 2014, 2015  Dirk Stolle"
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

# puts the the MySQL comments to preserve character set etc. to the file given as 1st parameter
sql_comments_start()
{
  # not optimal, might change in future MySQL versions
  echo '/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;' >> "$1"
  echo '/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;' >> "$1"
  echo '/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;' >> "$1"
  echo '/*!40101 SET NAMES utf8 */;' >> "$1"
  echo '/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;' >> "$1"
  echo "/*!40103 SET TIME_ZONE='+00:00' */;" >> "$1"
  echo '/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;' >> "$1"
  echo '/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;' >> "$1"
  echo "/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;" >> "$1"
  echo '/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;' >> "$1"
  echo >> "$1"
}

# puts the the concluding MySQL comments to preserve character set etc. to the file given as 1st parameter
sql_comments_end()
{
  # not optimal, might change in future MySQL versions
  echo >> "$1"
  echo '/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;' >> "$1"
  echo "" >> "$1"
  echo '/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;' >> "$1"
  echo '/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;' >> "$1"
  echo '/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;' >> "$1"
  echo '/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;' >> "$1"
  echo '/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;' >> "$1"
  echo '/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;' >> "$1"
  echo '/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;' >> "$1"
}

# name of the database that shall be extracted
db_name=""
# original dump file
src_dump=""
# destination file
dest_dump=""

numargs=$#
declare -i numargs #declare numargs as integer

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
      # should be database name
      if [[ -z $db_name ]]
      then
        db_name=${!i}
        echo "Database name set to '$db_name'."
      elif [[ -z $src_dump ]]
      then
        src_dump=${!i}
        echo "Source dump is '$src_dump'."
      elif [[ -z $dest_dump ]]
      then
        dest_dump=${!i}
        echo "Output file will be '$dest_dump'."
      else
        echo "$(basename "$0"): Too much command line arguments!"
        exit $E_INVALID_ARGS
      fi
    ;;
  esac
  i+=1
done

#script needs at least three arguments (db name, source dump, destination) to work.
if [[ ! $numargs -eq 3 ]]
then
  usage_info
  exit $E_INVALID_ARGS
fi

# check for presence of source, before we proceed
if [[ ! -f $src_dump ]]
then
  echo "$(basename "$0"): $src_dump not found or not a file!"
  echo "Please check whether you have mistyped the file name."
  exit $E_NO_SOURCE
fi

if [[ ! -r $src_dump ]]
then
  echo "$(basename "$0"): $src_dump is not readable!"
  echo "Please check file permissions."
  exit $E_SOURCE_NOT_READABLE
fi

# We don't want to overwrite any existing files, so let's check existence.
if [[ -e $dest_dump ]]
then
  echo "$(basename "$0"): $dest_dump already exists!"
  exit $E_DEST_EXISTS
fi

#all checks passed, proceed :)
# add starting SQL "comments"
sql_comments_start $dest_dump
# save current size
size_before_sed=$(stat --format=%s $dest_dump)
# do the real work
echo "Extracting..."
sed -n "/^-- Current Database: \`$db_name\`/,/^-- Current Database: \`/p" $src_dump >> $dest_dump
ret=$?
if [[ $ret != 0 ]]
then
  echo "sed returned a non-zero error code ($ret)!"
  exit $E_SED_FAILED
fi
# new size?
size_after_sed=$(stat --format=%s $dest_dump)
if [[ $size_before_sed == $size_after_sed ]]
then
  echo "Error: Unable to find SQL statements for database '$db_name' in file '$src_dump'!"
  exit $E_NO_DATA
fi
completed_line=$(tail $dest_dump | grep --fixed-strings "Dump completed on")
if [[ -z $completed_line ]]
then
  # Add concluding SQL "comments" - only when it wasn't the last DB in the dump,
  # because in that case they would already be there.
  sql_comments_end $dest_dump
fi
echo "Done."
exit 0
