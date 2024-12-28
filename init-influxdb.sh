#!/bin/bash

# Delay execution to allow InfluxDB more time to initialize
echo "Delaying initialization script execution by 60 seconds..."
sleep 60

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
influx -execute "USE \"PowerMonitorDatabase\""
influx -execute "CREATE CONTINUOUS QUERY \"cq_energy_hourUV\" ON \"PowerMonitorDatabase\" RESAMPLE EVERY 1s BEGIN SELECT INTEGRAL(\"Power\", 1h) AS \"LineLastHourEnergy_UV\" INTO \"PowerMonitorDatabase\".\"autogen\".\"EnergyMeasurement\" FROM \"Power\" WHERE \"Line\" = 'UV' GROUP BY time(1h) END"
influx -execute "CREATE CONTINUOUS QUERY \"cq_energy_hourVW\" ON \"PowerMonitorDatabase\" RESAMPLE EVERY 1s BEGIN SELECT INTEGRAL(\"Power\", 1h) AS \"LineLastHourEnergy_VW\" INTO \"PowerMonitorDatabase\".\"autogen\".\"EnergyMeasurement\" FROM \"Power\" WHERE \"Line\" = 'VW' GROUP BY time(1h) END"
influx -execute "CREATE CONTINUOUS QUERY \"cq_energy_hourWU\" ON \"PowerMonitorDatabase\" RESAMPLE EVERY 1s BEGIN SELECT INTEGRAL(\"Power\", 1h) AS \"LineLastHourEnergy_WU\" INTO \"PowerMonitorDatabase\".\"autogen\".\"EnergyMeasurement\" FROM \"Power\" WHERE \"Line\" = 'WU' GROUP BY time(1h) END"
echo "Continuous query 'cq_energy' created."

#Commande pour accéder à influxQL
#influx -precision rfc3339