FROM node:26-alpine
# Pick up fixed OS packages (openssl, zlib) published after the base image was built.
# The service does not need npm; the one bundled in the base image carries its own CVEs.
RUN apk upgrade --no-cache \
    && rm -rf /usr/local/lib/node_modules/npm /usr/local/bin/npm /usr/local/bin/npx
WORKDIR /app
COPY package.json ./
COPY src ./src
USER 1000
EXPOSE 3000
HEALTHCHECK --interval=30s --timeout=3s CMD ["node", "-e", "require('http').get('http://localhost:3000/health', r => process.exit(r.statusCode === 200 ? 0 : 1)).on('error', () => process.exit(1))"]
CMD ["node", "src/app.js"]
