$TTL ${TTL}
$ORIGIN ${DOMAIN_NAME}.
@  ${SOA_TTL}  IN  SOA ns1.${DOMAIN_NAME}. ${MASTER_EMAIL}.${DOMAIN_NAME}. (
				${SERIAL}
			      	${REFRESH}
			      	${RETRY}
			      	${EXPIRE}
			      	${MINIMUM}
)

	IN	NS		ns1.${DOMAIN_NAME}.
       	IN	NS     		ns2.${DOMAIN_NAME}.
       	IN	MX	10 	mx1.${DOMAIN_NAME}.
ns1	IN	A		${PRIMARY_DNS}
ns2	IN	A		${SECONDARY_DNS}
mx1	IN	A		${MX}
www    	IN	A      		${WWW}
