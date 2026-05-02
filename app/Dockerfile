FROM node:22-alpine
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
WORKDIR /app
COPY package*.json ./
RUN npm ci --omit=dev
COPY src/ ./src/
ARG APP_VERSION=unknown
ARG APP_ENVIRONMENT=unknown
ENV NODE_ENV=production
ENV PORT=8080
ENV APP_VERSION=${APP_VERSION}
ENV APP_ENVIRONMENT=${APP_ENVIRONMENT}
USER appuser
EXPOSE 8080
CMD ["node", "src/server.js"]
