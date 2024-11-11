# Use the official InfluxDB 1.8.10 image as a base
FROM influxdb:1.8.10

# Define build arguments for credentials
ARG INFLUXDB_USER
ARG INFLUXDB_PASSWORD

# Set environment variables to configure InfluxDB on startup
ENV INFLUXDB_DB=PowerMonitorDatabase
ENV INFLUXDB_HTTP_FLUX_ENABLED=true
ENV DOCKER_INFLUXDB_INIT_USERNAME=$INFLUXDB_USER
ENV DOCKER_INFLUXDB_INIT_PASSWORD=$INFLUXDB_PASSWORD
ENV DOCKER_INFLUXDB_INIT_ORG=CompagniePDC
ENV DOCKER_INFLUXDB_INIT_BUCKET=PowerMonitoringBucket

# Create directories for InfluxDB data and config
RUN mkdir -p /var/lib/influxdb1810 /etc/influxdb1810

# Use volumes for data and config to persist data between container restarts
VOLUME /var/lib/influxdb1810
VOLUME /etc/influxdb1810

# Copy the InfluxDB configuration file (optional if you need a custom config file)
# COPY influxdb.conf /etc/influxdb/influxdb.conf

# Expose the default InfluxDB HTTP port
#EXPOSE 8086

# Start InfluxDB with the appropriate configuration
CMD influxd & \
    until curl -s http://localhost:8086/ping; do \
        echo "Waiting for InfluxDB to be ready..."; \
        sleep 2; \
    done && \
    influx -execute "CREATE DATABASE IF NOT EXISTS PowerMonitorDatabase" && \
	wait
