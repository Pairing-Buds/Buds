FROM openjdk:17-jdk-slim
WORKDIR /app
COPY build/libs/buds.jar app.jar
COPY config/application.yml config/application.yml
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "/app/app.jar", "--spring.config.location=file:/app/config/application.yml"]