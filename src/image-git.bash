#!/bin/bash

build-git-image() {
THE_PWD=`pwd`

CONTAINER_NAME=${1:-git-container}
GITHUB_USER=${2:-nobody}
GIT_USERNAME=${3:-My user "name" for git logs}
GIT_EMAIL=${4:-user.email@local}

build-base() {
  cd $THE_PWD/imagedefs/base
  docker build \
    --rm \
    --squash \
    -t alpine-git-base \
    .
}

docker pull alpine | grep 'Downloaded newer image for alpine:latest' && build-base

cd $THE_PWD/imagedefs/user
docker build \
  --rm \
  --squash \
  -t $CONTAINER_NAME \
  --build-arg GITHUB_USER="$GITHUB_USER" \
  --build-arg GIT_USERNAME="$GIT_USERNAME" \
  --build-arg GIT_EMAIL="$GIT_EMAIL" \
  --build-arg BASEIMAGE=alpine-git-base \
  .

bindmount=""

if [ "x${ID_RSA}" != "x" ] ; then
  bindmount="-v ${ID_RSA}:/home/${GITHUB_USER}/.ssh/id_rsa"
fi

if [ "x${GIT_CREDENTIALS}" != "x" ]; then
    bindmount="$bindmount -v ${GIT_CREDENTIALS}:/home/${GITHUB_USER}/.git-credentials"
fi

vpwd='-v `pwd`:`pwd` '
wpwd='-w `pwd` '

runcommand=`cat <<EOF
#!/bin/bash
${CONTAINER_NAME}() {
  docker run -it --rm \
    ${bindmount} \
    ${vpwd} $wpwd \
    -h ${CONTAINER_NAME}.local \
    ${CONTAINER_NAME}
}
EOF`

cd $THE_PWD
echo "$runcommand" > ${HOME}/.containers.d/${CONTAINER_NAME}

cat <<EOF

GIT CONTAINER:

GITHUB_USER: $GITHUB_USER
GIT_USERNAME: $GIT_USERNAME
GIT_EMAIL: $GIT_EMAIL

Reload your ~/.bash_profile to alias the container command ${CONTAINER_NAME}()

EOF

}

