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
