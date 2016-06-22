
# Auto-generator for [Let's Encrypt](https://letsencrypt.org/)

### `sign.sh`

Automatically generate private key and CSR, verify domain, sign certificate and merge intermediate certificates in one script.

Usage:

```sh
$ cd /path/to/letsencrypt-bot
$ sign.sh <Name> <Subject> <WebRoot> [SubjectAltName]
```

Parameters:

- **Name**: A slug name to specify current signing (keys and ceritificates will be stored in `./signed-example_com`)

	> eg. `"example_com"`

- **Subject**: Subject name for the request

	> eg. `"/C=AU/ST=Some-State/L=Some-City/O=A-Company/OU=A-Section/CN=example.com"`

- **WebRoot**: The web root directory to put HTTP resource file for domain verification

	> eg. `"/var/www/example_com/public"`

- **SubjectAltName** (optional): The Subject Alternative Name for the request (used for multi-domain ceritificates)

	> eg. `"DNS:example.com,DNS:www.example.com,DNS:sub.example.com"`

### `sign-batch.sh`

Due to the 90 days validity of Let's Encrypt certificates, re-sign the certificates periodly to avoid unexpected expiration.

Create a batch shell script for signing certificates:

```sh
$ cd /path/to/letsencrypt-bot
$ cp sign-batch.sample.sh sign-batch.sh
```

Add the batch job:

```sh
$ crontab -e
```

```
0 0 1 * * bash /path/to/letsencrypt-bot/sign-batch.sh
```

Then the certificates in the batch script will be re-signed on the 1st of every month.

