# azure-keyvault-things

![kv](https://user-images.githubusercontent.com/6472374/79210609-c91e2900-7e4d-11ea-9bd1-4b356714e2c1.png)

## Included Projects

* `dotnet` An ASP.NET (.NET Framework 4.7.2) application that calls Azure Key Vault in various ways, and an ASP.NET Core application that calls Key Vault with Dependency Injection.

* `TypeScript` Retrieves secrets and keys from Key Vault in TypeScript.

* `Go` Go code that calls Key Vault to retrieve secrets and and sign a digest with a HSM key.

* `Java` Sample code in Java that calls Key Vault to retrieve secrets and certificates.

* `Python` Python 3.x code that gets a secret from Key Vault. Applicable for Python 2.x as well.

* `Pascal` Free Pascal sample that uses raw HTTP calls to get an access token via Managed Identity and retrieve a secret from Key Vault.

* `REST` Sample REST API calls for retrieving secrets and keys. It also demonstrates sign and verify operations.


## Resources

* Azure Key Vault Developer's Guide &mdash; https://docs.microsoft.com/en-us/azure/key-vault/key-vault-developers-guide 

* Azure Key Vault REST API Reference &mdash; https://docs.microsoft.com/en-us/rest/api/keyvault/

* App Service Key Vault References &mdash; 
https://docs.microsoft.com/en-us/azure/app-service/app-service-key-vault-references

* Configuration in ASP.NET Core &mdash; https://docs.microsoft.com/en-us/aspnet/core/fundamentals/configuration/?view=aspnetcore-3.1#configuration-keys-and-values

* What are managed identities for Azure resources? &mdash; https://docs.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/overview


Get a Key Vault access token from an Azure VM with Managed Identity enabled - 
```bash

# You'll need curl and jq (sudo apt install curl jq -y)

# Test the token endpoint
 $ curl -s "http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https%3A%2F%2Fvault.azure.net" -H "Metadata: true"

You should see an access token being returned.
Note the resource for Key Vault is always https://vault.azure.net (URL encoded),
no trailing slash, no Key Vault instance name.

# Save the access token to a bash variable
$ TOKEN=$(curl -s "http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https%3A%2F%2Fvault.azure.net" -H "Metadata: true" | jq -r ".access_token")

# Get a secret from Key Vault
$ curl -s "https://alice.vault.azure.net/secrets/secret1?api-version=7.0" -H "Authorization: Bearer $TOKEN" | jq

{
  "value": "TH3 VALU3 0F THE S3CRE7",
  "contentType": "this_property_is/completely_arbitrary",
  "id": "https://alice.vault.azure.net/secrets/secret1/d96492d7b6d744a085a37c812badb3e4",
  "attributes": {
    "enabled": true,
    "created": 1526314127,
    "updated": 1526314127,
    "recoveryLevel": "Purgeable"
  }
}

```
Note that you don't need to do this dance if you use the Azure SDK in your application (Azure.Identity will get the access token for you).
