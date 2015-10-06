#
# If you don't specify any certs folder a selfsigned certificate will be used.
# Only use the selfsigned certificate for testing.
#

# Use oldee stable
FROM debian:jessie

# Yep thats me, please use +docker tag to help me find the mail
MAINTAINER Arnulf Heimsakk "arnulf.heimsbakk+docker@gmail.com"

# Apache variables
ENV APACHE_RUN_USER  www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_PID_FILE  /var/run/apache2.pid
ENV APACHE_RUN_DIR   /var/run/apache2
ENV APACHE_LOCK_DIR  /var/lock
ENV APACHE_LOG_DIR   /var/log/apache2
ENV APACHE_CONFDIR   /etc/apache2

# Change to your servers FQDN
ENV SERVER_NAME localhost

# Change to your webmaster email
ENV SERVER_ADMIN webmaster@$SERVER_NAME

# Strict transport age
ENV SSL_STRICT_TRANSPORT max-age=31536000; includeSubDomains 

# Server SSL chiphers to use
ENV SSL_CIPHERS EECDH:EDH:AES:!aNULL:!eNULL:!LOW:!RC4:!3DES:!DES:!MD5:!EXP:!PSK:!SRP:!DSS

# Install apache2 and haveged for entropy
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get -y install apache2 openssl haveged && apt-get clean && rm -rf /var/lib/apt/lists/*

# Configure apache servername
RUN echo ServerName \${SERVER_NAME} > /etc/apache2/conf-available/servername.conf
RUN a2enconf servername

# Add ssl, rewrite, headers and proxy module
RUN a2enmod ssl rewrite headers proxy_http

# Remove default site
RUN a2dissite 000-default

# Add redirect from port 80 to ssl, and the ssl site
ADD site-redirect.conf      /etc/apache2/sites-enabled/010-redirect.conf
ADD site-ssl.conf           /etc/apache2/sites-enabled/020-ssl.conf

# Expose both ports
EXPOSE 80 443

# Generate a a selfsigned certificate just for testing using $SERVER_NAME 
# as server name; valid for 365 after build of docker
RUN test -f /etc/ssl/private/$SERVER_NAME.key || echo -n -e NO\\n.\\n.\\n.\\nWaffle Company Inc\\nBranding\\n$SERVER_NAME\\n$SERVER_ADMIN\\n | openssl req -x509 -newkey rsa:4096 -sha256 -keyout /etc/ssl/private/$SERVER_NAME.key -out /etc/ssl/private/$SERVER_NAME.cert -days 365 -nodes && ln -s /etc/ssl/private/$SERVER_NAME.cert /etc/ssl/private/$SERVER_NAME.chain

# Expose certificate directory
VOLUME /etc/ssl/private

# Run apache
CMD ["apache2", "-DFOREGROUND"]

