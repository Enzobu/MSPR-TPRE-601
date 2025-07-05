FROM node:20-alpine AS base

RUN apk add --no-cache git

WORKDIR /app
RUN git clone https://github.com/Enzobu/MSPR-TPRE-601-FRONT.git .

ARG VITE_API_URL
ARG VITE_APP_TITLE

ENV VITE_API_URL=$VITE_API_URL
ENV VITE_APP_TITLE=$VITE_APP_TITLE

RUN npm install

# === STAGE 1: TEST ===
FROM base AS test
CMD ["npm", "run", "quality"]

# === STAGE 2: BUILD ===
FROM base AS build
RUN npm run build

# === STAGE 3: FINAL NGINX ===
FROM nginx:stable-alpine
COPY --from=build /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
