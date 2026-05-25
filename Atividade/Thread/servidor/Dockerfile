FROM alpine:latest
RUN apk add --no-cache lua5.4 luarocks5.4
RUN luarocks install luasocket
RUN luarocks install lanes
WORKDIR /app
COPY servert.lua .
CMD ["lua5.4", "servert.lua"]