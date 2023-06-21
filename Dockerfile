# Step 1: Build the application using Maven
FROM maven:3.8.4-openjdk-11 AS build
WORKDIR /app
COPY . .
RUN mvn clean package -DskipTests

# Step 2: Create a minimal JRE image and add the JAR file
FROM adoptopenjdk:11-jre-hotspot
WORKDIR /app
COPY --from=build /app/target/my-application.jar /app/my-application.jar

# Step 3: Run the application
CMD ["java", "-jar", "/app/my-application.jar"]