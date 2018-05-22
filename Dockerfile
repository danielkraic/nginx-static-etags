FROM debian:stretch

# mkdir output
# docker run -it --rm -v `pwd`/output:/output debian:stretch bash

# mkdir out && dpkg -x *nginx*full.deb out/

# add deb-src sources
RUN echo 'deb-src http://deb.debian.org/debian stretch main' >> /etc/apt/sources.list && \
    echo 'deb-src http://deb.debian.org/debian stretch-updates main' >> /etc/apt/sources.list && \
    echo 'deb-src http://security.debian.org stretch/updates main' >> /etc/apt/sources.list

# install requirements
RUN apt update && \
    apt install -y dpkg-dev git

# create build dir
RUN mkdir -p /opt/nginx && \
    cd /opt/nginx

# get nginx sources
RUN apt-get source nginx && \
    apt-get build-dep -y nginx

# add etag module
RUN cd /opt/nginx/nginx-*/debian/modules/ && \
    git clone https://github.com/danielkraic/nginx-static-etags.git

# change configure script
RUN cd /opt/nginx/nginx*/ && \
    sed -i 's/common_configure_flags := /common_configure_flags := --add-module=$(MODULESDIR)\/nginx-static-etags /' debian/rules

# build deb packages
RUN cd /opt/nginx/nginx*/ && \
    dpkg-buildpackage -rfakeroot -uc -b

# mode packages to soutput dir
RUN mkdir -p /output && \
    mv ../*.deb /output
