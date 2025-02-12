#!/usr/bin/env bash

# Login to Azure using Service Principal
AZURE_LOGIN_OUTPUT=$(az login --service-principal -u $azure_client_id -p $azure_client_secret --tenant $azure_tenant_id --output json)

# Extract the tenant name using jq
TENANT_NAME=$(echo "$AZURE_LOGIN_OUTPUT" | jq -r --arg tenant "$azure_tenant_id" '.[] | select(.tenantId == $tenant) | .name')

# Print the extracted tenant name
echo Tenant Name: $TENANT_NAME
