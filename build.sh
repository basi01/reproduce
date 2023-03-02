#!/bin/bash

#echo "get latest Revision from branch Development"
#SVN_REV=`svn info  --show-item=last-changed-revision https://teamserver.sprintr.com/$SVN_PROJECT_ID/trunk --username $SVN_USERNAME --password $SVN_PASSWORD`
SVN_REV=

SVN_RARG=${SVN_REV:+-r ${SVN_REV}}

echo "Checking out code (revision $SVN_REV) from: https://teamserver.sprintr.com/$SVN_PROJECT_ID/branches/Development under $SVN_USERNAME" 
svn checkout -q ${SVN_RARG} https://teamserver.sprintr.com/$SVN_PROJECT_ID/trunk checkout/src --username $SVN_USERNAME --password $SVN_PASSWORD 
rm -rf checkout/src/.svn 

CURR_DIR=`pwd`

echo "Current working Dir : $CURR_DIR"

echo "All done."