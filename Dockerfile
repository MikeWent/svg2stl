FROM python:3.12

RUN apt update -y && \
    apt install -y openscad potrace imagemagick inkscape libxml2-utils

COPY app /app
ADD requirements.txt /app

WORKDIR /app
RUN --mount=type=cache,target=/root/.cache/pip \
    pip3 install -r requirements.txt

ENTRYPOINT [ "python3", "./server.py" ]
