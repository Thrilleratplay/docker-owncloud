FROM l3iggs/lamp-aur
MAINTAINER l3iggs <l3iggs@live.com>
# Report issues here: https://github.com/l3iggs/docker-owncloud/issues
# Say thanks by adding a star or a comment here: https://registry.hub.docker.com/u/l3iggs/owncloud/

# upldate package list
RUN sudo pacman -Sy

# set environmnt variable defaults
ENV REGENERATE_SSL_CERT false
ENV START_APACHE true
ENV START_MYSQL true
ENV MAX_UPLOAD_SIZE 30G
ENV TARGET_SUBDIR owncloud

# remove info.php
RUN sudo rm /srv/http/info.php

# to mount SAMBA shares: 
#RUN sudo pacman -S --noconfirm --needed smbclient

# for video file previews
RUN sudo pacman -S --noconfirm --needed ffmpeg

# for document previews
RUN sudo pacman -S --noconfirm --needed libreoffice-fresh

# Install owncloud
RUN sudo pacman -S --noconfirm --needed owncloud

# Install owncloud addons
RUN sudo pacman -S --noconfirm --needed owncloud-app-bookmarks
RUN sudo pacman -S --noconfirm --needed owncloud-app-calendar
RUN sudo pacman -S --noconfirm --needed owncloud-app-contacts
RUN sudo pacman -S --noconfirm --needed owncloud-app-documents
RUN sudo pacman -S --noconfirm --needed owncloud-app-gallery

# enable large file uploads
RUN sudo sed -i "s,php_value upload_max_filesize 513M,php_value upload_max_filesize ${MAX_UPLOAD_SIZE},g" /usr/share/webapps/owncloud/.htaccess
RUN sudo sed -i "s,php_value post_max_size 513M,php_value post_max_size ${MAX_UPLOAD_SIZE},g" /usr/share/webapps/owncloud/.htaccess
RUN sudo sed -i 's,<IfModule mod_php5.c>,<IfModule mod_php5.c>\nphp_value output_buffering Off,g' /usr/share/webapps/owncloud/.htaccess

# setup Apache for owncloud
RUN sudo cp /etc/webapps/owncloud/apache.example.conf /etc/httpd/conf/extra/owncloud.conf
RUN sudo sed -i '/<VirtualHost/,/<\/VirtualHost>/d' /etc/httpd/conf/extra/owncloud.conf
RUN sudo sed -i 's,Alias /owncloud /usr/share/webapps/owncloud/,Alias /${TARGET_SUBDIR} /usr/share/webapps/owncloud/,g' /etc/httpd/conf/extra/owncloud.conf
RUN sudo sed -i 's,Options Indexes FollowSymLinks,Options -Indexes +FollowSymLinks,g' /etc/httpd/conf/httpd.conf
RUN sudo sed -i '$a Include conf/extra/owncloud.conf' /etc/httpd/conf/httpd.conf
RUN sudo chown -R http:http /usr/share/webapps/owncloud/

# configure PHP open_basedir
RUN sudo sed -i 's,^open_basedir.*$,\0:/usr/share/webapps/owncloud/:/usr/share/webapps/owncloud/config/:/etc/webapps/owncloud/config/,g' /etc/php/php.ini

# expose some important directories as volumes
#VOLUME ["/usr/share/webapps/owncloud/data"]
#VOLUME ["/etc/webapps/owncloud/config"]
#VOLUME ["/usr/share/webapps/owncloud/apps"]

# place your ssl cert files in here. name them server.key and server.crt
#VOLUME ["/https"]

# start servers
CMD ["/root/startServers.sh"]

USER docker

RUN yaourt -Syyua --noconfirm --needed owncloud-app-mozilla_sync \
    owncloud-app-notes-git \
    owncloud-app-news-git

USER root

