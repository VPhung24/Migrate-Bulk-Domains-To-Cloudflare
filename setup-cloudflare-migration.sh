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

domains_info=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones?per_page=500" \
    -H "Content-Type: application/json" \
    -H "X-Auth-Email: $CLOUDFLARE_EMAIL" \
    -H "X-Auth-Key: $CLOUDFLARE_API_KEY")

echo "Domain,Zone ID,Name Server 1,Name Server 2,DNSSEC Algorithm,DNSSEC Digest,DNSSEC Digest Type,DNSSEC Key Tag" >./domain_nameservers.csv

echo "$domains_info" | jq -r '.result[] | @base64' | while IFS= read -r domain_encoded; do
    _jq() {
        echo "${domain_encoded}" | base64 --decode | jq -r "${1}"
    }

    domain_name=$(_jq '.name')
    zone_id=$(_jq '.id')

    printf "Fetching DNSSEC details for %s (Zone ID: %s):\n" "$domain_name" "$zone_id"

    # Fetch DNSSEC details for the domain
    dnssec_details=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/${zone_id}/dnssec" \
        -H "Content-Type: application/json" \
        -H "X-Auth-Email: $CLOUDFLARE_EMAIL" \
        -H "X-Auth-Key: $CLOUDFLARE_API_KEY")

    # Parse DNSSEC details
    algorithm=$(echo "$dnssec_details" | jq -r '.result.algorithm')
    digest=$(echo "$dnssec_details" | jq -r '.result.digest')
    digest_type=$(echo "$dnssec_details" | jq -r '.result.digest_type')
    key_tag=$(echo "$dnssec_details" | jq -r '.result.key_tag')

    # Extract name servers, join them with commas
    name_servers=$(echo "${domain_encoded}" | base64 --decode | jq -r '.name_servers | join(",")')

    # Append information to CSV
    echo "$domain_name,$zone_id,$name_servers,$algorithm,$digest,$digest_type,$key_tag" >>./domain_nameservers.csv

    printf "success! \n"

    printf "\n\n"
    printf "DNS quick scanning ${domain}:\n"

    scan_output=$(curl -X POST https://api.cloudflare.com/client/v4/zones/$zone_id/dns_records/scan \
        -H "Content-Type: application/json" \
        -H "X-Auth-Email: $CLOUDFLARE_EMAIL" \
        -H "X-Auth-Key: $CLOUDFLARE_API_KEY")

    echo $scan_output | jq .
done
