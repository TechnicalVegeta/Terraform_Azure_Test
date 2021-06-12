# Configure the Azure varialbe values
subscription_id = "xxxxx-xxxx-xxxx-xxxx-xxxxxxxxxx"
client_id       = "{applicationId}"
client_secret   = "{applicationSecret}"
tenant_id       = "xxxxx-xxxx-xxxx-xxxx-xxxxxxxxxx"
rg_name         = "AzureTest-RG"
location        = "West Europe"
prefix          = "AzureTest"


# Network Settings
nics = [
    "10.0.0.4",
    "10.0.1.4"
]
vnet_prefix = ["10.0.0.0/16"]
subnet_prefixes = [
    "10.0.0.0/24",
    "10.0.1.0/24"
]


