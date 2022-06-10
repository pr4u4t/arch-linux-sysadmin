#mode 		client
client
remote 		${REMOTE_ADDR} ${REMOTE_PORT}
proto 		${PROTOCOL}
dev     	${DEV_TYPE}             	#tunX,tapX
persist-tun					#persist tun/tap
persist-key					#dont re-read key
daemon						#become daemon after initialization
#write-pid      ${PID_FILE}             	#? systemd pid : openvpn pid
comp-lzo        ${COMPRESS}             	# yes | no
tls-client					#assume that we are tls client
#dh		${DH_FILE}			#diffie hellman parameters file
cert            ${CERT_FILE}            	#client certificate signed by CA
key		${KEY_FILE}			#client private key file
cipher		${CIPHER}			#cipher type
lladdr		${MAC_ADDR}			#client tap mac address
ca		${CA_FILE}
up-restart
