item = git
image = image-$(item)
package = container-$(item)
container = $(package)
version = 1.0
tarname = $(package)
distdir = $(tarname)-$(version)

imagebash = ${HOME}/src/$(image).bash
containerbash = ${HOME}/src/$(package)


install: install-containers.d remove-links
	rm -f ${HOME}/.containers.d/$(container)
	rm -f ${HOME}/.containers.d/$(image)
	ln -s ${PWD}/src/$(container).bash ${HOME}/.containers.d/$(container)
	cp ${PWD}/src/$(image).bash ${HOME}/.containers.d/$(image)
	sed -i '' 's|#CONTAINER_GIT_HOME#|${PWD}|g' ${HOME}/.containers.d/$(image)

remove-links:
	rm -f ${HOME}/.containers.d/$(container)
	rm -f ${HOME}/.containers.d/$(image)

uninstall: remove-links

uninstall-containers.d:
	rm -rf ~/.containers.d/
	sed -i '' '/^for conf in.*containers\.d.*$$/d' ${HOME}/.bash_profile

install-containers.d:
	mkdir -p ${HOME}/.containers.d/
	grep '~/.containers.d/*' ~/.bash_profile || \
	echo 'for conf in ~/.containers.d/* ; do source "$$conf" ; done ;' >> ${HOME}/.bash_profile

.PHONY: all clean
