#!/bin/sh

echo 1 > /proc/sys/net/ipv4/ip_forward

echo   "\n Создаем контейнеры \n "
/usr/bin/docker-compose up -d

echo  "\n Обновляем репозитарии \n "
/usr/bin/docker exec -it app_web1_1 apt-get update
/usr/bin/docker exec -it app_web2_1 apt-get update
/usr/bin/docker exec -it app_ng_1 apt-get update

echo  "\n Установка первого веб-сервера\n "
/usr/bin/docker exec -it app_web1_1 apt-get -y install apache2

echo  "\n Установка второго веб-сервера\n "
/usr/bin/docker exec -it app_web2_1 apt-get -y install apache2

echo  "\n Установка балансировщика веб трафика\n "
/usr/bin/docker exec -it app_ng_1 apt-get -y install nginx

echo  "\n Обновление конфигурационных файлов \n "
/usr/bin/docker exec -it app_web1_1 /bin/bash -c 'echo "<H1>Hello world 1</H1>" > /var/www/html/index.html'
/usr/bin/docker exec -it app_web2_1 /bin/bash -c 'echo "<H1>Hello world 2</H1>" > /var/www/html/index.html'
/usr/bin/docker exec -it app_ng_1 /bin/bash -c 'cp  /var/tmp/data/default /etc/nginx/sites-enabled/'
/usr/bin/docker exec -it app_ng_1 /bin/bash -c 'cp  /var/tmp/data/nginx.conf /etc/nginx/'

echo  "\n Перезапуск веб сервисов\n "
/usr/bin/docker exec -it app_web1_1  service apache2 restart
/usr/bin/docker exec -it app_web2_1  service apache2 restart
/usr/bin/docker exec -it app_ng_1    service nginx restart

echo  "\n Установка и настройка выполнены \n "