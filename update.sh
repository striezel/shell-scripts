#!/bin/bash

#  update.sh - general update script to get the latest version of another
#              script from GitHub by checking the repo
#              <https://github.com/striezel/shell-scripts>.
#
#  Copyright (C) 2013, 2015  Dirk Stolle
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

location_latest_base=https://raw.github.com/striezel/shell-scripts/master

# error codes / exit codes
E_DOWNLOAD_FAILED=1 # download of new version failed
E_FILE_ERROR=2      # file error

wget_error()
{
  case $1 in
    0)
      echo "no error"
    ;;
    1)
      echo "unknown generic error"
    ;;
    2)
      echo "parse error"
    ;;
    3)
      echo "I/O error"
    ;;
    4)
      echo "network failure"
    ;;
    5)
      echo "SSL verification failure"
    ;;
    6)
      echo "authentication failure"
    ;;
    7)
      echo "protocol error"
    ;;
    8)
      echo "server returned error"
    ;;
    *)
      echo "unknown error"
    ;;
  esac
} # end of function wget_error

# function to do the real update work for a script
# It expects one parameter:
#    1st - base name of the script to update
update_script()
{
  local to_update=$1

  if [[ ! -e "./$to_update" ]]
  then
    echo "Info: $to_update was not found in the current directory, hence it cannot be updated."
    exit $E_FILE_ERROR
  fi

  # create temporary directory (downloaded files will be there)
  local tmp_dir=$(mktemp --directory)
  echo -n "Checking latest version of $to_update... "
  local version_file="version-$(basename "$to_update" .sh).txt"
  wget --quiet --no-cookies --no-http-keep-alive -O "$tmp_dir/$version_file" "$location_latest_base/$version_file"
  local wget_exit=$?
  if [[ $wget_exit -ne 0 ]]
  then
    echo -n "Error while downloading version file: "
    wget_error $wget_exit
    #remove file
    if [[ -f "$tmp_dir/$version_file" ]]
    then
      rm "$tmp_dir/$version_file"
    fi
    #remove temp dir
    rmdir "$tmp_dir"
    exit $E_DOWNLOAD_FAILED
  fi
  echo "OK"

  # extract version data from file
  local latest_hash=$(awk ' { print $1 } ' "$tmp_dir/$version_file")
  local latest_file=$(awk ' { print $2 } ' "$tmp_dir/$version_file")
  local latest_version=$(awk ' { print $3 } ' "$tmp_dir/$version_file")
  local latest_date=$(awk ' { print $4 } ' "$tmp_dir/$version_file")
  rm "$tmp_dir/$version_file"
  echo "Info: latest version of $latest_file is $latest_version of $latest_date."

  # get current file's hash and compare with latest file
  local current_hash=$(sha1sum "./$to_update")
  current_hash=${current_hash:0:40}
  if [[ $latest_hash = $current_hash ]]
  then
    echo "You already have the latest version of $to_update!"
    rmdir "$tmp_dir"
    exit 0
  else
    echo "You have a different version of $to_update."
  fi

  # start the download
  echo -n "Downloading latest version of $to_update..."
  wget --quiet --no-cookies --no-http-keep-alive -O "$tmp_dir/$to_update" "$location_latest_base/$to_update"
  wget_exit=$?
  if [[ $wget_exit -ne 0 ]]
  then
    echo -n "Error while downloading file: "
    wget_error $wget_exit
    #remove temp dir
    rmdir "$tmp_dir"
    exit $E_DOWNLOAD_FAILED
  fi
  echo " success."

  if [[ -e "./$to_update" ]]
  then
    if [[ ! -f "./$to_update" ]]
    then
      echo "$to_update already exists, but it is not a regular file! Aborting."
      exit $E_FILE_ERROR
    fi
    download_hash=$(sha1sum "$tmp_dir/$to_update")
    download_hash=${download_hash:0:40}
    if [[ $latest_hash != $download_hash ]]
    then
      echo "The downloaded version of $to_update is corrupt!"
      echo "That might be caused by transmission or disk errors."
      rm "$tmp_dir/$to_update"
      exit $E_DOWNLOAD_FAILED
    else
      echo "A newer version of $to_update was downloaded."
      echo "Copying latest version of $to_update to current directory."
      mv "$tmp_dir/$to_update" "./$to_update"
      chmod u+x "./$to_update"
    fi
  fi

  #remove temp dir
  rmdir "$tmp_dir"
} #update function

# update requested?
if [[ ! -z $1 ]]
then
  to_up=$(basename "$1")
  update_script "$to_up"
else
  echo "Nothing do do here, you didn't specify a script file that should be updated."
  echo "If you want to update a script, type"
  echo "    ./$(basename "$0") script-file.sh"
  echo "where script-files.sh has to be replaced by the script's name."
fi
exit 0
