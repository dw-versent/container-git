#!/bin/bash

clean-docker-images() { docker rmi `docker images | grep \<none | awk '{print $3}'` ; }
clean-docker-containers() { docker rm `docker ps -a | grep Exited | awk '{print $1}'` ; }

export BUILDCMD='build-git-image'

# Example for $USER/etc/containers.d/container-git
build-git-example-container() {
  THE_PWD=`pwd`

  [ -f ~/.ssh/my-github.key ] && export ID_RSA=~/.ssh/my-github.key
  [ -f ~/.ssh/.my-git-credentials ] && export GIT_CREDENTIALS=~/.ssh/.my-git-credentials

  $BUILDCMD \
    whatbirdisthat/git-container \
    me-example \
    "Example User" \
    "example@example.com"

  cd $THE_PWD
}

