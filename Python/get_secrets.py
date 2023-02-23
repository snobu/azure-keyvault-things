#!/usr/bin/env python3

import json
import os
from azure.identity import DefaultAzureCredential, InteractiveBrowserCredential
from azure.keyvault.secrets import SecretClient
from dotenv import load_dotenv

load_dotenv(verbose=True)

# Use InteractiveBrowserCredential() if you want to
# login interactively for an access token
# credential = InteractiveBrowserCredential()

# Use DefaultAzureCredential() for automatic fallback:
# env vars, Managed Identity
credential = DefaultAzureCredential()

secret_client = SecretClient(vault_url="https://alice.vault.azure.net/", credential=credential)

secret = secret_client.get_secret("secret1")

print(f'\n  Name: {secret.name}')
print(f'  Value: {secret.value}')
print(f'  Enabled: {secret.properties.enabled}')
print(f'  Content type: {secret.properties.content_type}')
print(f'  Expires: {secret.properties.expires_on}')
print(f'  Version: {secret.properties.version}')
print(f'  Vault URL: {secret.properties.vault_url}\n')
