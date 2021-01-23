#!/bin/sh
set -e

if [[ "$1" -ne "major" && "$1" -ne "minor" && "$1" -ne "patch" ]]; then
  echo "usage: $(basename $0) [major/minor/patch] major.minor.patch"
  exit 1
fi
version=$2
ver=( ${version//./ } )
if [ ${#ver[@]} -ne 3 ]
then
  echo "usage: $(basename $0) [major/minor/patch] major.minor.patch"
  exit 1
fi
if [ "$1" == "major" ]
then
  ((ver[0]++))
  ver[1]=0
  ver[2]=0
fi
if [ "$1" == "minor" ]
then
  ((ver[1]++))
  ver[2]=0
fi
if [ "$1" == "patch" ]
then
  ((ver[2]++))
fi
echo "${ver[0]}.${ver[1]}.${ver[2]}"