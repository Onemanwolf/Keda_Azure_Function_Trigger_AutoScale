$Location='eastus'
$ResourceGroup='hello-keda'
$StorageAccountName='jsqueue01js'
$QueueName='js-queue-items'
$AKSName='aks-hello-keda'



## Create a resource group
az group create -l $Location -n $ResourceGroup
## Create a storage account
az storage account create --sku Standard_LRS --location $Location -g $ResourceGroup -n $StorageAccountName
## Connection string variable
$CONNECTION_STRING=$(az storage account show-connection-string --name $StorageAccountName --query connectionString)
## Create a queue
az storage queue create -n $QueueName --connection-string $CONNECTION_STRING
## Get Connection String
az storage account show-connection-string --name $StorageAccountName --query connectionString
## Create a AKS Cluster
az aks create --resource-group $ResourceGroup --name $AKSName --location $Location --node-count 1 --generate-ssh-keys
az aks get-credentials --name $AKSName --resource-group $ResourceGroup
echo $CONNECTION_STRING
helm repo add "stable" "https://charts.helm.sh/stable" --force-update
## Install KEDA into cluster
## Add Keda to your local repo 
helm repo add kedacore https://kedacore.github.io/charts
## Update helm repo 
helm repo update
## Install KEDA
## Create namespace keda
kubectl create namespace keda
## Install KEDA Pacakge
helm install keda kedacore/keda --version 2.0.0 --namespace keda

## Verify Installation
kubectl get customresourcedefinition

## Login to Container Registry 
docker login

## Push image to Container Registry
func kubernetes deploy --name hello-keda --registry timo1

## Create Deployment Yaml to modify
func kubernetes deploy --name hello-keda --registry timo1 --javascript --dry-run > deploy.yaml

## Build the image
docker build -t timo1/hello-keda .

#Push the image to the Container Registry
docker push timo1/hello-keda
# Deploy the image to AKS
kubectl apply -f deploy.yaml
kubectl delete -f deploy.yaml
kubectl get deploy

kubectl get pods -w

kubectl logs hello-keda-85c5b4cf57-fzmp9


az aks nodepool scale --node-count 3 --name nodepool1 --resource-group $ResourceGroup --cluster-name $AKSName

az aks show -g $ResourceGroup -n $AKSName > aks.json

$WORKSPACE='aksworkshop-workspacekeda001'

az resource create --resource-type Microsoft.OperationalInsights/workspaces --name $WORKSPACE --resource-group $RESOURCEGROUP  --location $Location --properties '{}' -o table

$WORKSPACE_ID=$(az resource show --resource-type Microsoft.OperationalInsights/workspaces --resource-group $RESOURCEGROUP --name $WORKSPACE --query "id" -o tsv)
az aks enable-addons --resource-group $RESOURCEGROUP --name $AKSName --addons monitoring --workspace-resource-id $WORKSPACE_ID


kubectl logs hello-keda-85c5b4cf57-9txzt -c hello-keda








## UNINSTALL KEDA Remove from you cluster
helm uninstall -n keda keda
kubectl delete -f https://raw.githubusercontent.com/kedacore/keda/v2.0.0/config/crd/bases/keda.sh_scaledobjects.yaml
kubectl delete -f https://raw.githubusercontent.com/kedacore/keda/v2.0.0/config/crd/bases/keda.sh_scaledjobs.yaml
kubectl delete -f https://raw.githubusercontent.com/kedacore/keda/v2.0.0/config/crd/bases/keda.sh_triggerauthentications.yaml

