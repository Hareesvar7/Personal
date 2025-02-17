#!/bin/bash

# Step 1: Install Flyway
echo "##[section] Start: Installing Flyway"
wget -qO- https://repo1.maven.org/maven2/org/flywaydb/flyway-commandline/8.5.13/flyway-commandline-8.5.13-linux-x64.tar.gz | tar xvz
sudo mv flyway-8.5.13 /usr/local/flyway
sudo ln -sf /usr/local/flyway/flyway /usr/local/bin/flyway
export PATH=$(pwd)/flyway-8.5.13:$PATH
echo "##[section] Flyway installed"
flyway -v

# Step 2: Run Flyway Repair
echo "##[section] repoName value: ${variables.repoName}"
echo "##[section] Start: Running Flyway Repair"
flyway -schemas="${TENANT_NAME}_${variables.repoName}" \
       -table="flywayapptable" \
       -user="${MYSQL_DB_USERNAME}" \
       -password="${MYSQL_DB_PASSWORD}" \
       -url="jdbc:mysql://${MYSQL_DB_HOST}:${MYSQL_DB_PORT}/${TENANT_NAME}_${variables.repoName}" \
       repair

# Step 3: Run Flyway Migrate
echo "##[section] repoName value: ${variables.repoName}"
echo "##[section] Start: Running Flyway for each directory containing .sql files"
find . -type f -name "*.sql" -exec dirname {} \; | sort -u | while read dir; do
    echo "##[section] Running Flyway for directory: $dir"
    flyway -schemas="${TENANT_NAME}_${variables.repoName}" \
           -table="flywayapptable" \
           -user="${MYSQL_DB_USERNAME}" \
           -password="${MYSQL_DB_PASSWORD}" \
           -url="jdbc:mysql://${MYSQL_DB_HOST}:${MYSQL_DB_PORT}/${TENANT_NAME}_${variables.repoName}" \
           -locations="filesystem:$dir" \
           -baselineOnMigrate=true \
           migrate
done
