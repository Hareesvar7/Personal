flyway -schemas="$(TENANT_NAME)_${{ variables.repoName }}" \
  -table="flywayapptable" \
  -user="$(MYSQL_DB_USERNAME)" \
  -password="$(MYSQL_DB_PASSWORD)" \
  -url="jdbc:mysql://$(MYSQL_DB_HOST):$(MYSQL_DB_PORT)/$(TENANT_NAME)_${{ variables.repoName }}" \
  repair

displayName: 'Run Flyway Repair'


- script: |
  echo "##[section]repoName value: ${{ variables.repoName }}"
  echo "##[section] Start: Running Flyway for each directory containing SQL files"

  find . -type f -name "*.sql" -exec dirname {} \; | sort -u | while read dir; do




  echo "##[section] Running Flyway for directory: $dir"

  flyway -schemas="$(TENANT_NAME)_${{ variables.repoName }}" \
    -table="flywayapptable" \
    -user="$(MYSQL_DB_USERNAME)" \
    -password="$(MYSQL_DB_PASSWORD)" \
    -url="jdbc:mysql://$(MYSQL_DB_HOST):$(MYSQL_DB_PORT)/$(TENANT_NAME)_${{ variables.repoName }}" \
    -locations="filesystem:$dir" \
    -baselineOnMigrate=true \
    migrate
