# 빌드 스테이지
FROM gradle:8.4.0-jdk17 AS builder
WORKDIR /app
COPY . .
RUN ./gradlew clean build -x test

# 실행 스테이지
FROM openjdk:17-jar-slim
WORKDIR /app
COPY --from=builder /app/backend/build/libs/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
