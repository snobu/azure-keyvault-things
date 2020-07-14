### Install dependencies
```go
go get github.com/logrusorgru/aurora
go get github.com/go-resty/resty
go get github.com/Azure/azure-sdk-for-go/services/keyvault/2016-10-01/keyvault
go get github.com/Azure/go-autorest/autorest
go get github.com/Azure/go-autorest/autorest/azure/auth
go get github.com/joho/godotenv
go get github.com/fatih/color
```

There's probably a much easier way to do that in Go, so do that instead
and maybe send a PR against this README as well.

Create an `.env` file with the following content. This should be in project root, so if you're building `secrets.go` it should go under `secrets/`:

```
AZURE_TENANT_ID=<Your tenant ID>
AZURE_CLIENT_ID=<Service principal client ID>
AZURE_CLIENT_SECRET=<Service principal secret>
```

If you're using this authorizer
```go
keyvaultAuthorizer, err := auth.NewAuthorizerFromCLIWithResource("https://vault.azure.net")
```
then you don't need the `.env` file, Azure CLI will fetch the access token for you.

### `secrets/secrets.go`
Fetches a secret from Key Vault
```go
cd secrets
go build
./secrets
```

### `sign/sign.go`
Signs a digest with a key retrieved from Key Vault.
```go
cd sign
go build
./sign
```
