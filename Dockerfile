FROM node:22-alpine
WORKDIR /app
ENV NODE_ENV=production
COPY index.html server.mjs ./
RUN mkdir -p /app/data
VOLUME ["/app/data"]
EXPOSE 4173
CMD ["node", "server.mjs"]
