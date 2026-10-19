# Stage 1: Build Spring Boot JAR with Java 21
FROM maven:3.9.9-eclipse-temurin-21-alpine AS build
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline -B
COPY src ./src
RUN mvn clean package -DskipTests -B

# Stage 2: Lightweight Production Runtime
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app
ENV TZ=Asia/Dhaka
COPY --from=build /app/target/landtrust-backend-1.0.0.jar app.jar
EXPOSE 8085
ENTRYPOINT ["java", "-Xms128m", "-Xmx512m", "-jar", "app.jar"]
