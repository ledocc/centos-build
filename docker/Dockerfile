ARG CENTOS_VERSION=7.9.2009
FROM centos:${CENTOS_VERSION}



RUN yum -y update

RUN yum -y install \
    centos-release-scl \
    epel-release.noarch
    
RUN yum -y update

RUN yum -y install \
        cargo \
	chrpath \
        ccache \
        devtoolset-10 \
        git \
        jq \
        m4 \
        patch \
        perl-Data-Dumper \
        perl-Digest-SHA \
        perl-IPC_Cmd \
        perl-Thread-Queue \
        sudo

RUN yum -y install \
        bash-completion \
        emacs \
        tmux


RUN adduser builder
RUN echo builder ALL = NOPASSWD:ALL > /etc/sudoers.d/builder

USER builder
WORKDIR /home/builder

COPY script /tmp/script
RUN /tmp/script/run.sh
RUN sudo rm -rf /tmp/script
