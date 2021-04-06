echo "🚀   Paste your CLIENT ID here: "
  read -r CLIENT_ID
  export CLIENT_ID="${CLIENT_ID}"

echo "🚀   Paste your CLIENT SECRET here: "
  read -r CLIENT_SECRET
  export CLIENT_SECRET="${CLIENT_SECRET}"


dsbulk-1.8.0/bin/dsbulk load \
-url owner.csv \
-b astra-creds.zip \
-u ${CLIENT_ID} \
-p ${CLIENT_SECRET} \
-query "INSERT INTO spring_petclinic.petclinic_owner (first_name, last_name, address, city, telephone, id) VALUES (:first_name,:last_name,:address,:city,:telephone,UUID())" \
-header true \
-delim ';'
