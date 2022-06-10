mode 		${MODE} 		# p2p,server
local 		${LOCAL_ADDRESS} 	#bind to specified local address
lport		${LOCAL_PORT}		#local port to listen
proto		${PROTOCOL} 		#
dev 		${DEV_TYPE} 		#tunX,tapX
persist-key
persist-tun
daemon					#become daemon after initialization
#write-pid	${PID_FILE}		#? systemd pid : openvpn pid
comp-lzo	${COMPRESS}		# yes | no
tls-server				#assume we are tls server
ca              ${CA_FILE}              #CA root file
dh		${DH_FILE}		#diffie hellman parameters file
cipher		${CIPHER}		#cipher type
cert		${CERT_FILE}		#server certifificate signed by ca
key		${KEY_FILE}		#private server key file
keepalive	${KEEP_PING} ${KEEP_TIMEOUT}
