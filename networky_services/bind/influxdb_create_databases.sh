#!/bin/bash

#Create a Grafana database:
curl -X POST 'http://localhost:8086/db?u=root&p=root' -d '{"name": "grafana"}'
#Create a user for the grafana database:
curl -X POST 'http://localhost:8086/db/grafana/users?u=root&p=root' -d '{"name": "nick", "password": "password"}'

#Create a riemann-data database:
curl -X POST 'http://localhost:8086/db?u=root&p=root' -d '{"name": "riemann-data"}'
#Create a user for the riemann-data database:
curl -X POST 'http://localhost:8086/db/riemann-data/users?u=root&p=root' -d '{"name": "nick", "password": "password"}'