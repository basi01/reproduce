#!/bin/bash

#rm -rf checkout/src/.git
#mv -T checkout/src.save/.git checkout/src/.git 2>/dev/null || true

set -e

THISDIR=$(cd "${0%/*}" && pwd)
SAVEDIR=${PWD:?}

# Worktree is the output artifact itself so storing .git separately
export GIT_DIR="${SAVEDIR:?}/checkout/src.save/.git"

mkdir -p checkout/src checkout/src.save

SVN_REV=`cat $THISDIR/revision.txt`
echo "Checking out code (revision $SVN_REV)"

SCM_URL="https://git.api.mendix.com/${SVN_PROJECT_ID:?}.git"

# This starts a daemon process that may leak!
#git credential-cache exit
#git_arg_cred=credential.helper="cache"

# This stores password as plaintext!
rm -f "$SAVEDIR/.gitcred"
git_arg_cred=credential.helper="store --file=\"$SAVEDIR/.gitcred\""

# Store or Cache the password escaping the '@' sign in username if necessary
cat <<EOF | git -c "$git_arg_cred" credential approve
url=${SCM_URL:?}
username=${SVN_USERNAME:?}
password=${SVN_USERTOKEN:?}
EOF

mkdir -p checkout/src
cd checkout/src

{
  # make a new blank repository in the current directory
  git -c init.defaultBranch=dummy init

  # add a remote
  git remote add origin "${SCM_URL:?}"

  # set the username for URL
  git config credential."${SCM_URL:?}".username "${SVN_USERNAME:?}"

  # specifying --depth when repo already shallow causes redundant traffic
  git_depth_arg=
  [ "true" = "$(git rev-parse --is-shallow-repository)" ] || git_depth_arg="--depth=1"

  # fetch a commit (or branch or tag) of interest
  # Note: the full history up to this commit will be retrieved unless
  #       you limit it with '--depth=...' or '--shallow-since=...'
  checkoutarg=FETCH_HEAD
  git -c "$git_arg_cred" fetch $git_depth_arg origin "${SVN_REV:?}" || {
    # not all names can be fetched, e.g. abbreviated commits can't,
    # fallback to full fetch
    git -c "$git_arg_cred" fetch $git_depth_arg origin
    checkoutarg="${SVN_REV:?}"
  }

  # checkout what we fetched
  git -c advice.detachedHead=false checkout "$checkoutarg"
}

# shorten the SHA-1 version to display in the app
# This won't include the tag or branch name. If that's needed use:
# git describe --dirty --always --tags
SVN_REV=`git rev-parse --short HEAD`

cd ../..

echo "r$SVN_REV" >checkout/src/model-version.txt
echo "SVN Revision: $SVN_REV"

CURR_DIR=`pwd`

echo "Current working Dir : $CURR_DIR"

echo "All done."
