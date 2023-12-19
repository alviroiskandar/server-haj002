FROM node:18-alpine

WORKDIR /app
RUN apk add git
RUN git clone https://github.com/GNUWeeb/pgpkeys-wkd-server.git wkd

WORKDIR /app/wkd
RUN npm install -g pnpm
RUN pnpm install
RUN pnpm run compile

CMD [ "pnpm", "start" ]
