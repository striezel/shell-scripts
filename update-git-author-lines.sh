#!/bin/bash


#  update-git-author-lines.sh.sh
#                    - update script to get the latest version of
#                      git-author-lines.sh from GitHub by checking the repo
#                      <https://github.com/Thoronador/shell-scripts>.
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

to_update=git-author-lines.sh
location_latest=https://raw.github.com/Thoronador/shell-scripts/master/git-author-lines.sh

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

if [[ ! -e "./$to_update" ]]
then
  echo "Info: $to_update was not found in the current directory, hence it cannot be updated."
  exit $E_FILE_ERROR
fi

# create temporary directory (downloaded files will be there)
tmp_dir=`mktemp --directory`
#echo "Created temporary directory for download of new version: $tmp_dir"
echo -n "Checking latest version of $to_update... "
version_file="version-`basename "$to_update" .sh`.txt"
wget --quiet --no-cookies --no-http-keep-alive -O "$tmp_dir/$version_file" "`dirname $location_latest`/$version_file"
wget_exit=$?
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
latest_hash=`awk ' { print $1 } ' "$tmp_dir/$version_file"`
latest_file=`awk ' { print $2 } ' "$tmp_dir/$version_file"`
latest_version=`awk ' { print $3 } ' "$tmp_dir/$version_file"`
latest_date=`awk ' { print $4 } ' "$tmp_dir/$version_file"`
rm "$tmp_dir/$version_file"
echo "Info: latest version of $latest_file is $latest_version of $latest_date."

# get current file's hash and compare with latest file
current_hash=`sha1sum "./$to_update"`
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
wget --quiet --no-cookies --no-http-keep-alive -O "$tmp_dir/$to_update" $location_latest
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
  download_hash=`sha1sum "$tmp_dir/$to_update"`
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
exit 0
