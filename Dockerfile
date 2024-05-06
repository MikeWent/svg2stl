FROM debian:testing

RUN apt update -y && \
    apt install -y openscad potrace imagemagick inkscape libxml2-utils

ADD svg2stl.sh /opt/
ADD svg2stl.scad /opt/

VOLUME [ "/data" ]
WORKDIR /opt
ENTRYPOINT [ "./svg2stl.sh" ]
