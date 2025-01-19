#!/bin/bash
# NOTE: Assumes 'az login' has been executed in the environment.
# NOTE: This should only be run once to generate a Service Principal. Running multiple times produces multiple service principals in Azure.
# NOTE: Save the output file somewhere secure, i.e. within your home directory.
# NOTE: List App Registrations: https://portal.azure.com/#blade/Microsoft_AAD_RegisteredApps/ApplicationsListBlade
# NOTE: Additional queries can be performed using the Azure CLI's --query parameter, see this website for more examples: https://jmespath.org/

echo "==== Using Current Azure Account Information"
az account show
echo "==== Provide Service Principal Display Name (created within Azure App Registrations):"
read spname

# Get basic tenant and subscription IDs for subscription which is CURRENTLY signed in
export TF_VAR_subscription_id=$(az account show --query 'id' --output tsv)
export TF_VAR_tenant_id=$(az account show --query 'tenantId' --output tsv)

# Create app ID under Azure -> App Registrations. This also returns the client secret.
# Additional documentation: https://docs.azure.cn/zh-cn/cli/ad/sp?view=azure-cli-latest
export TF_VAR_client_secret=$(az ad sp create-for-rbac --role "Contributor" --scopes="/subscriptions/$TF_VAR_subscription_id" --name $spname --query password --output tsv)

# Pause for a moment to allow Azure to catch up
echo "Sleeping for 10 seconds..."
sleep 10

# Get the client ID generated from previous command which created it
export TF_VAR_client_id=$(az ad sp list --show-mine --query "[?displayName == '$spname'].appId" -o tsv)

# Output
echo "==== .azure_docker_creds.env created to store Azure authentication parameters. SECURE THIS FILE."
echo "TF_VAR_subscription_id=$TF_VAR_subscription_id" > .azure_docker_creds.env
echo "TF_VAR_tenant_id=$TF_VAR_tenant_id" >> .azure_docker_creds.env
echo "TF_VAR_client_id=$TF_VAR_client_id" >> .azure_docker_creds.env
echo "TF_VAR_client_secret=$TF_VAR_client_secret" >> .azure_docker_creds.env
