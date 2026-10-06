# ---- Stage 1: install production dependencies ----
FROM node:20-alpine AS deps

WORKDIR /app

COPY package*.json ./
RUN npm ci --omit=dev

# ---- Stage 2: runtime image ----
FROM node:20-alpine

WORKDIR /app

ENV NODE_ENV=production
ENV HOME=/home/node
ENV npm_config_cache=/home/node/.npm
ENV TMPDIR=/home/node/tmp

# Copy dependencies with correct ownership
COPY --from=deps --chown=node:node /app/node_modules ./node_modules
COPY --chown=node:node package*.json ./
COPY --chown=node:node src ./src

# Ensure node user owns all required directories
RUN mkdir -p /home/node/.npm /home/node/tmp && \
    chown -R node:node /home/node /app

EXPOSE 3000

USER node

CMD ["node", "src/server.js"]