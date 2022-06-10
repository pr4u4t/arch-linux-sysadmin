[Unit]
Description='fcgi-php for user ${USER}'
#After=clamd.service

[Service]
Type=forking
ExecStartPre=install -g http -o http -d /run/fcgi-php
ExecStart=/usr/bin/spawn-fcgi -u ${PROC_USER} -g ${PROC_GROUP} -C ${PHP_CHILDREN} -P ${PID_LOCATION} -U ${SOCKET_USER} -G ${SOCKET_GROUP} -s ${SOCKET_LOCATION} /usr/bin/php-cgi

[Install]
WantedBy=multi-user.target
