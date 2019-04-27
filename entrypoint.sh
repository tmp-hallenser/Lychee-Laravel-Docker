#!/bin/sh

echo "**** Starting the Entrypoint Script ****"
set -e

echo "**** Make sure the /conf and /uploads folders exist ****"
[ ! -f /conf ] && \
	mkdir -p /conf
[ ! -f /uploads ] && \
	mkdir -p /uploads

echo "**** Create the symbolic link for the /uploads folder ****"
[ ! -L /usr/share/nginx/html/Lychee-Laravel/public/uploads ] && \
	cp -r /usr/share/nginx/html/Lychee-Laravel/public/uploads/* /uploads && \
	rm -r /usr/share/nginx/html/Lychee-Laravel/public/uploads && \
	ln -s /uploads /usr/share/nginx/html/Lychee-Laravel/public/uploads

echo "**** Copy the .env to /conf ****" && \
[ ! -e /conf/.env ] && \
	cp /usr/share/nginx/html/Lychee-Laravel/.env.example /conf/.env
[ ! -L /usr/share/nginx/html/Lychee-Laravel/.env ] && \
	ln -s /conf/.env /usr/share/nginx/html/Lychee-Laravel/.env
echo "**** Inject .env values ****" && \
	/inject.sh

[ ! -e /tmp/first_run ] && \
	echo "**** Generate the key (to make sure that cookies cannot be decrypted etc) ****" && \
	cd /usr/share/nginx/html/Lychee-Laravel && \
	./artisan key:generate && \
	echo "**** Migrate the database ****" && \
	cd /usr/share/nginx/html/Lychee-Laravel && \
	./artisan migrate && \
	touch /tmp/first_run

echo "**** Set Permissions ****"
chown -R nginx:nginx /usr/share/nginx/html/Lychee-Laravel

echo "**** Setup complete, starting the server. ****"
php-fpm7
exec $@

