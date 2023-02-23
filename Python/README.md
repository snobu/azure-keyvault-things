# Fetch secrets from Azure Key Vault in Python 3.x

## Usage

It will try Managed Credentials then fallback to Managed Credentials via `az` CLI, then fallback to `.env`.

For the last option, create an `.env` file with the following content:

```
AZURE_TENANT_ID=<Your tenant ID>
AZURE_CLIENT_ID=<Service principal client ID>
AZURE_CLIENT_SECRET=<Service principal secret>
```

Install dependencies and run:
```
pip install -r requirements.txt
python get_secrets.py
```
