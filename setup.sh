echo "🚀     Go to https://astra.datastax.com and register or login
Select your database from the left panel
Click 'Settings' in the tab bar at the top.
From this screen, choose 'Database Administrator' in the Role selection and click 'Create Token'
What you need here is the third field, the 'Token'.  Copy that value and paste it here:"
  read -r ASTRA_DB_ADMIN_TOKEN
  export ASTRA_DB_ADMIN_TOKEN="${ASTRA_DB_ADMIN_TOKEN}"
  echo "[default]" > ~/.astrarc
  echo "ASTRA_DB_ADMIN_TOKEN=${ASTRA_DB_ADMIN_TOKEN}" >> ~/.astrarc

echo "🚀     What is the database ID you want to use?"
  read -r ASTRA_DB_ID
  export ASTRA_DB_ID="${ASTRA_DB_ID}"
  echo "ASTRA_DB_ID=${ASTRA_DB_ID}" >> ~/.astrarc


echo "Getting database by ID..."
DBbyID=$(curl -s --request GET \
  --url "https://api.astra.datastax.com/v2/databases/${ASTRA_DB_ID}?include=nonterminated&provider=all&limit=25" \
  --header "authorization: Bearer ${ASTRA_DB_ADMIN_TOKEN}" \
  --header 'content-type: application/json')

#http https://api.astra.datastax.com/v2/databases | jq '.[] | {id: .id, name: .info.name}'
#export DBbyID=$(http https://api.astra.datastax.com/v2/databases/${ASTRA_DB_ID} include==nonterminated provider==all limit==25)

FIRST_DB_SECURE_BUNDLE_URL=$(echo "${DBbyID}" | jq -c '.info.datacenters[0].secureBundleUrl')
echo $FIRST_DB_SECURE_BUNDLE_URL

export ASTRA_SECURE_BUNDLE_URL=${FIRST_DB_SECURE_BUNDLE_URL}
gp env ASTRA_SECURE_BUNDLE_URL=${FIRST_DB_SECURE_BUNDLE_URL} &>/dev/null

# Download the secure connect bundle
echo "Downloading secure bundle astra-creds.zip"
curl -s -L $(echo $FIRST_DB_SECURE_BUNDLE_URL | sed "s/\"//g") -o astra-creds.zip

export ASTRA_DB_BUNDLE="astra-creds.zip"
gp env ASTRA_DB_BUNDLE="astra-creds.zip" &>/dev/null

echo "Yay! You should now have an astra-creds.zip secure bundle. Later on in the DSBulk portion you will use this file to connect to your Astra database."
