#
# SSL keys must reside in /etc/ssl/private
#  * cert.pem
#  * cert-key.pem
#  * cert-chain.pem
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

# Add your own email
ENV SERVER_ADMIN webmaster@localhost

# Server name
ENV SERVER_NAME localhost

# Strict transport age
ENV SSL_STRICT_TRANSPORT max-age=31536000; includeSubDomains 

# Server SSL chiphers to use
ENV SSL_CIPHERS EECDH:EDH:AES:!aNULL:!eNULL:!LOW:!RC4:!3DES:!DES:!MD5:!EXP:!PSK:!SRP:!DSS

# Install apache2 and haveged for entropy
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get -y install apache2 openssl haveged && apt-get clean && rm -rf /var/lib/apt/lists/*

#RUN ln -sf /dev/stdout /var/log/nginx/access.log
#RUN ln -sf /dev/stderr /var/log/nginx/error.log

# Add redirection and ssl site
RUN echo ServerName \${SERVER_NAME} > /etc/apache2/conf-available/servername.conf
RUN a2enconf servername
RUN a2enmod ssl rewrite headers proxy_http
RUN a2dissite 000-default
ADD site-redirect.conf      /etc/apache2/sites-enabled/010-redirect.conf
ADD site-ssl.conf           /etc/apache2/sites-enabled/020-ssl.conf

# Expose both ports
EXPOSE 80 443

# Generate a a selfsigned certificate just for testing  if we don't find a one 
# for $SERVER_NAME server
RUN test -f /etc/ssl/private/$SERVER_NAME.key || echo -n -e NO\\n.\\n.\\n.\\nWaffle Company Inc\\nBranding\\n$SERVER_NAME\\n$SERVER_ADMIN\\n | openssl req -x509 -newkey rsa:4096 -sha256 -keyout /etc/ssl/private/$SERVER_NAME.key -out /etc/ssl/private/$SERVER_NAME.cert -days 365 -nodes && ln -s /etc/ssl/private/$SERVER_NAME.cert /etc/ssl/private/$SERVER_NAME.chain

# Expose logdir, html and cgi dir
VOLUME /etc/ssl/private

# Run apache
CMD ["apache2", "-DFOREGROUND"]

