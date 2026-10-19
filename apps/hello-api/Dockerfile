# ---- build stage: full toolchain, dev dependencies, TypeScript ----
FROM node:24-trixie-slim AS build
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci
COPY tsconfig.json ./
COPY src ./src
# Compile, then drop devDependencies (typescript, @types/*) from node_modules
RUN npm run build && npm prune --omit=dev

# ---- runtime stage: Node only, no shell, non-root user ----
FROM gcr.io/distroless/nodejs24-debian13:nonroot
WORKDIR /app
# package.json is needed at runtime: "type": "module" tells Node to load dist/*.js as ESM
COPY --from=build /app/package.json ./
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/dist ./dist
# The image's ENTRYPOINT is already node, so CMD holds only its arguments
CMD ["dist/server.js"]