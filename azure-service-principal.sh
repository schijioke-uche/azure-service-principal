#@Author: Jeffrey Chijioke-Uche
#@Company: IBM
#@Usage: Azure + Terraform

#INSTALL:  AZ CLI(WINDOWS)  https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-windows?tabs=azure-cli
#INSTALL:  AZ CLI (LINUX)   https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-linux?pivots=apt

function azLogin(){
   az login 
}


# IBM Trigger v3.4.0
function azureServicePrincipal(){
    while true; do
        read -p "Do You Wish to login to Your Azure Account? [y|n] " yn
        case $yn in
            [Yy]* )  break;;
            [Nn]* )  break;;  
            * ) echo "Please answer yes or no.";;
        esac
    done
    #Login to your Azure Account && Configure Service Principal.
    if [[ $yn == "n" || $yn == "N" || $yn == "No" || $yn == "no" || $yn == "NO" ]]
    then
         indiCators
         echo "Ok, thats fine, you said that you do not need to sign-in to Azure account at this time!"
         echo "Checking to ensure that you are already signed-in to Azure."
         CheckState
         servicePrincipal
         exportIDs
    elif [[ $yn == "y" || $yn == "Y" || $yn == "Yes" || $yn == "yes" || $yn == "YES" ]]
    then
         indiCators
         echo "Ok, follow the browser prompt to sign-in to your Azure account!"
         echo "Remember to return to this terminal after signing in to Azure."
         azLogin
         CheckState
         servicePrincipal
         exportIDs
    else
         echo "No matching Response!"
         exit;
    fi
}


function configRun(){
  azureServicePrincipal
}

function servicePrincipal(){
RAND=$((1 + $RANDOM % 13455533234))
APP_NAME="mySvcPr-$RAND"
SUBSCRIPTION_ID=$(az account show --query id --output tsv)
SVCP=$(az ad sp create-for-rbac -n $APP_NAME --role Contributor --scopes /subscriptions/$SUBSCRIPTION_ID --output json --only-show-errors)
APP_ID=$(echo $SVCP | jq -r .appId)
OBJ_ID=$(az ad sp list --filter "appId eq '$APP_ID'" --output json | jq '.[0].objectId' -r)
PASS_ID=$(echo $SVCP | jq -r .password)
TENANT_ID=$(echo $SVCP | jq -r .tenant)
echo "Creating Role assinment.."
az role assignment create --role "User Access Administrator" --assignee-object-id $OBJ_ID --only-show-errors
CheckState
echo "Listing Role Assignment..."
az role assignment list --assignee $APP_ID --query [].roleDefinitionName --output json --only-show-errors
}


function exportIDs(){
    reportBar
    export ARM_CLIENT_ID=${APP_ID}
    export ARM_CLIENT_SECRET=${PASS_ID}
    export ARM_TENANT_ID=${TENANT_ID}
    export ARM_SUBSCRIPTION_ID=${SUBSCRIPTION_ID}
    echo "APP NAME:  $APP_NAME"
    echo "CLIENT ID:  ${APP_ID}"
    echo "CLIENT SECRET:  ${PASS_ID}"
    echo "TENANT ID:  ${TENANT_ID}"
    echo "USER OR APP PRINCIPAL OBJECT ID: $OBJ_ID"
    echo "SUBSCRIPTION ID: ${SUBSCRIPTION_ID}"
    azure
}


function CheckState(){
sleep 12s & PID=$! 
echo -e "${CYAN}Checking, please wait....${NOCOLOR}"
printf "["
while kill -0 $PID 2> /dev/null; do 
    printf  "${GREEN}|||||||"
    sleep 2
done
printf "done!${NOCOLOR}]" 
echo -e ""
}


function indiCators(){
  NOCOLOR='\033[0m'
  RED='\033[0;31m'
  GREEN='\033[0;32m'
  ORANGE='\033[0;33m'
  BLUE='\033[0;34m'
  PURPLE='\033[0;35m'
  CYAN='\033[0;36m'
  LIGHTGRAY='\033[0;37m'
  DARKGRAY='\033[1;30m'
  LIGHTRED='\033[1;31m'
  LIGHTGREEN='\033[1;32m'
  YELLOW='\033[1;33m'
  LIGHTBLUE='\033[1;34m'
  LIGHTPURPLE='\033[1;35m'
  LIGHTCYAN='\033[1;36m'
  WHITE='\033[1;37m'
}


function reportBar(){
  echo -ne '"[||||||||                     (33%)\r'
  sleep 1
  echo -ne '[||||||||||||||||||||]             (66%)\r'
  sleep 2
  echo -ne ${GREEN} '[||||||||||||||||||||||||||||||||||||]  (100%) completed! \r' ${NOCOLOR}
  echo -ne '\n'
}


function azure(){
  echo -e "${GREEN}Azure Cloud Configuration Completed!${NOCOLOR}"
  echo -e "${GREEN}
    /---\   M I C R O S O F T    A Z U R E                             
   /  _  \ __________ _________   ____  
  /  /_\  \\___   /  |  \_  __ \_/ __ \ 
 /    |    \/    /|  |  /|  | \/\  ___/ 
 \____|__  /_____ \____/ |__|    \___  >
        \/      \/                  \/ 
 A Z U R E   I N F R A S T R U C T U R E  AS  C O D E    P  R  E-R  E  Q ${NOCOLOR}"
}
#Exec::::::::::::::::::::::#
configRun
#Exec::::::::::::::::::::::#