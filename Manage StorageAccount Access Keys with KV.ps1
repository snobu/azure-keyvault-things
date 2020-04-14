#Manage Access Keys for a Storage Account with KV

#Variables
$location = "eastus"
$id = Get-Random -Minimum 1000 -Maximum 9999
$prefix = "demo"
$username = "username@domain.com"

#Log into Azure
$Credential=Get-Credential -UserName $username
Add-AzAccount -Credential $Credential

#Select the correct subscription
Get-AzSubscription -SubscriptionName "Azure Subscription Name" | Select-AzSubscription

#KeyVault Parameters - needs to be customized
$keyVaultParameters = @{
    Name = "AKVES"
    ResourceGroupName = "test"
    Location = $location
    Sku = "Premium"
}

#Create a new storage account
$saAccountParameters = @{
    Name = "$($prefix)sa$id"
    ResourceGroupName = $keyVaultParameters.ResourceGroupName
    Location = $location
    SkuName = "Standard_LRS"
}

$storageAccount = New-AzStorageAccount @saAccountParameters

Get-AzStorageAccountKey -ResourceGroupName $storageAccount.ResourceGroupName -Name $storageAccount.StorageAccountName

$keyVaultSpAppId = "cfa8b339-82a2-471a-a3c9-0fc0be7a4093"

New-AzRoleAssignment -ApplicationId $keyVaultSpAppId -RoleDefinitionName 'Storage Account Key Operator Service Role' -Scope $storageAccount.Id

Set-AzKeyVaultAccessPolicy -VaultName $keyVaultParameters.Name -UserPrincipalName 'elcioban@microsoft.com' -PermissionsToStorage get, list, delete, set, update, regeneratekey, getsas, listsas, deletesas, setsas, recover, backup, restore, purge

# Add your storage account to your Key Vault's managed storage accounts
$managedStorageAccount = @{
    VaultName = $keyVaultParameters.Name
    AccountName = $storageAccount.StorageAccountName
    AccountResourceId = $storageAccount.Id
    ActiveKeyName = "key1"
    RegenerationPeriod = [System.Timespan]::FromDays(90)
}

Add-AzKeyVaultManagedStorageAccount @managedStorageAccount

Get-AzKeyVaultManagedStorageAccount -VaultName $keyVaultParameters.Name

Update-AzKeyVaultManagedStorageAccountKey -VaultName $keyVaultParameters.Name -AccountName $storageAccount.StorageAccountName -KeyName "key1"

