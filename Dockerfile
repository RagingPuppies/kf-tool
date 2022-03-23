FROM python:3.8-slim-buster

LABEL maintainer="Tomer Setty tsetty@outbrain.com"


WORKDIR /app

COPY requirements.txt /app/

RUN pip3 install -r requirements.txt 
RUN apt update && apt install curl iputils-ping -y
CMD ["/bin/bash", "-c", "--", "chmod 777 /usr/bin/kf;while true; do sleep 30; done;"]

