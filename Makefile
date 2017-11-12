package = container-git
version = 1.0
tarname = $(package)
distdir = $(tarname)-$(version)

install: install-containers.d
	rm -f ${HOME}/.containers.d/$(package)
	rm -f ${HOME}/.containers.d/image-git
	ln -s ${PWD}/src/image-git.bash ${HOME}/.containers.d/image-git
	cp ${PWD}/src/$(package).bash ${HOME}/.containers.d/$(package)
	sed -i '' 's|#CONTAINER_GIT_HOME#|${PWD}|g' ${HOME}/.containers.d/$(package)

uninstall:
	rm -f ${HOME}/.containers.d/$(package)
	rm -f ${HOME}/.containers.d/image-git

uninstall-containers.d:
	rm -rf ~/.containers.d/
	sed -i '' '/^for conf in.*containers\.d.*$$/d' ${HOME}/.bash_profile

install-containers.d:
	mkdir -p ${HOME}/.containers.d/
	grep '~/.containers.d/*' ~/.bash_profile || \
	echo 'for conf in ~/.containers.d/* ; do source "$$conf" ; done ;' >> ${HOME}/.bash_profile

.PHONY: all clean
