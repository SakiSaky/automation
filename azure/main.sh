#!/bin/bash
#
# Create user, group in Entra ID and VM. Add permission to this user for RDS 
# to this VM.

# Includes:
source functions.sh
source variables.sh

# Write OS info
get_os_info

# Checking CLI is installed, and ask to install it if not
check_cli

# Exit if CLI is not installed
if ! $AZ_CLI_INTALLED; then
  echo "Azure CLI is not installed. Please install it first."
  exit 1
fi

# sign in with specific tenant if not logged in
current_tenant_id=$(az account show --query "tenantId" --output tsv)
if [[ "$current_tenant_id" == "$TENANT_ID" ]]; then
  echo "You are logged in to the target tenant."
else
  echo "Log in with the link below to the target tenant!"
  az login --tenant $TENANT_ID
fi

# Allow installing CLI extensions without prompt if necessary
az config set extension.use_dynamic_install=yes_without_prompt

# Check and create user in Entra ID if not exist
az ad user show --id $USER_PRINCIPAL_NAME &>/dev/null
if [ $? -ne 0 ]; then
  echo "Creating '${USER_PRINCIPAL_NAME}' user in Entra ID"
  az ad user create \
    --display-name "$USER_NAME" \
    --password "$USER_PASSWORD" \
    --user-principal-name "$USER_PRINCIPAL_NAME" \
    --force-change-password-next-sign-in false
else
  echo "'${USER_PRINCIPAL_NAME}' user already exist"
fi

# Check and create user group in Entra ID if not exist
az ad group show --group $AD_GROUP_NAME &>/dev/null
if [ $? -ne 0 ]; then
  echo "Creating '$AD_GROUP_NAME' group in Entra ID" 
  az ad group create \
    --display-name "$AD_GROUP_NAME" \
    --mail-nickname "$AD_GROUP_NAME"
else
    echo "'${AD_GROUP_NAME}' AD group already exist"
fi

# Check and add user to group if it is not a member
user_id=$(az ad user list \
  --filter "userPrincipalName eq '$USER_PRINCIPAL_NAME'" \
  --query "[].id" \
  -o tsv)
az ad group member check --group $AD_GROUP_NAME --member-id $user_id &>/dev/null
if [ $? -ne 0 ]; then
  echo "Add '$USER_PRINCIPAL_NAME' user to the '$AD_GROUP_NAME' group in Entra ID" 
  az ad group member add \
    --group "$AD_GROUP_NAME" \
    --member-id "$user_id"
else
    echo "'${USER_PRINCIPAL_NAME}' is a member of the '${AD_GROUP_NAME}' group"
fi

# Create resource group if not exist
az group show --name $RESOURCE_GROUP &>/dev/null
if [ $? -ne 0 ]; then
  echo "Creating missing '${RESOURCE_GROUP}' resource group"
  az group create \
    --name "$RESOURCE_GROUP" \
    --location "$LOCATION"
  echo "Waiting for resource group to be created"
  az group wait --created --name "$RESOURCE_GROUP"
else
    echo "'${RESOURCE_GROUP}' resource group already exist"
fi

# Create network security group if not exist
az network nsg show --resource-group "$RESOURCE_GROUP" --name "$NSG_NAME" &>/dev/null
if [ $? -ne 0 ]; then
  echo "Creating '${NSG_NAME}' network security group"
  az network nsg create \
    --resource-group "$RESOURCE_GROUP" \
    --name "$NSG_NAME" \
    --location "$LOCATION"
  echo "Waiting for virtual network to be created"
  az network nsg wait --created --name "$NSG_NAME" --resource-group "$RESOURCE_GROUP"
else
    echo "'${NSG_NAME}' network security group already exist"
fi

# Create vnet if not exist
az network vnet show --resource-group "$RESOURCE_GROUP" --name "$VNET_NAME" &>/dev/null
if [ $? -ne 0 ]; then
  echo "Creating '${VNET_NAME}' virtual network"
  az network vnet create \
    --name "$VNET_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --location "$LOCATION" \
    --address-prefixes "$ADDRESS_PREFIXES" \
    --subnet-name "$SUBNET_NAME" \
    --subnet-prefixes "$SUBNET_PREFIXES" \
    --network-security-group "$NSG_NAME"
  echo "Waiting for vnet to be created"
  az network vnet wait --created --name "$VNET_NAME" --resource-group "$RESOURCE_GROUP"
else
  echo "'${VNET_NAME}' virtual network already exist"
fi

# Enable network policy
echo "Enable network policy"
az network vnet subnet update \
  --name "$SUBNET_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --vnet-name "$VNET_NAME" \
  --private-endpoint-network-policies "$PRIVATE_ENDPOINT_NETWORK_POLICIES"
echo "Waiting for vnet subnet to be updated"
az network vnet subnet wait --updated --name "$SUBNET_NAME" --resource-group "$RESOURCE_GROUP" --vnet-name "$VNET_NAME"

