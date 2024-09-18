#!/bin/bash

set -e
set -o pipefail

SVN_REV=`cat ${1:?}`

MXGIT_BASE_URL="https://git.api.mendix.com"

SAVEDIR=${PWD:?}

fn_git_conf_add() {
  #
  # add Git configuration option without writing to any file
  #
  export "GIT_CONFIG_KEY_$((GIT_CONFIG_COUNT))=${1:?}"
  export "GIT_CONFIG_VALUE_$((GIT_CONFIG_COUNT))=${2}"
  export GIT_CONFIG_COUNT=$((GIT_CONFIG_COUNT + 1))
}

# reset
export GIT_CONFIG_COUNT=0

# disable default git config
export GIT_CONFIG_GLOBAL=/dev/null

SCM_URL="${MXGIT_BASE_URL:?}/${SVN_PROJECT_ID:?}.git"

# This stores password as plaintext!
rm -f "$SAVEDIR/.gitcred"
fn_git_conf_add credential.helper "store --file=\"${SAVEDIR:?}/.gitcred\""

# Store or Cache the password escaping the '@' sign in username if necessary
cat <<EOF | git credential approve
url=${MXGIT_BASE_URL:?}
username=${SVN_USERNAME:?}
password=${SVN_USERTOKEN:?}
EOF

echo "Checking out code (revision $SVN_REV)"

mkdir -p checkout/src checkout/src.save

# Worktree is the output artifact itself so storing .git separately
export GIT_DIR="${SAVEDIR:?}/checkout/src.save/.git"

cd checkout/src

{
  # make a new blank repository in the current directory
  git -c init.defaultBranch=dummy init

  # add a remote
  git remote add origin "${SCM_URL:?}"

  # This is unnecessary when .gitcred already has a matching url-user-password
  if false && [ ! -z "$SVN_USERNAME" ]; then
    # set the username for URL
    git config credential."${SCM_URL:?}".username "${SVN_USERNAME:?}"
  fi

  # specifying --depth when repo already shallow causes redundant traffic
  git_depth_arg=
  [ "true" = "$(git rev-parse --is-shallow-repository)" ] || git_depth_arg="--depth=1"

  # fetch a commit (or branch or tag) of interest
  # Note: the full history up to this commit will be retrieved unless
  #       you limit it with '--depth=...' or '--shallow-since=...'
  checkoutarg=FETCH_HEAD
  git fetch $git_depth_arg origin "${SVN_REV:?}" || {
    # not all names can be fetched, e.g. abbreviated commits can't,
    # fallback to full fetch
    git fetch $git_depth_arg origin
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
