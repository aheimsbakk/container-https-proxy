# https-proxy

**This repository is for historic purposes only**. Use [traefik](https://doc.traefik.io/traefik/) or another sensible https proxy.

https-proxy terminates a HTTPS connection for a linked dockers unencrypted web service. If you bind both https-proxy ports, 80 and 443 to the host, port 80 will redirect all requests to port 443.

This docker is configured to get **A+** on [sslabs.com](https://www.ssllabs.com/ssltest/).

## Tags

* `6`, `6.1`

    Apache hardening.

        Header set Referrer-Policy "strict-origin"

## Changelog, historic tags

* `6.0`

    Upped to Debian Stable slim base image.

* `5`

    Upped to Debian Buster.

* `4`, `4.1`

    Pull request from [triplepoint](https://github.com/triplepoint): Dockerfile Add proxypass configuration option as an environment variable. ProxyPass directive is now configurable, see Apache `mod_proxy` [ProxyPass](https://httpd.apache.org/docs/2.4/mod/mod_proxy.html#proxypass) directive for more information.

        PROXYPASS_CONFIG retry=60

* `4.0`

    Updated for easier use with [letsencrypt.org](https://letsencrypt.org), see under certificate naming. Added new environment variables for certificate names

        SSL_CERT_FILE /etc/ssl/private/cert.pem
        SSL_PRIVKEY_FILE /etc/ssl/private/privkey.pem
        SSL_CHAIN_FILE /etc/ssl/private/chain.pem

* `3.2`

    Added recommendations from [httpoxy.org](https://httpoxy.org/).

        RequestHeader unset Proxy early


* 3.1: Give the application a hint that it receives connection from a ssl proxy.

        RequestHeader set X-Forwarded-Proto "https"

* 3.0: Added ability to redirect multiple ports. New environment varibles as following.

        PORT_HTTP 80
        PORT_HTTPS 443
        PORT_REDIRECT 80

* 2.1: Fixed generation of private SSL cert during build. Added certificate stapling in SSL config.

        SSLUseStapling on
        SSLStaplingCache "shmcb:logs/stapling-cache(150000)"
        SSLStaplingResponseMaxAge 900

* 2.1: Set SSL compression off in SSL config.

        SSLCompression off

* 2.0: Apache header hardening with the following.

        Header set X-Content-Type-Options "nosniff"
        Header set X-XSS-Protection "1; mode=block"
        Header set X-Robots-Tag "none"
        Header set X-Frame-Options "SAMEORIGIN"

* 1.1: Added ProxyPreserveHost to config.

* 1.0.1: Updated documentation for docker.

* 1.0: Basic customizable SSL proxy based on `debian:jessie` and jessies version of Apache. Proxying port 80 is supported in this version.

## Start https-proxy

### For testing

    docker run -d --name my_proxy -p 80:80 -p 443:443 \
    -v ./my_certs:/etc/ssl/private \
        -e SERVER_NAME=www.mydomain.com \
        -e SERVER_ADMIN=webmaster@mydomain.com \
        --link www_container:http \
    aheimsbakk/https-proxy:4

### With letsencrypt.org certificate

#### Start docker

Start the docker with referering to letsencrypt.org certificate.

  docker run -d --name my_proxy -p 80:80 -p 443:443 \
    -v /etc/letsencrypt:/etc/ssl/private \
        -e SERVER_NAME=www.mydomain.com \
        -e SERVER_ADMIN=webmaster@mydomain.com \
        -e SSL_CERT_FILE=/etc/ssl/private/live/www.mydomain.com/cert.pem \
        -e SSL_PRIVKEY_FILE=/etc/ssl/private/live/www.mydomain.com/privkey.pem \
        -e SSL_CHAIN_FILE=/etc/ssl/private/live/www.mydomain.com/chain.pem \
        --link www_container:http \
        aheimsbakk/https-proxy:4

#### Update letsencrypt.org certificate

Create a cronjob to keep your letsencrypt.org certificate up to date with something like this.

  docker stop my_proxy
  docker run -it --rm  -p 80:80 -p 443:443 \
    -v /etc/letsencrypt:/etc/letsencrypt \
    -v /var/lib/letsencrypt:/var/lib/letsencrypt \
    quay.io/letsencrypt/letsencrypt:latest --standalone -t renew -q
  docker start my_proxy

## Environment variables

* `SERVER_NAME` - your full server name - FQDN

    default: `localhost`

* `SERVER_ADMIN` - your webmaster email

    default `webmaster@${SERVER_NAME}`

* `SSL_CIPHERS` - your preferred SSL ciphers

    default: `EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH`

* `SSL_STRICT_TRANSPORT` - strict transport options

    default: `max-age=31536000; includeSubDomains`

* `PORT_HTTP` - port which accepts HTTP traffic and redirects to first `PORT_HTTPS`

    default: `80`

* `PORT_HTTPS` - port or space separated list of HTTPS ports

    default: `443`

* `PORT_REDIRECT` - maps one to one with PORTS_HTTPS, and redirect to port on linked container

    default: `80`

* `SSL_CERT_FILE` - name of certificate file

  default: `/etc/ssl/private/cert.pem`

* `SSL_PRIVKEY_FILE` - name of certificate private key file

  default: `/etc/ssl/private/privkey.pem`

* `SSL_CHAIN_FILE` - name of certificate chain file

  default: `/etc/ssl/private/chain.pem`

* `PROXYPASS_CONFIG` - additional configuration for the ProxyPass directive, see the Apache [ProxyPass](https://httpd.apache.org/docs/2.4/mod/mod_proxy.html#proxypass) documentation.

    default: `retry=60`

## Volumes

* `/etc/ssl/private` - where certificate resides

## Certificate naming

In `/etc/ssl/private` certificate filename is important to make Apache work with your own certificate.

* Private key file is `privkey.pem`
* Public certificate is `cert.pem`
* Certificate chain is `chain.pem`

This is the default names used with [letsencrypt.org](https://letsencrypt.org) under your `/etc/letsencrypt/live/$SERVER_NAME` folder.

Get the certificate chain from your CA if you don't have it at hand.

### Getting certificate from [letsencrypt.org](https://letsencrypt.org)

Example of getting certificate.

  docker run -it --rm  \
    -p 80:80 -p 443:443 \
    -v /etc/letsencrypt:/etc/letsencrypt \
    -v /var/lib/letsencrypt:/var/lib/letsencrypt \
    quay.io/letsencrypt/letsencrypt:latest certonly --standalone --agree-tos -t -d www.mydomain.com -m webmaster@mydomain.com

###### vim: set syn=markdown spell spl=en:
