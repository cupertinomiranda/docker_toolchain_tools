FROM debian

WORKDIR /
RUN mkdir -p /workdir

COPY scripts /scripts

ENV INSTALL_DIR="/usr/share/"
ENV SOURCE_DIR="/source"

#VOLUME ["/source"]

#ONBUILD RUN cd /scripts && ./scripts/docker_builder.rb
CMD ["/bin/bash"]
