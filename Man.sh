az login --service-principal -u $azure_client_id -p $azure_client_secret --tenant $azure_tenant_id --output json | jq -r --arg tenant "$azure_tenant_id" '.[] | select(.tenantId == $tenant) | .name'
