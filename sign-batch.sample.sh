#!/bin/bash

working_dir="`dirname $0`"

"$working_dir"'/sign.sh' \
    'ychong_com' \
    '/C=CN/ST=Beijing/L=Beijing/O=Neverland/OU=IT Dept/CN=ychong.com' \
    '/var/www/html/default/public' \
    'DNS:ychong.com,DNS:www.ychong.com,DNS:blog.ychong.com'

"$working_dir"'/sign.sh' \
    'chon_io' \
    '/C=CN/ST=Beijing/L=Beijing/O=Neverland/OU=IT Dept/CN=chon.io' \
    '/var/www/html/default/public' \
    'DNS:chon.io,DNS:www.chon.io,DNS:res.chon.io'

"$working_dir"'/sign.sh' \
    'res_chon_io' \
    '/C=CN/ST=Beijing/L=Beijing/O=Neverland/OU=IT Dept/CN=res.chon.io' \
    '/var/www/html/default/public'

