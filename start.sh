#!/usr/bin/env bash
set -e

echo "=========================================================="
echo "  ভূমি সেতু (Bhumi Setu / LandTrust) — Full-Stack Launcher"
echo "  Stack: Flutter (Web/Mobile) + Spring Boot + PostgreSQL"
echo "=========================================================="

echo "[1/2] Starting Spring Boot Backend on http://localhost:8085 ..."
cd "$(dirname "$0")/backend"
JAVA_HOME=/usr/lib/jvm/java-21-openjdk mvn spring-boot:run &
BACKEND_PID=$!

echo "[2/2] Starting Flutter Web App on http://localhost:8086 ..."
cd "../frontend"
flutter run -d web-server --web-port 8086 --web-hostname 0.0.0.0

kill $BACKEND_PID 2>/dev/null || true
