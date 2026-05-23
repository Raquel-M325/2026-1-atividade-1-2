FROM alpine:latest
RUN apk add --no-cache lua5.4
WORKDIR /app
COPY classe.lua .
CMD ["lua5.4", "classe.lua"]