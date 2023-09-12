set -e
tag=${1:?}

docker image tag bookplanningexport-mx-katee-base eu.gcr.io/halfpipe-io/bookplanningexport-mx-katee-base:${tag:?}
docker image push eu.gcr.io/halfpipe-io/bookplanningexport-mx-katee-base:${tag:?}
