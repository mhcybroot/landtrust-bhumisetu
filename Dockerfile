FROM eclipse-temurin:21-jre-alpine

WORKDIR /app
ENV TZ=Asia/Dhaka

# Install PostgreSQL, Nginx, Bash, and su-exec for all-in-one deployment
RUN apk add --no-cache postgresql16 postgresql16-contrib nginx bash su-exec && \
    mkdir -p /run/nginx /var/lib/postgresql/data /run/postgresql && \
    chown -R postgres:postgres /var/lib/postgresql /run/postgresql

# Copy pre-built Spring Boot JAR and Flutter Web bundle
COPY deploy/app.jar /app/app.jar
COPY deploy/web /usr/share/nginx/html
COPY deploy/nginx.conf /etc/nginx/http.d/default.conf
COPY deploy/entrypoint.sh /app/entrypoint.sh

RUN chmod +x /app/entrypoint.sh

EXPOSE 9999 80

VOLUME ["/var/lib/postgresql/data"]

CMD ["/app/entrypoint.sh"]
