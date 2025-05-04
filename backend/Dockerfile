#FROM gradle:8.4.0-jdk17 AS builder
#WORKDIR /app
#COPY . .
#RUN ./gradlew clean build -x test

FROM openjdk:17-jdk-slim
WORKDIR /app
COPY build/libs/buds.jar app.jar
# --from=builder /app/
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "/app/app.jar"]