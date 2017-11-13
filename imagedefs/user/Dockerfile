ARG BASEIMAGE=whatbirdisthat/alpine-git-base
FROM ${BASEIMAGE}

WORKDIR /

ARG GITHUB_USER=nobody
ARG GIT_USERNAME="nobody"
ARG GIT_EMAIL="nobody@localhost"


RUN echo "GITHUB USER IS " ${GITHUB_USER}

RUN adduser -D -g '' ${GITHUB_USER}
RUN addgroup ${GITHUB_USER} git

WORKDIR /home/${GITHUB_USER}
ADD assets/.bashrc .

RUN mkdir /home/${GITHUB_USER}/.ssh
WORKDIR /home/${GITHUB_USER}/.ssh
RUN cat /etc/ssh/known_hosts > /home/${GITHUB_USER}/.ssh/known_hosts
RUN chmod 0400 /home/${GITHUB_USER}/.ssh/known_hosts

WORKDIR /home/${GITHUB_USER}
RUN chown -R ${GITHUB_USER} /home/${GITHUB_USER}

USER ${GITHUB_USER}

RUN git config --global user.name "${GIT_USERNAME}"
RUN git config --global user.email "${GIT_EMAIL}"
RUN git config --global credential.helper 'read-only'

ENTRYPOINT /bin/bash
