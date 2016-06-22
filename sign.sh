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
fi

tmp_dir='/tmp/__letsencrypt';
working_dir="./signed-$1"
acme_base_dir="$3/.well-known"
acme_dir="$3/.well-known/acme-challenge"

if [ ! -f "./account.key" ]; then
	echo '==> Generating account key';
	openssl genrsa -out './account.key' 4096
fi

mkdir -p "$tmp_dir"

fLog '==> Downloading Let’s Encrypt Authority X3';
curl -Ls 'https://letsencrypt.org/certs/lets-encrypt-x3-cross-signed.pem' > "$tmp_dir/intermediate.pem"

fLog '==> Downloading ISRG Root X1';
curl -Ls 'https://letsencrypt.org/certs/isrgrootx1.pem' > "$tmp_dir/root.pem"

fLog '==> Downloading acme-tiny';
curl -Ls 'https://raw.githubusercontent.com/diafygi/acme-tiny/master/acme_tiny.py' > "$tmp_dir/acme_tiny.py"


fLog '==> Generating private key';
mkdir -p "$working_dir"
openssl genrsa -out "$working_dir/server.key" 4096

fLog '==> Generating CSR';
if [ -z "$4" ]; then
	openssl req -new -sha256 -key "$working_dir/server.key" -out "$working_dir/$1.csr" -subj "$2"
else
	cp "$openssl_cnf_path" "$tmp_dir/openssl.cnf"
	echo "[SAN]\nsubjectAltName=$4" >> "$tmp_dir/openssl.cnf"
	openssl req -new -sha256 -key "$working_dir/server.key" -out "$working_dir/$1.csr" -subj "$2" -reqexts SAN -config "$tmp_dir/openssl.cnf"
fi

fLog '==> Signing certificate';
mkdir -p "$acme_dir"
python "$tmp_dir/acme_tiny.py" --account-key './account.key' --csr "$working_dir/$1.csr" --acme-dir "$acme_dir" > "$working_dir/$1.crt"

fLog '==> Merging certificates';
cat "$working_dir/$1.crt" "$tmp_dir/intermediate.pem" "$tmp_dir/root.pem" > "$working_dir/ssl-bundle.crt"

fLog '==> Cleaning up';
rm -rf "$tmp_dir"
rm -rf "$acme_dir"
rm -rf "$acme_base_dir"

