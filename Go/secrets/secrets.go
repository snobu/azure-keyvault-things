// Code heavily borrowed from brennerm on GitHub
// https://github.com/brennerm/azure-keyvault-external-secret/tree/master/keyvault

package main

import (
	"context"
	"fmt"
	"time"
	"os"

	"github.com/Azure/azure-sdk-for-go/services/keyvault/2016-10-01/keyvault"
	"github.com/Azure/go-autorest/autorest"
	"github.com/Azure/go-autorest/autorest/azure/auth"
	"github.com/joho/godotenv"
	"github.com/fatih/color"
)

type KeyVaultClient struct {
	client keyvault.BaseClient
}

func getKeyvaultAuthorizer() (autorest.Authorizer, error) {
	// See this for more on authentication:
	// https://github.com/Azure/azure-sdk-for-go#more-authentication-details
	//
	// This requires exporting AZURE_AD_RESOURCE="https://vault.azure.net" as env var:
	// keyvaultAuthorizer, err := auth.NewAuthorizerFromCLI()
	//
	// This doesn't require any env vars and uses azure-cli to get an access token
	// keyvaultAuthorizer, err := auth.NewAuthorizerFromCLIWithResource("https://vault.azure.net")
	//
	// This requires exporting a bunch of env vars:
	// AZURE_TENANT_ID: Specifies the Tenant to which to authenticate.
	// AZURE_CLIENT_ID: Specifies the app client ID to use.
	// AZURE_CLIENT_SECRET: Specifies the app secret to use.
	// More at https://github.com/Azure/azure-sdk-for-go#more-authentication-details
	keyvaultAuthorizer, err := auth.NewAuthorizerFromEnvironmentWithResource("https://vault.azure.net")

	return keyvaultAuthorizer, err
}

func NewKeyVaultClient() (KeyVaultClient, error) {
	a, err := getKeyvaultAuthorizer()
	if err != nil {
		color.Red("Failed to get KeyVault Authorizer: %+v")
		panic(err.Error())
	}

	keyVaultClient := KeyVaultClient{
		client: keyvault.New(),
	}

	keyVaultClient.client.Authorizer = a

	return keyVaultClient, err
}

func (c *KeyVaultClient) GetSecret(vaultURL string, name string) (string, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	// Either specify the secret version after the name
	// or pass in "" for latest version
	bundle, err := c.client.GetSecret(ctx, vaultURL, name, "")
	if err != nil {
		return "", fmt.Errorf("Failed to get secret %s: %+v", name, err.Error())
	}

	return *bundle.Value, nil
}

func main() {
	err := godotenv.Load()
	if err != nil {
		color.Red("Error loading .env file")
	}
	fmt.Println("Loaded .env file.")
	keyVaultClient, err := NewKeyVaultClient()
	if err != nil {
		color.Red("Failed to create Key Vault Client: %+v", err)
	}

	secret, err := keyVaultClient.GetSecret("https://alice.vault.azure.net", "secret1")
	if err != nil {
		color.Red("Failed to fetch secret: %+v")
		panic(err)
	}
	fmt.Println("Value of secret is: " + color.GreenString(secret))
}
