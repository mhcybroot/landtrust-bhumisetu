# Stage 1: Build Flutter Web Release
FROM ghcr.io/cirruslabs/flutter:stable AS build
WORKDIR /app
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get
COPY . .
RUN flutter build web --release

# Stage 2: Serve with Nginx on port 9999 + Reverse Proxy /api/ to backend
FROM nginx:stable-alpine
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/build/web /usr/share/nginx/html
EXPOSE 9999
CMD ["nginx", "-g", "daemon off;"]
