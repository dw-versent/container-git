#!/bin/bash

# Include me in your bash_profile:
# [ -f ~/my-containers/container-git/bin/container-git.bash ] && . ~/my-containers/container-git/bin/container-git.bash


clean-docker-images() { docker rmi `docker images | grep \<none | awk '{print $3}'` ; }
clean-docker-containers() { docker rm `docker ps -a | grep Exited | awk '{print $1}'` ; }

# generated by containers.d
for file in ~/bin/containers.d/* ; do
  source "$file"
done

# declared by user
for file in ~/etc/containers.d/* ; do
  source "$file"
done

# Example for $USER/etc/containers.d/container-git
build-git-example-container() {
  THE_PWD=`pwd`
  [ -f ~/.ssh/my-github.key ] && export ID_RSA=~/.ssh/my-github.key
  [ -f ~/.ssh/.my-git-credentials ] && export GIT_CREDENTIALS=~/.ssh/.my-git-credentials

  cd ~/my-containers/container-git

  ./bin/build-container \
    git-container \
    me-example \
    "Example User" \
    "example@example.com"

  cd $THE_PWD
}

