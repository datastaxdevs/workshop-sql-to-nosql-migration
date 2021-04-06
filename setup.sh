echo "🚀    Go to https://astra.datastax.com/org/?create_service_account
If you have not created a service account for your org click Actions -> Add Service Account. Then, click the copy icon and paste your service account credentials here: "
  read -r SERVICE_ACCOUNT
  export SERVICE_ACCOUNT="${SERVICE_ACCOUNT}"

echo "🚀   Now, paste your database ID here: "
  read -r DB_ID
  export DB_ID="${DB_ID}"

echo "Getting your Astra DevOps API token..."
DEVOPS_TOKEN=$(curl -s --request POST \
  --url "https://api.astra.datastax.com/v2/authenticateServiceAccount" \
  --header 'content-type: application/json' \
  --data "$SERVICE_ACCOUNT" | jq -r '.token')

echo "Getting database by ID..."
DBbyID=$(curl -s --request GET \
  --url "https://api.astra.datastax.com/v2/databases/${DB_ID}?include=nonterminated&provider=all&limit=25" \
  --header "authorization: Bearer ${DEVOPS_TOKEN}" \
  --header 'content-type: application/json')

FIRST_DB_SECURE_BUNDLE_URL=$(echo "${DBbyID}" | jq -c '.info.datacenters[0].secureBundleUrl')
echo $FIRST_DB_SECURE_BUNDLE_URL

export ASTRA_SECURE_BUNDLE_URL=${FIRST_DB_SECURE_BUNDLE_URL}
gp env ASTRA_SECURE_BUNDLE_URL=${FIRST_DB_SECURE_BUNDLE_URL} &>/dev/null

# Download the secure connect bundle
curl -s -L $(echo $FIRST_DB_SECURE_BUNDLE_URL | sed "s/\"//g") -o astra-creds.zip

export ASTRA_DB_BUNDLE="astra-creds.zip"
gp env ASTRA_DB_BUNDLE="astra-creds.zip" &>/dev/null
