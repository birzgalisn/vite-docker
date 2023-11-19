# syntax=docker/dockerfile:1

FROM node:20.9.0-alpine AS base

ENV PNPM_HOME=/root/.local/share/pnpm
ENV PATH=$PATH:$PNPM_HOME
RUN corepack enable

RUN apk add --no-cache libc6-compat
RUN apk update

FROM base AS fetcher
WORKDIR /app

COPY package.json pnpm-lock.yaml ./
RUN --mount=type=cache,id=pnpm,target=/root/.local/share/pnpm/store pnpm fetch

FROM fetcher AS installer
WORKDIR /app

COPY --from=fetcher /app/package.json /app/pnpm-lock.yaml ./
RUN --mount=type=cache,id=pnpm,target=/root/.local/share/pnpm/store pnpm install --frozen-lockfile --silent --offline

FROM base AS builder
WORKDIR /app

ARG ENV_VARIABLE
ARG VITE_ENV_VARIABLE

ENV NODE_ENV=production
ENV ENV_VARIABLE=${ENV_VARIABLE}
ENV VITE_ENV_VARIABLE=${VITE_ENV_VARIABLE}

COPY . ./
COPY --from=installer /app/package.json /app/pnpm-lock.yaml /app/node_modules ./
RUN --mount=type=cache,id=pnpm,target=/root/.local/share/pnpm/store pnpm build

FROM nginx:1.25.3-alpine AS final

COPY nginx.conf /etc/nginx/nginx.conf
COPY --from=builder /app/dist /usr/share/nginx/html

EXPOSE 3000/tcp

CMD ["nginx", "-g", "daemon off;"]
