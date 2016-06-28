#!/bin/bash

if [ "$#" -lt 3 ]; then
	echo '
Usage: sign.sh <Name> <Subject> <WebRoot> [SubjectAltName]

Parameters:

 - Name           A slug name to specify current signing
                  eg. "example_com"

 - Subject        Subject name for the request
                  eg. "/C=AU/ST=Some-State/L=Some-City/O=A-Company/OU=A-Section/CN=example.com"

 - WebRoot        The web root directory to put HTTP resource for domain verification
                  eg. "/var/www/example_com/public"

 - SubjectAltName The Subject Alternative Name for the request
                  eg. "DNS:example.com,DNS:www.example.com,DNS:sub.example.com"

Read more: https://github.com/ychongsaytc/letsencrypt-bot
'
	exit 0;
fi

function fLog()
{
	echo -en '\033[32m'
	echo -n "$1"
	echo -e '\033[0m'
}

if [ -n "$4" ]; then
	openssl_cnf_path='/etc/ssl/openssl.cnf'
	if [ ! -f $openssl_cnf_path ]; then
		openssl_cnf_path='/etc/openssl/openssl.cnf'
	fi
	if [ ! -f $openssl_cnf_path ]; then
		openssl_cnf_path='/usr/lib/ssl/openssl.cnf'
	fi
	if [ ! -f $openssl_cnf_path ]; then
		openssl_cnf_path='/etc/pki/tls/openssl.cnf'
	fi
	if [ ! -f $openssl_cnf_path ]; then
		openssl_cnf_path='/usr/local/etc/openssl/openssl.cnf'
	fi
	if [ ! -f $openssl_cnf_path ]; then
		openssl_cnf_path='/System/Library/OpenSSL/openssl.cnf'
	fi
	if [ ! -f $openssl_cnf_path ]; then
		fLog '==> Cannot locate openssl.cnf';
		exit 0;
	fi
	fLog '==> Located openssl.cnf in '"$openssl_cnf_path";
fi

tmp_dir='/tmp/__letsencrypt';
working_dir="`dirname $0`"
cert_dir="$working_dir"'/signed-'"$1"
acme_base_dir="$3/.well-known"
acme_dir="$3/.well-known/acme-challenge"

account_key_path="$working_dir"'/account.key'
private_key_path="$cert_dir"'/server.key'
csr_path="$cert_dir"'/'"$1"'.csr'
crt_path="$cert_dir"'/'"$1"'.crt'

if [ -f "$account_key_path" ]; then
	fLog '==> Using account key: '"$account_key_path"
else
	echo '==> Generating account key';
	openssl genrsa -out "$account_key_path" 4096
fi

mkdir -p "$tmp_dir"

fLog '==> Downloading Let’s Encrypt Authority X3';
curl -Ls 'https://letsencrypt.org/certs/lets-encrypt-x3-cross-signed.pem' > "$tmp_dir"'/intermediate.pem'

fLog '==> Downloading ISRG Root X1';
curl -Ls 'https://letsencrypt.org/certs/isrgrootx1.pem' > "$tmp_dir"'/root.pem'

fLog '==> Downloading ACME Tiny';
curl -Ls 'https://raw.githubusercontent.com/diafygi/acme-tiny/master/acme_tiny.py' > "$tmp_dir"'/acme_tiny.py'

mkdir -p "$cert_dir"

if [ -f "$private_key_path" ]; then
	fLog '==> Using private key: '"$private_key_path"
else
	fLog '==> Generating private key';
	openssl genrsa -out "$private_key_path" 4096
fi

fLog '==> Generating CSR';
if [ -z "$4" ]; then
	openssl req -new -sha256 -key "$private_key_path" -out "$csr_path" -subj "$2"
else
	openssl req -new -sha256 -key "$private_key_path" -out "$csr_path" -subj "$2" \
		-reqexts SAN \
		-config <(cat $openssl_cnf_path \
			<(printf "[SAN]\nsubjectAltName=$4"))
fi

fLog '==> Signing certificate';
mkdir -p "$acme_dir"
python "$tmp_dir"'/acme_tiny.py' --account-key "$account_key_path" --csr "$csr_path" --acme-dir "$acme_dir" > "$crt_path"

fLog '==> Merging certificates';
cat "$crt_path" "$tmp_dir"'/intermediate.pem' > "$cert_dir"'/ssl-bundle.crt'
cat "$tmp_dir"'/intermediate.pem' "$tmp_dir"'/root.pem' > "$cert_dir"'/ssl-chain.crt'

fLog '==> Cleaning up';
rm -rf "$tmp_dir"
rm -rf "$acme_dir"
rm -rf "$acme_base_dir"

