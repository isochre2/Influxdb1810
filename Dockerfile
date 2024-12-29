# Use the official InfluxDB 1.8.10 image as a base
FROM influxdb:1.8.10

# Define build arguments for credentials
ARG INFLUXDB_USER
ARG INFLUXDB_PASSWORD

# Set environment variables to configure InfluxDB on startup
ENV DOCKER_INFLUXDB_INIT_MODE=setup
ENV DOCKER_INFLUXDB_INIT_USERNAME=$INFLUXDB_USER
ENV DOCKER_INFLUXDB_INIT_PASSWORD=$INFLUXDB_PASSWORD
ENV DOCKER_INFLUXDB_INIT_ORG=CompagniePDC
ENV DOCKER_INFLUXDB_INIT_BUCKET=PowerMonitoringBucket
ENV INFLUXDB_HTTP_FLUX_ENABLED=true
ENV INFLUXDB_DB=PowerMonitorDatabase


# Copy the init script into the container
COPY init-influxdb-custom.sh init-influxdb-custom.sh

# Ensure the script is executable
RUN chmod +x init-influxdb-custom.sh

# Use the default CMD from the InfluxDB image
CMD ["sh", "-c", "influxd & ./init-influxdb-custom.sh & wait"]

