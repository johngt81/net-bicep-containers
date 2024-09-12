
## Step1: Create Infrastructure
## step2: CI: Build Container Image
## step3: CD: Deploy Container Image to Container App


# Create Resource Group
az group create -g weather-app-resource-group -l northcentralus

# Create Container Registry
az deployment group create --resource-group weather-app-resource-group --template-file registry.bicep

# Create Container App
az deployment group create --resource-group weather-app-resource-group --template-file containerapp2.bicep

-----------------------------
# Create Resource Group
az group create -g weather-app-resource-group3 -l northcentralus

# Create Container Registry
az deployment group create --resource-group weather-app-resource-group3 --template-file registry.bicep

az deployment group create --resource-group weather-app-resource-group3 --template-file containerapp3.bicep






