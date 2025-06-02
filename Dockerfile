# ---------- Stage 1: Base ----------
    FROM node:18-alpine AS base
    WORKDIR /app
    COPY package*.json ./
    
    # ---------- Stage 2: Development ----------
    FROM base AS dev
    RUN npm install
    COPY . .
    RUN npm install -g ts-node nodemon
    CMD ["npm", "run", "dev"]
    
    # ---------- Stage 3: Production ----------
    FROM base AS build
    RUN npm ci
    COPY . .
    RUN npm run build
    
    FROM node:18-alpine AS prod
    WORKDIR /app
    COPY --from=build /app/package*.json ./
    COPY --from=build /app/node_modules ./node_modules
    COPY --from=build /app/dist ./dist
    CMD ["npm", "start"]
    