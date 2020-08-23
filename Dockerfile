FROM php:7.2-apache
MAINTAINER BNBRNDN <bnbrndn@gmail.com>

RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer

RUN apt-get update \
  && apt-get install -y \
    libfreetype6-dev \
    libicu-dev \
    libjpeg62-turbo-dev \
    libmcrypt-dev \
    libpng-dev \
    libxslt1-dev \
    git \
    vim \
    wget \
    lynx \
    psmisc \
    cron \
  && apt-get clean

RUN docker-php-ext-configure \
    gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/; \
  docker-php-ext-install \
    gd \
    intl \
    mbstring \
    pdo_mysql \
    xsl \
    zip \
    opcache \
    bcmath \
    soap \
    sockets

RUN a2enmod rewrite
RUN a2enmod deflate
RUN a2enmod headers
RUN a2enmod ssl

# Copy hello-cron file to the cron.d directory
COPY m2-task /etc/cron.d/m2-task

# Give execution rights on the cron job
RUN chmod 0644 /etc/cron.d/m2-task

# Apply cron job
RUN crontab /etc/cron.d/m2-task

# Create the log file to be able to run tail
RUN touch /var/log/cron.log

# Run the command on container startup
CMD cron && tail -f /var/log/cron.log