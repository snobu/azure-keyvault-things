# Fetch secrets from Azure Key Vault in Python 3.x

Should work for Python 2.x as well, just rewrite the print statements.

## Usage

Create an `.env` file with the following content:

```
AZURE_TENANT_ID=<Your tenant ID>
AZURE_CLIENT_ID=<Service principal client ID>
AZURE_CLIENT_SECRET=<Service principal secret>
```

Install dependencies and run:
```
pip install -r requirements.txt
python secrets.py
```