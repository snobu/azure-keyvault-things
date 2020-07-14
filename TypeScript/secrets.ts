import * as dotenv from "dotenv";

import { DefaultAzureCredential, InteractiveBrowserCredential } from '@azure/identity';
import { SecretClient } from '@azure/keyvault-secrets';
import { KeyClient } from '@azure/keyvault-keys';

async function main() {
    dotenv.config();
    const keyVaultName = 'alice';
    const KVUri = 'https://' + keyVaultName + '.vault.azure.net';

    // DefaultAzureCredential first checks environment variables for configuration:
    // AZURE_TENANT_ID, AZURE_CLIENT_ID, AZURE_CLIENT_SECRET
    // If environment configuration is incomplete/missing, it will try to get an
    // acccess token via Managed Identity.
    // https://docs.microsoft.com/en-us/azure/key-vault/secrets/quick-create-node#set-environmental-variables
    const credential = new DefaultAzureCredential();

    // InteractiveBrowserCredential is not supported in Node.js
    // const credential = new InteractiveBrowserCredential();
    
    const secretClient = new SecretClient(KVUri, credential);
    const secretName = 'secret1';
    const secret = await secretClient.getSecret(secretName);

    console.log('Your secret is:\n---------------');
    console.log(`Secret name: ${secret.name}`);
    console.log(`Value: ${secret.value}`);
    console.log('Properties:', secret.properties);
    console.log();

    const keyClient = new KeyClient(KVUri, credential);
    const keyName = 'ec-key-in-hsm';
    const key = await keyClient.getKey(keyName);

    console.log('Your key is:\n------------');
    console.log(`Key name: ${key.name}`);
    console.log(`Key operations: ${key.keyOperations}`);
    console.log(`Key type: ${key.keyType}`);
    console.log('Properties:', key.properties);
}

main()