#!/bin/bash

'./sign.sh' 'chon_io' \
            '/C=CN/ST=Beijing/L=Beijing/O=Neverland/OU=IT Dept/CN=chon.io' \
            '/var/www/chon_io/public' \
            'DNS:chon.io,DNS:www.chon.io,DNS:res.chon.io'

'./sign.sh' 'ychong_com' \
            '/C=CN/ST=Beijing/L=Beijing/O=Neverland/OU=IT Dept/CN=ychong.com' \
            '/var/www/chon_io/public' \
            'DNS:ychong.com,DNS:www.ychong.com,DNS:blog.ychong.com'

