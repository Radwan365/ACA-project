# stage 1 'builder'
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json yarn.lock ./
RUN yarn config set network-timeout 600000 && yarn install
COPY . .
RUN yarn build

# stage 2 'production'
FROM nginx:alpine
RUN apk upgrade --no-cache && apk del --no-cache curl
COPY --from=builder /app/build /usr/share/nginx/html
EXPOSE 80
CMD [ "nginx", "-g", "daemon off;" ]