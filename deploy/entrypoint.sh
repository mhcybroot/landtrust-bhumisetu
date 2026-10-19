#!/usr/bin/env bash
set -e

echo "==================================================="
echo "  Starting LandTrust (Bhumi Setu) All-in-One Stack"
echo "==================================================="

# 1. Start embedded PostgreSQL if external DB_URL is not provided
if [ -z "$DB_URL" ]; then
    mkdir -p /var/lib/postgresql/data /run/postgresql
    chown -R postgres:postgres /var/lib/postgresql /run/postgresql

    if [ ! -s "/var/lib/postgresql/data/PG_VERSION" ]; then
        echo "[1/3] Initializing PostgreSQL database cluster..."
        su-exec postgres initdb -D /var/lib/postgresql/data --encoding=UTF8 --locale=C
    fi

    echo "[1/3] Starting PostgreSQL service..."
    su-exec postgres pg_ctl -D /var/lib/postgresql/data -o "-c listen_addresses='127.0.0.1'" -w start

    su-exec postgres psql -tc "SELECT 1 FROM pg_database WHERE datname = 'landtrust_db'" | grep -q 1 || \
        su-exec postgres psql -c "CREATE DATABASE landtrust_db ENCODING 'UTF8';"

    export DB_URL="jdbc:postgresql://127.0.0.1:5432/landtrust_db"
    export DB_USERNAME="postgres"
    export DB_PASSWORD=""
fi

# 2. Start Spring Boot Backend on port 8085
echo "[2/3] Starting Spring Boot Backend on port 8085..."
java -Xms128m -Xmx512m -jar /app/app.jar &

# 3. Start Nginx Frontend on port 9999 & 80
echo "[3/3] Starting Nginx Frontend on port 9999..."
exec nginx -g "daemon off;"
