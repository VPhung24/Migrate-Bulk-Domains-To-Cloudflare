#!/usr/bin/env sh

if [ ! -s config.txt ]; then
    echo "Error: config.txt does not exist. Please use config.example.txt as a template."
    exit 1
fi

source ./config.txt

# Check if domains.txt exists and is not empty
if [ ! -s domains.txt ]; then
    echo "Error: domains.txt is empty or does not exist."
    exit 1
fi

for domain in $(cat domains.txt); do
    printf "Adding ${domain}:\n"

    curl https://api.cloudflare.com/client/v4/zones \
        -H "Content-Type: application/json" \
        -H "X-Auth-Email: $CLOUDFLARE_EMAIL" \
        -H "X-Auth-Key: $CLOUDFLARE_API_KEY" \
        --data '{
      "account": {
        "id": "'"$CLOUDFLARE_ACCOUNT_ID"'"
      },
      "name": "'"$domain"'",
      "type": "full"
    }'
done
