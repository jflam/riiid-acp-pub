resourceGroupName="ez-workspace-rg"
storageAccountName="jflamezstorage"
fileShareName="ezdata"

# mntRoot="/mount"
# mntPath="$mntRoot/$storageAccountName/$fileShareName"
mntPath="/home/jlam/src/riiid-acp-pub/input/share"

sudo mkdir -p $mntPath

# This command assumes you have logged in with az login
httpEndpoint=$(az storage account show \
    --resource-group $resourceGroupName \
    --name $storageAccountName \
    --query "primaryEndpoints.file" | tr -d '"')
smbPath=$(echo $httpEndpoint | cut -c7-$(expr length $httpEndpoint))$fileShareName

storageAccountKey=$(az storage account keys list \
    --resource-group $resourceGroupName \
    --account-name $storageAccountName \
    --query "[0].value" | tr -d '"')

sudo mount -t cifs $smbPath $mntPath -o username=$storageAccountName,password=$storageAccountKey,serverino,uid=jlam,file_mode=0777,dir_mode=0777
