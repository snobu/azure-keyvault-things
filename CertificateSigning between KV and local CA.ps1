#CertificateSigning between KV and local CA
#This script is creating a .csr in KV. Use openssl to request and sign a certificate using this .csr. Upload the signed cert in KV

#Variables
$prefix = "demo"
$location = "eastus"
$id = Get-Random -Minimum 1000 -Maximum 9999
$username = "username@domain.com"
$vaultName = "AKVES"

#Log into Azure
$Credential=Get-Credential -UserName $username
Add-AzAccount -Credential $Credential


#Select the correct subscription
Get-AzSubscription -SubscriptionName "Azure Subscription Name" | Select-AzSubscription


$keyVaultParameters = @{
    Name = $vaultName
    ResourceGroupName = $keyVaultGroup.ResourceGroupName
    Location = $location
    Sku = "Premium"
}


$policyParameters = @{
    SecretContentType = "application/x-pkcs12"
    SubjectName = "CN=www.domain.xyz"
    IssuerName = "Unknown"
    ValidityInMonths = 6
}

$policy = New-AzKeyVaultCertificatePolicy @policyParameters

$certRequest = Add-AzKeyVaultCertificate -VaultName $keyVault.VaultName -Name "Testing-www-cert" -CertificatePolicy $policy

#Create the CSR file that we will sign as a certificate and send back to Key Vault
$inFile = ".\Testing-www-cert.csr"
$outFile = ".\Testing-www-cert.pem"

Add-Content -Path $inFile -Value "-----BEGIN CERTIFICATE REQUEST-----" -Encoding Ascii
Add-Content -Path $inFile -Value $certRequest.CertificateSigningRequest -Encoding Ascii
Add-Content -Path $inFile -Value "-----END CERTIFICATE REQUEST-----" -Encoding Ascii

#Create a local Certificate Authority using openssl
$SUBJECT = "/C=RO/ST=Bucharest/L=Greenfield/O=Microsoft, Inc./OU=IT/CN=Domain"

#Create a CA key
openssl genrsa -out ca.key.pem 4096

#Creata a CA certificate
openssl req -key ca.key.pem -new -x509 -days 7300 -sha256 -out ca.cert.pem -extensions v3_ca -subj $SUBJECT

#Create the certificate from the request
openssl x509 -req -days 180 -CA ca.cert.pem -CAkey ca.key.pem -CAcreateserial -in $inFile -out $outFile

#Import the certificate back to Key Vault
Import-AzKeyVaultCertificate -VaultName $keyVault.VaultName -Name "Testing-www-cert" -FilePath $outFile