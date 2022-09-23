#-------------------------------------------------------------------------------------------------------------
#       AUTHOR:  JEFFREY CHIJIOKE-UCHE, DIT, MSIT, MSIS, DS
#       USAGE: AZURE PLATFORM
#       AUTHOR INITIAL CREATION:  AUG 31, 2017
#       LAST UPDATED:  SEP. 1, 2022
#       COMPANY:  IBM
#--------------------------------------------------------------------------------------------------------------

# Given the client ID and tenant ID for an app registered in Azure,
# along with a refresh token, provide a new Azure AD access token and
# refresh token.

# If the caller is not already signed in to Azure, the caller's
# web browser will prompt the caller to sign in first.

# pip install msal
from msal import PublicClientApplication
import sys

# You can hard-code the registered app's client ID, tenant ID,
# and refresh token here, or you can provide them as command-line
# arguments to this script.
client_id = '<client-id>'
tenant_id = '<refresh-token'
refresh_token = '<refresh-token>'

# Do not modify this variable. It represents the programmatic ID for
# Azure Databricks along with the default scope of '.default'.
scope = [ '2ff814a6-3304-4ab8-85cb-cd0e6f879c1d/.default' ]

# Check for too few or too many command-line arguments.
if (len(sys.argv) > 1) and (len(sys.argv) != 4):
    print("Usage: refresh-tokens.py <client ID> <tenant ID> <refresh token>")
    exit(1)

# If the registered app's client ID, tenant ID, and refresh token are
# provided as command-line variables, set them here.
if len(sys.argv) > 1:
    client_id = sys.argv[1]
    tenant_id = sys.argv[2]
    refresh_token = sys.argv[3]

app = PublicClientApplication(
    client_id = client_id,
    authority = "https://login.microsoftonline.com/" + tenant_id
)

acquire_tokens_result = app.acquire_token_by_refresh_token(
    refresh_token = refresh_token,
    scopes = scope
)

if 'error' in acquire_tokens_result:
    print("Error: " + acquire_tokens_result['error'])
    print("Description: " + acquire_tokens_result['error_description'])
else:
    print("\nNew access token:\n")
    print(acquire_tokens_result['access_token'])
    print("\nNew refresh token:\n")
    print(acquire_tokens_result['refresh_token'])