# Allow RDP connection if not exist
az network nsg rule show --resource-group "$RESOURCE_GROUP" --nsg-name "$NSG_NAME" --name "$NSG_RULE_NAME" &>/dev/null
if [ $? -ne 0 ]; then
  echo "Creating '${NSG_RULE_NAME}' nsg rule for '${NSG_NAME}'"
  az network nsg rule create \
    --name "$NSG_RULE_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --nsg-name "$NSG_NAME" \
    --priority "$NSG_RULE_PRIORITY" \
    --access "$NSG_RULE_ACCESS" \
    --description "$NSG_RULE_DESCRIPTION" \
    --destination-address-prefixes "$NSG_RULE_DESTINATION_ADDRESS_PREFIXES" \
    --destination-port-ranges "$NSG_RULE_DESTINATION_PORT_RANGES" \
    --protocol "$NSG_RULE_PROTOCOL" \
    --source-address-prefixes "$NSG_RULE_SOURCE_ADDRESS_PREFIXES" \
    --source-port-ranges "$NSG_RULE_SOURCE_PORT_RANGES"
  echo "Waiting for nsg RDS rule to be created"
  az network nsg rule wait --created --name "$NSG_RULE_NAME" --resource-group "$RESOURCE_GROUP" --nsg-name "$NSG_NAME"
else
  echo "'${NSG_RULE_NAME}' NSG rule already exist"
fi

# Create Virtual Machine if not exist
az vm show --resource-group "$RESOURCE_GROUP" --name "$VM_NAME" &>/dev/null
if [ $? -ne 0 ]; then
  echo "Creating ${VM_IMAGE} VM"
  az vm create \
    --name "$VM_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --location "$LOCATION" \
    --admin-username "$ADMIN_USERNAME" \
    --admin-password "$ADMIN_PASSWORD" \
    --image "$VM_IMAGE" \
    --size "$VM_SIZE" \
    --vnet-name "$VNET_NAME" \
    --subnet "$SUBNET_NAME" \
    --nsg "$NSG_NAME" \
    --public-ip-address "$PUBLIC_IP_ADDRESS_NAME" \
    --nic-delete-option "$NIC_DELETE_OPTION" \
    --storage-sku "$STORAGE_SKU" \
    --os-disk-size-gb "$OS_DISK_SIZE_GB" \
    --ultra-ssd-enabled "$ULTRA_SSD_ENABLED" \
    --nsg-rule "$NSG_RULE" \
    --private-ip-address "$PRIVATE_IP_ADDRESS" \
    --accelerated-networking "$ACCELERATED_NETWORKING"
  # Wait for VM to be provisioned
  echo "Waiting while VM is to be created"
  az vm wait --created --resource-group "$RESOURCE_GROUP" --name "$VM_NAME"
else
  echo "'${VM_NAME}' VM already exist"
fi

# Add managed identity to VM if not exist
# Get the resource ID of the VM
vm_id=$(az vm show -g $RESOURCE_GROUP -n $VM_NAME --query "id" -o tsv)
# Check if managed identity is enabled for the VM
managed_identity=$(az vm identity show --ids $vm_id --query "principalId" -o tsv)
if [ -n "$managed_identity" ]; then
  echo "Managed identity exists for VM ${VM_NAME}"
else
  echo "Creating managed identity for VM ${VM_NAME}"
  az vm identity assign -g "$RESOURCE_GROUP" -n "$VM_NAME"
fi

# Install the Microsoft Entra login VM extension if not exist
az vm extension show \
  --resource-group "$RESOURCE_GROUP" \
  --vm-name "$VM_NAME" \
  --name "$ENTRA_EXTENSION" \
  --query "provisioningState" -o tsv &>/dev/null
if [ $? -ne 0 ]; then
  echo "Installing '${ENTRA_EXTENSION}' extension"
  az vm extension set \
    --publisher "Microsoft.Azure.ActiveDirectory" \
    --name "AADLoginForWindows" \
    --resource-group "$RESOURCE_GROUP" \
    --vm-name "$VM_NAME"
  # Wait for VM to be provisioned
  echo "Waiting while extension to be created"
  az vm extension wait --created --resource-group "$RESOURCE_GROUP" --name "$ENTRA_EXTENSION" --vm-name "$VM_NAME"
else
  echo "'${ENTRA_EXTENSION}' extension already exist for '$VM_NAME'"
fi

# Use object ID because the Microsoft Entra domain and login username domain can be different.
user_object_id=$(az ad user list --upn $USER_PRINCIPAL_NAME --query "[0].id" -o tsv)

# Set VM login right according the VM_ADMIN value
if [ "$VM_ADMIN" == true ]; then
  target_role="$VM_ADMIN_LOGIN_ROLE"
else
  target_role="$VM_USER_LOGIN_ROLE"
fi
subscription_id=$(az account show --query id -o tsv)
role_scope=$(az vm show --resource-group "$RESOURCE_GROUP" --name "$VM_NAME" --query id -o tsv)

role_assignment=$(az role assignment list --scope "/subscriptions/$subscription_id/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Compute/virtualMachines/$VM_NAME" --include-inherited --query "[?principalName=='$USER_PRINCIPAL_NAME' && roleDefinitionName=='$VM_ADMIN_LOGIN_ROLE']" -o tsv 2>/dev/null)

if [ -n "$role_assignment" ]; then
  echo "'${USER_PRINCIPAL_NAME}' user has the '${target_role}' role assignment on VM '$VM_NAME'"
else
  echo "Assign '${target_role}' role to the user '${USER_PRINCIPAL_NAME}' on VM '${VM_NAME}'"
  az role assignment create \
    --role "$target_role" \
    --assignee-object-id "$user_object_id" \
    --scope "$role_scope"
fi

echo "Configutation finished!"
