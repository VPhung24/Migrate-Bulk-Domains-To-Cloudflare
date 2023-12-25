#!/usr/bin/env sh
source ./config.txt

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

    printf "\n\n"
done
