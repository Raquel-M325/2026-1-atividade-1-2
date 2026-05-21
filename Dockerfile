FROM ubuntu:22.04

RUN apt update && \
    apt install -y lua5.4 luarocks build-essential git

RUN luarocks install luasocket

RUN luarocks install lanes

WORKDIR /app

COPY . .

CMD ["lua", "cliente.lua"]