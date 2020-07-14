## This sample demonstrates retrieving a secret from Azure Key Vault using the Azure SDK for Java.

![](hello-java.jpg)
<small><i>Artist's interpretation of developing in Java. The artist apologizes.</i></small>

[`DefaultAzureCredential`][1] is used to pick up a service principal from env vars when developing locally.
When running in Azure, it will try to use Managed Identity if enabled (no need to provide secrets in this case).

See this for more:
https://github.com/Azure/azure-sdk-for-java/tree/master/sdk/identity/azure-identity#key-concepts

To develop locally create a `.env` file with the following content:

```
AZURE_TENANT_ID=<Your tenant ID>
AZURE_CLIENT_ID=<Service principal client ID>
AZURE_CLIENT_SECRET=<Service principal secret>
```

This is later used by `make run` to populate those environment variables before booting the application.

Of course you can define those variables manually should you choose to do so. `make run` won't be able to pick them up in this case, however you can simply invoke `java -jar <path_to_jar>` instead (do make sure it's in the same terminal session).

### Build .jar
```
$ make build
```

### Run the application

```
$ make run
```


[1]: https://github.com/Azure/azure-sdk-for-java/tree/master/sdk/identity/azure-identity#defaultazurecredential
