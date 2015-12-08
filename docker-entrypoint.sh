#!/bin/bash

declare port_http=$PORT_HTTP
declare ports_https=( $PORT_HTTPS )
declare ports_redirect=( $PORT_REDIRECT )

if [ ${#ports_https[*]} -ne ${#ports_redirect[*]} ]; then
    echo >&2 error: not equal number of PORT_HTTPS and PORT_REDIRECT mappings
    exit 1
fi

# Remove old config 
rm -f /etc/apache2/sites-enabled/*

# How many ports do we have
let "count = ${#ports_https[*]} - 1"

# Copy out each config
for i in $(seq 0 $count); do
    port_https=${ports_https[$i]}
    port_redirect=${ports_redirect[$i]}

    # First port, check if we're going to copy out HTTP redirect
    if [ $i -eq 0 -a ! -z "$port_http" ]; then
        cp /etc/apache2/sites-available/redirect.conf /etc/apache2/sites-enabled/$i-redirect.conf
        sed -i "s/%PORT_HTTPS%/$port_https/g" /etc/apache2/sites-enabled/$i-redirect.conf

        # Don't extra listening if we don't need it
        if [ $port_http -ne 80 -a $port_http -ne 443 ]; then
            echo Listen $port_http > /etc/apache2/conf-enabled/listen-${port_http}.conf
        fi
    fi

    # Copy out ssl config and sed to correct ports
    cp /etc/apache2/sites-available/ssl.conf /etc/apache2/sites-enabled/$i-ssl.conf
    sed -i "s/%PORT_HTTPS%/$port_https/g" /etc/apache2/sites-enabled/$i-ssl.conf
    sed -i "s/%PORT_REDIRECT%/$port_redirect/g" /etc/apache2/sites-enabled/$i-ssl.conf

    # Don't extra listening if we don't need it
    if [ $port_https -ne 80 -a $port_https -ne 443 ]; then
        echo Listen $port_https > /etc/apache2/conf-enabled/listen-${port_https}.conf
    fi
done

exec $@

    
    

