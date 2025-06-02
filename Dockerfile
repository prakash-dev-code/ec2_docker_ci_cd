# Stage 1: Base (dependencies)
FROM node:20.11.0-alpine AS deps

WORKDIR /app

# Copy package files first for caching
COPY package.json package-lock.json ./

# Install all dependencies (needed for build)
RUN npm install

# Stage 2: Build
FROM node:20.11.0-alpine AS build

WORKDIR /app

# Copy source code
COPY . .

# Copy dependencies from previous stage
COPY --from=deps /app/node_modules ./node_modules

# Build the Next.js app
RUN npm run build

# Stage 3: Production
FROM node:20.11.0-alpine AS prod

WORKDIR /app

# Copy package files first
COPY package.json package-lock.json ./

# Install only production dependencies
RUN npm ci --omit=dev

# Copy build output from build stage
COPY --from=build /app/.next ./.next
COPY --from=build /app/public ./public
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/next.config.ts ./next.config.ts
COPY --from=build /app/tsconfig.json ./tsconfig.json

EXPOSE 3000

CMD ["npm", "start"]
