FROM ubuntu:22.04

RUN apt update && \
    apt install -y \
    lua5.4 \
    liblua5.4-dev \
    luarocks \
    build-essential \
    git

RUN luarocks install luasocket

RUN luarocks install lanes

WORKDIR /app

COPY . .

CMD ["lua", "cliente.lua"]