FROM centos:centos7.9.2009



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

ENV PATH=/home/builder/.local/bin:${PATH}

