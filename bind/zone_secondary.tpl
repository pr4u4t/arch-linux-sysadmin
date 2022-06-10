$TTL ${TTL}
$ORIGIN ${DOMAIN_NAME}.
@  ${SOA_TTL}  IN  SOA ${PRIMARY_DNS_NAME}. ${MASTER_EMAIL}.${DOMAIN_NAME}. (
				${SERIAL}
			      	${REFRESH}
			      	${RETRY}
			      	${EXPIRE}
			      	${MINIMUM}
)

	IN	NS		${PRIMARY_DNS_NAME}.
       	IN	NS     		${SECONDARY_DNS_NAME}.
       	IN	MX	10 	${MX_NAME}.

www    	IN	A      		${WWW}
