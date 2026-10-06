# ---- Stage 1: install production dependencies ----
FROM node:20-alpine AS deps

WORKDIR /app

COPY package*.json ./
RUN npm ci --omit=dev

# ---- Stage 2: runtime image ----
FROM node:20-alpine

WORKDIR /app

ENV NODE_ENV=production
ENV NODE_VERSION=20.11.1
ENV HOME=/root
ENV npm_config_cache=/root/.npm
ENV TMPDIR=/root/tmp

# Copy dependencies with correct ownership
COPY --from=deps /app/node_modules ./node_modules
COPY package*.json ./
COPY src ./src

# Ensure the app directory is owned by root
RUN mkdir -p /root/.npm /root/tmp && chown -R root:root /app /root

EXPOSE 3000

CMD ["node", "src/server.js"]