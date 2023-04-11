#!/bin/bash

SVN_URL="https://teamserver.sprintr.com/${SVN_PROJECT_ID:?}/trunk"

#echo "get latest Revision from branch Development"
#SVN_REV=`svn info --show-item=last-changed-revision "$SVN_URL" --username "$SVN_USERNAME" --password "$SVN_PASSWORD"`
SVN_REV=

SVN_RARG=${SVN_REV:+-r ${SVN_REV}}

echo "Checking out code ($SVN_RARG) from: "$SVN_URL" under $SVN_USERNAME"
svn checkout -q ${SVN_RARG} "$SVN_URL" checkout/src --username "$SVN_USERNAME" --password "$SVN_PASSWORD"

if [ -z "$SVN_REV" ]; then
  SVN_REV=$(svn info --show-item last-changed-revision checkout/src)
fi
echo "r$SVN_REV" >checkout/src/model-version.txt
echo "SVN Revision: $SVN_REV"

rm -rf checkout/src/.svn

CURR_DIR=`pwd`

echo "Current working Dir : $CURR_DIR"

echo "All done."
