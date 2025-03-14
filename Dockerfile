# Stage 1: Build the WAR file
FROM maven:3.8-openjdk-11 AS builder

# Clone the repository
RUN apt-get update && apt-get install -y git
WORKDIR /app
RUN git clone https://github.com/vbc1012/java-war-repo.git .

# Build the WAR file
RUN mvn clean package

# Stage 2: Deploy to Tomcat with SSL
FROM tomcat:9.0-jdk11

# Install necessary packages
RUN apt-get update && apt-get install -y openssl

# Generate self-signed certificate
RUN mkdir -p /usr/local/tomcat/ssl
WORKDIR /usr/local/tomcat/ssl
RUN openssl req -new -newkey rsa:4096 -days 365 -nodes -x509 \
    -subj "/CN=localhost" \
    -keyout server.key -out server.crt

# Configure Tomcat to use SSL
RUN sed -i '/<Service name="Catalina">/a \\\n    <Connector port="8443" protocol="org.apache.coyote.http11.Http11NioProtocol" maxThreads="150" SSLEnabled="true" scheme="https" secure="true" keystoreFile="/usr/local/tomcat/ssl/keystore.p12" keystorePass="changeit" keyAlias="tomcat" keystoreType="PKCS12" clientAuth="false" sslProtocol="TLS"/>' /usr/local/tomcat/conf/server.xml

# Create PKCS12 keystore
RUN openssl pkcs12 -export -in server.crt -inkey server.key \
    -out keystore.p12 -name tomcat -passout pass:changeit

# Copy the WAR file from the builder stage
COPY --from=builder /app/target/*.war /usr/local/tomcat/webapps/opskill.war

# Set proper permissions
RUN chmod -R 755 /usr/local/tomcat/webapps

EXPOSE 8080 8443

CMD ["catalina.sh", "run"]
