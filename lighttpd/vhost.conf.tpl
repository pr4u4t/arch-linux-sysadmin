$HTTP["host"] == "${HOST}" {
	server.document-root = "${HOME}/${HOST}/www"
        server.errorlog = "${ERRLOG}/${HOST}.error.log"
        accesslog.filename = "${ERRLOG}/${HOST}.access.log"
}
