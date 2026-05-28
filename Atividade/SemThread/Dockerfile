FROM ubuntu:22.04

RUN apt-get update && \
    apt-get install -y lua5.4 luarocks && \
    luarocks install luasocket

WORKDIR /app

COPY . .

CMD ["bash"]