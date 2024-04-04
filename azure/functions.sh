#
# Functions 
# 

#######################################
# Get OS informations
# Globals:
#   DIST_NAME
#   OS_VERSION
#   MAIN_VERSION
# Arguments: None
# DIST_NAME is the first part of the name like CentOS, Red, Ubuntu, Debian
#######################################
get_os_info() {
  release_info=$(cat /etc/*-release 2>/dev/null)

  if [ -n "$release_info" ]; then
    DIST_NAME=$(echo "${release_info}" | grep -m 1 "^NAME=" | cut -d '"' -f 2 | awk '{print $1}')

    OS_VERSION=$(echo "${release_info}" | grep -m 1 "^VERSION_ID=" | cut -d '"' -f 2)

    MAIN_VERSION=$(echo "${OS_VERSION}" | cut -d '.' -f 1)    
    
    if [ -z "$DIST_NAME" ]; then
      DIST_NAME=$(echo "${release_info}" | grep -m 1 "^PRETTY_NAME=" | cut -d '"' -f 2 | awk '{print $1}')
    fi
    readonly DIST_NAME
    readonly OS_VERSION
    readonly MAIN_VERSION
    echo "Local Distribution: ${DIST_NAME}"
    echo "Local OS version: ${OS_VERSION}"
  fi
}

#######################################
# Install Azure CLI and check installation status on:
#   Ubuntu	20, 22
#   Debian  10, 11, 12
#   CentOS  8, 9
#   Redhat  8, 9
# Globals:
#   AZ_CLI_INTALLED
# Arguments: None
#######################################
install_cli() {
  echo "CLI is installing..."

  #   Ubuntu	20.04 LTS, 22.04, Debian 10, 11, 12
  if [[ ("$DIST_NAME" == "Ubuntu" && ( "$MAIN_VERSION" == "20" || "$MAIN_VERSION" == "22" ) ) || \
        ( "$DIST_NAME" == "Debian" && \
        ( "$MAIN_VERSION" == "10" || "$MAIN_VERSION" == "11" || "$MAIN_VERSION" == "12" ) ) ]]; then

    echo "Instlling ubuntu-debian version"
    curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
  fi

  # RHEL 8, 9, CentOS 8, 9
  if [[ ("$DIST_NAME" == "Red" || "$DIST_NAME" == "CentOS" ) && \
        ( "$MAIN_VERSION" == "8" || "$MAIN_VERSION" == "9" ) ]]; then

    echo "Instlling redhat-centos version"

    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
    local version=$(cat /etc/centos-release | cut -d ' ' -f 4 | cut -d '.' -f 1)

    sudo dnf install -y https://packages.microsoft.com/config/rhel/$version/packages-microsoft-prod.rpm

    sudo dnf install azure-cli -y
  fi

  if [ -z "$(which az)" ]; then
    echo "Azure CLI not installed"
    AZ_CLI_INTALLED=false
  else
    echo "Azure CLI installed"
    AZ_CLI_INTALLED=true
  fi
}

#######################################
# Check is CLI installed on host machine, ask to install if not, call install_cli
# function and set AZ_CLI_INTALLED variable value and make it readonly.
# Globals:
#   AZ_CLI_INTALLED
# Arguments:
#   None
#######################################
check_cli() {
    if [ -z "$(which az)" ]; then
    echo "Azure CLI not found"
    while [ -z $prompt ];
      do read -p "Would like to install Azure CLI (y/n)?" choice;
      case "$choice" in
        y|Y) install_cli; break ;;
        n|N) break ;;
      esac;
    done;
  else
    echo "Azure CLI found"
    AZ_CLI_INTALLED=true
    readonly AZ_CLI_INTALLED
  fi
}