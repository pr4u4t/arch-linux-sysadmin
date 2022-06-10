server 0.arch.pool.ntp.org
server 1.arch.pool.ntp.org
server 2.arch.pool.ntp.org
server 3.arch.pool.ntp.org

restrict ${DEFAULT_RESTRICT_OPTIONS}
restrict ${DEFAULT_RESTRICT_IP}

driftfile ${DRIFT_FILE}
logfile ${LOG_FILE}

server ${SERVER_LOCAL}
fudge ${SERVER_LOCAL} stratum ${LOCAL_STRATUM}
