# Migrate Bulk Domains To [Cloudflare](https://www.cloudflare.com)

This script bulk adds domains, imports its current DNS records, enables and retrieves DNSSEC cloudflare records for each cloudflare created domain.

Why? "On September 7, 2023 [Squarespace](https://www.squarespace.com/) acquired all domain registrations and related customer accounts from [Google Domains](https://domains.google). Customers and domains will be transitioned over the next few months. [Learn more](https://support.google.com/domains/answer/13689670)"

Due to the sheer number of domains I own (50+) individually migrating each domain to Cloudflare would be far too time-consuming. Here’s how I mass-transferred my domains using Cloudflare’s API. There are more efficient ways to do this, but I cranked out the fastest solution I could think of. Feel free to use this script as a starting point for your own mass domain transfer from any domain provider to [Cloudflare](https://www.cloudflare.com).

Notice: I would have used Google Domains API to unlock domain for transfer, but Google has conveniently depricated this endpoint. Would recommend reaching out to their support team to mass unlock domains for transfer.

## Getting Started

### Create and add your domains to the domains.txt file

```sh
touch domains.txt
```

### Reuse config example and update with your cloudflare secrets

```sh
mv config.example.txt config.txt
```

## Run

### Add all domains in the domains.txt file to your cloudflare account

```sh
bash add-multiple-zones.sh
```

### Setup domains to migrate to cloudflare account

1) Retrieve all domains in your cloudflare account
2) Get nameservers for each domain to update nameservers at your domain registrar
3) Fetch and enable DNSSEC for each domain
4) Retrieve all DNS records for each domain and migrate to cloudflare

```sh
bash setup-cloudflare-migration.sh
```
