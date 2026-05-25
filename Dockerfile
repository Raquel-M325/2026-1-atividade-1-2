FROM alpine:latest
RUN apk add --no-cache lua5.4
WORKDIR /app
COPY basico.lua .
CMD ["lua5.4", "basico.lua"]
