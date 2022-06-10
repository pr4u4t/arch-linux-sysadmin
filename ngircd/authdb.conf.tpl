connect = dbname=${DBNAME} user=${DBUSER} password=${DBPASS} host=${DBHOST} port=${DBPORT} connect_timeout=${TIMEOUT}
auth_query = select passUser(%u)
acct_query = select optionsUser(%u)
pwd_query = select passwdUser(%u,%p,'clear')
pw_type = ${PWHASH}
#debug = 1
