#
# Constant variables for deployment
# 

# Main variables
DOMAIN_NAME="XXX.onmicrosoft.com"
TENANT_ID="XXX"
RESOURCE_GROUP="RG1"
LOCATION="swedencentral"

# VM variables
VM_NAME="VMTest1"
ADMIN_USERNAME="adminuser"
ADMIN_PASSWORD="P@ssw0rd12345"
VM_SIZE="Standard_B1s"
VM_IMAGE="MicrosoftWindowsDesktop:Windows-10:win10-22h2-pro:19045.4170.240307"
VNET_NAME="VMTest1-vnet"
ADDRESS_PREFIXES="10.0.0.0/16"
SUBNET_NAME="default"
SUBNET_PREFIXES="10.0.0.0/24"
PRIVATE_IP_ADDRESS="10.0.0.10"
PUBLIC_IP_ADDRESS_NAME=""
NSG_NAME="VMTest1-nsg"
NSG_RULE="RDP"
STORAGE_SKU="StandardSSD_LRS"
OS_DISK_SIZE_GB="127"
ACCELERATED_NETWORKING=false
NIC_DELETE_OPTION="Delete"
ULTRA_SSD_ENABLED=false
ENTRA_EXTENSION="AADLoginForWindows"

# User variables
USER_NAME="testuser"
USER_PASSWORD="P@ssw0rd12345"
USER_DISPLAY_NAME="Test User"
USER_PRINCIPAL_NAME="${USER_NAME}@${DOMAIN_NAME}"
AD_GROUP_NAME="test-gr"
VM_ADMIN=true
VM_ADMIN_LOGIN_ROLE="Virtual Machine Administrator Login"
VM_USER_LOGIN_ROLE="Virtual Machine User Login"

# network policy enable/disable
PRIVATE_ENDPOINT_NETWORK_POLICIES="Enabled"

# network security group rule
NSG_RULE_NAME="RDP"
NSG_RULE_PRIORITY=300
NSG_RULE_ACCESS="Allow"
NSG_RULE_DESCRIPTION="Allow RDP connection from all IP"
NSG_RULE_DESTINATION_ADDRESS_PREFIXES="*"
NSG_RULE_DESTINATION_PORT_RANGES="3389"
NSG_RULE_PROTOCOL="Tcp"
NSG_RULE_SOURCE_ADDRESS_PREFIXES="*"
NSG_RULE_SOURCE_PORT_RANGES="*"

# Temporary value of Readonly variables given by the program
DIST_NAME=""
OS_VERSION=""
MAIN_VERSION=""
AZ_CLI_INTALLED=false