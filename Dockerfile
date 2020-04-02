FROM alpine:3
LABEL Maintainer="Mansionis" \
      Description="Lightweight container for Magento 2"

# Upgrade packages
RUN apk --no-cache update && apk --no-cache upgrade

# Install packages
RUN apk --no-cache add supervisor curl git nginx php7 php7-cli php7-fpm php7-phar
# php7-iconv

#RUN apk --no-cache add php7-mysqli php7-json php7-openssl php7-curl \
#    php7-zlib php7-xml php7-intl php7-dom php7-xmlreader php7-ctype php7-session \
#    php7-mbstring php7-gd php7-bcmath

# Configure nginx
COPY config/nginx.conf /etc/nginx/nginx.conf

# Remove default server definition
RUN rm /etc/nginx/conf.d/default.conf

# Configure PHP-FPM
COPY config/fpm-pool.conf /etc/php7/php-fpm.d/www.conf
COPY config/php.ini /etc/php7/conf.d/magento2.ini

# Configure supervisord
COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Setup document root
RUN git clone https://github.com/magento/magento2.git /var/www/magento2

# Ensure the cache folder for Composer is present
#RUN mkdir /var/www/magento2/.composer

# Install composer from the official image
COPY --from=composer /usr/bin/composer /usr/bin/composer

# Add application working directory
WORKDIR /var/www/magento2

# Run composer install to install the dependencies
RUN composer install --optimize-autoloader --no-interaction --no-progress

# Make sure files/folders needed by the processes are accessable when they run under the nobody user
RUN chown -R nobody.nobody /var/www/magento2 && \
  chown -R nobody.nobody /run && \
  chown -R nobody.nobody /var/lib/nginx && \
  chown -R nobody.nobody /var/log/nginx
  
# Make the document root a volume
VOLUME /var/www/magento2

# Switch to use a non-root user from here on
USER nobody

# Add application working directory
WORKDIR /var/www/magento2

# Make sure Magento 2 can write in these folders
RUN find var generated vendor pub/static pub/media app/etc -type f -exec chmod g+w {} +
RUN find var generated vendor pub/static pub/media app/etc -type d -exec chmod g+ws {} +


# Expose the port nginx is reachable on
EXPOSE 8080

# Let supervisord start nginx & php-fpm
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

# Configure a healthcheck to validate that everything is up&running
HEALTHCHECK --timeout=10s CMD curl --silent --fail http://127.0.0.1:8080/fpm-ping
