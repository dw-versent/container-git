item = git
base_image = wbit/alpine-$(item)-base

ifndef CONTAINER_NAME
$(info NO CONTAINER_NAME - using default)
CONTAINER_NAME:=$(item)-$(GITHUB_USER)
$(info "CONTAINER_NAME: $(CONTAINER_NAME)")
endif

ifndef GIT_CREDENTIALS_LOCATION
GIT_CREDENTIALS_LOCATION:=/dev/null
endif

ifndef DOCKERFILE
$(info NO DOCKERFILE SPECIFIED - using default)
DOCKERFILE:=Dockerfile
$(info "DOCKERFILE=$(DOCKERFILE)")
endif

check-build-base-image:
	@{                                                                                               \
		docker images | grep -q '$(base_image)' && exit 0 ;                                            \
		docker pull alpine:latest | grep -vq 'Downloaded newer image for alpine:latest' || exit 0 ;    \
		cd imagedefs/base &&                                                                           \
		docker build                                                                                   \
		--rm --squash -t                                                                               \
		$(base_image) . ;                                                                              \
	}


check-user-image-variables:
ifndef GITHUB_USER
	$(error NO GITHUB USER)
endif
ifndef GIT_USERNAME
	$(error NO GIT USERNAME)
endif
ifndef GIT_EMAIL
	$(error NO GIT EMAIL)
endif


install: check-build-base-image check-user-image-variables build-user-image build-container-command
	@echo "YAY $$DOCKERFILE"


define RUN_COMMAND
#!/bin/bash

docker run -it --rm                                                   \
-v $(PRIVATE_KEY_LOCATION):/home/$(GITHUB_USER)/.ssh/id_rsa           \
-v $(GIT_CREDENTIALS_LOCATION):/home/$(GITHUB_USER)/.git-credentials  \
-v `pwd`:`pwd`                                                        \
-w `pwd`                                                              \
-h $(item).local                                            \
$(CONTAINER_NAME)

endef

export RUN_COMMAND

build-container-command:
	echo "$$RUN_COMMAND" > "/usr/local/bin/$(CONTAINER_NAME)"
	chmod u+x "/usr/local/bin/$(CONTAINER_NAME)"

clean: uninstall

uninstall:
	docker rmi $(base_image)

build-user-image:
	@{                                                                 \
	docker images | grep -q '$(CONTAINER_NAME)' && exit 0 ;            \
	echo "*** BUILDING $(CONTAINER_NAME) IMAGE ***" &&                 \
	cd imagedefs/user &&                                               \
	docker build --rm --squash -t $(CONTAINER_NAME)                    \
	--file "$(DOCKERFILE)"                                             \
	--build-arg BASEIMAGE=$(base_image)                                \
	--build-arg GITHUB_USER="$(GITHUB_USER)"                           \
	--build-arg GIT_USERNAME="$(GIT_USERNAME)"                         \
	--build-arg GIT_EMAIL="$(GIT_EMAIL)"                               \
		. ;                                                              \
	}



define HELP_TEXT
GIT CONTAINER THINGY

	Build containers for your git identities.

	Setting up git on a developer workstation can be tangled if the developer has
	multiple git identities (say, github, bitbucket, corporate gits etc).

	One way to untangle this and keep git identities separated is to use containers.

Examples:
  1.
	Simple git container using bare minimums

  GITHUB_USER=loginusername                         \
	GIT_USERNAME='Friendly Name For Commits'          \
	GIT_EMAIL='email@address.tld'                     \
	make install

  The above will create an image called git-loginusername and put an executable
  script into /usr/local/bin/git-loginusername which will fire up a container in $PWD
  bind-mounting the private key `$HOME/.ssh/id_rsa`.

  2.
  To use another key, set PRIVATE_KEY_LOCATION on the command line:

  GITHUB_USER=loginusername                         \
  GIT_USERNAME='Friendly Name For Commits'          \
  GIT_EMAIL='email@address.tld'                     \
  PRIVATE_KEY_LOCATION=$HOME/.ssh/my-key.key        \
  make install


  3.
	For HTTPS based authentication we need to set GIT_CREDENTIALS_LOCATION on the command line.

	GITHUB_USER=login                                  \
	GIT_USERNAME="Friendly Login Name"                 \
	GIT_EMAIL='hidden-email@users.noreply.github.com'  \
	PRIVATE_KEY_LOCATION=$HOME/.ssh/github.key         \
	GIT_CREDENTIALS_LOCATION=~/.github-git-credentials \
	make install

  4.
	You might want to use a different Dockerfile for the user build (say, your org
	has a bunch of certificates that need to be added) - this can be accomplished
	using DOCKERFILE env var, and placing the custom dockerfile in ./imagedefs/user/Dockerfile-custom:

	GITHUB_USER=login                                  \
	GIT_USERNAME="Friendly Login Name"                 \
	GIT_EMAIL='hidden-email@users.noreply.github.com'  \
	PRIVATE_KEY_LOCATION=$HOME/.ssh/github.key         \
	GIT_CREDENTIALS_LOCATION=~/.github-git-credentials \
	DOCKERFILE=Dockerfile-custom                       \
	make install

endef
export HELP_TEXT

help:
	$(info $(HELP_TEXT))
	@:



.PHONY: all clean help
