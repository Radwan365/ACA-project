# Build context is ./app (see .github/workflows/docker-build.yml)

# Stage 1: build the React app into static files.
# Pinned to Node 24: this project uses Yarn v1, which the official node images
# stopped bundling at Node 26 because Yarn v1 is frozen upstream.
FROM node:24-alpine AS builder
WORKDIR /app

# Copy the dependency manifests first so this layer is cached until they change
COPY package.json yarn.lock ./
RUN yarn config set network-timeout 600000 \
    && yarn install --frozen-lockfile

COPY . .
RUN yarn build

# Stage 2: serve the static files with nginx running as a non-root user
FROM nginxinc/nginx-unprivileged:1.30-alpine-slim

# Pick up security patches for the base image packages, then drop back to the nginx user
USER root
RUN apk upgrade --no-cache
USER 101

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=builder /app/build /usr/share/nginx/html

# Non-root processes cannot bind ports below 1024, so nginx listens on 8080
EXPOSE 8080
