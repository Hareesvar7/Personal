#!/bin/bash

# Ensure required environment variables are set
if [[ -z "$TENANT_NAME" || -z "$MYSQL_DB_USERNAME" || -z "$MYSQL_DB_PASSWORD" || -z "$MYSQL_DB_HOST" || -z "$MYSQL_DB_PORT" || -z "$REPO_NAME" ]]; then
  echo "Error: One or more required environment variables are missing!"
  echo "Ensure TENANT_NAME, MYSQL_DB_USERNAME, MYSQL_DB_PASSWORD, MYSQL_DB_HOST, MYSQL_DB_PORT, and REPO_NAME are set."
  exit 1
fi

# Construct database name and JDBC URL
DB_NAME="${TENANT_NAME}_${REPO_NAME}"
JDBC_URL="jdbc:mysql://$MYSQL_DB_HOST:$MYSQL_DB_PORT/$DB_NAME"

echo "##[section] Running Flyway Repair for $DB_NAME"

# Run Flyway Repair
flyway -schemas="$DB_NAME" \
  -table="flywayapptable" \
  -user="$MYSQL_DB_USERNAME" \
  -password="$MYSQL_DB_PASSWORD" \
  -url="$JDBC_URL" \
  repair

echo "##[section] Start: Searching for SQL migration directories"

# Find directories containing SQL files
SQL_DIRS=$(find . -type f -name "*.sql" -exec dirname {} \; | sort -u)

if [[ -z "$SQL_DIRS" ]]; then
  echo "No SQL migration files found. Exiting."
  exit 0
fi

# Loop through each directory and run Flyway migrations
for DIR in $SQL_DIRS; do
  echo "##[section] Running Flyway Migrations for directory: $DIR"

  flyway -schemas="$DB_NAME" \
    -table="flywayapptable" \
    -user="$MYSQL_DB_USERNAME" \
    -password="$MYSQL_DB_PASSWORD" \
    -url="$JDBC_URL" \
    -locations="filesystem:$DIR" \
    -baselineOnMigrate=true \
    migrate

  if [[ $? -ne 0 ]]; then
    echo "##[error] Flyway migration failed in directory: $DIR"
    exit 1
  fi
done

echo "##[section] Flyway migration completed successfully!"
