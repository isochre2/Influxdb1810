#!/bin/bash

# Wait for InfluxDB to be ready
until curl -s http://localhost:8086/ping; do
    echo "Waiting for InfluxDB to be ready..."
    sleep 2
done

# Check if the database exists
if ! curl -G http://localhost:8086/query --data-urlencode "q=SHOW DATABASES" | grep -q "\"PowerMonitorDatabase\""; then
    influx -execute "CREATE DATABASE PowerMonitorDatabase"
    echo "Database PowerMonitorDatabase created."
else
    echo "Database PowerMonitorDatabase already exists."
fi

# Set up retention policies
influx -execute "CREATE RETENTION POLICY \"one_hour\" ON \"PowerMonitorDatabase\" DURATION 1h REPLICATION 1 DEFAULT"
echo "Retention policy 'one_hour' set on PowerMonitorDatabase."

# Set up continuous queries (adjust these to your requirements)
#influx -execute "CREATE CONTINUOUS QUERY \"cq_power\" ON 'PowerMonitorDatabase' BEGIN SELECT mean(\"Power\") AS avg_value INTO 'PowerMonitorDatabase'.'one_week'.'average_values' FROM 'measurement_name' GROUP BY time(1h) END"
#echo "Continuous query 'cq_example' created."
