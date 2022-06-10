CREATE TABLE relay_user 
(
	username 	VARCHAR(255),
	domain		VARCHAR(255),
	host		VARCHAR(255),
	password	VARCHAR(255)
);

CREATE OR REPLACE FUNCTION mailAlias(pattern VARCHAR(8000))
RETURNS TABLE
(
	destiny VARCHAR(8000)
) 
AS
$$
	BEGIN
		RETURN QUERY SELECT goto::VARCHAR(8000) FROM alias WHERE address = pattern;
	END
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION maildir(pattern VARCHAR(8000))
RETURNS TABLE
(
	maildir VARCHAR(8000)
)
AS
$$
	BEGIN
		RETURN QUERY SELECT mailbox.maildir FROM mailbox WHERE username = pattern;
	END
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION mailboxOwner(pattern VARCHAR(8000))
RETURNS TABLE
(
	owner VARCHAR(8000)
)
AS
$$
	BEGIN
		IF ( SELECT COUNT(username) FROM mailbox WHERE username = pattern) THEN
			RETURN QUERY SELECT username FROM relay_user UNION SELECT username FROM mailbox WHERE username=pattern;
		END IF;
	END
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION virtualDomains(pattern VARCHAR(8000))
RETURNS TABLE
(
	domain VARCHAR(8000)
)
AS
$$
	BEGIN
		RETURN QUERY SELECT domain.domain FROM domain WHERE domain.domain !~ 'ALL' AND domain.domain = pattern;
	END
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION relayHost(pattern VARCHAR(8000))
RETURNS TABLE 
(
	host VARCHAR(8000)
)
AS
$$
	BEGIN
		IF pattern ~ '[a-z0-9]+([\.-]*[a-z0-9])*@[a-z0-9]+([\.-]*[a-z0-9])*' THEN
			RETURN QUERY SELECT relay_user.host FROM relay_user WHERE domain = substring(substring(pattern from '(@[a-z0-9]+([\.-]*[a-z0-9])*)') from '([a-z0-9]+([\.-]*[a-z0-9])*)') LIMIT 1;
		END IF;

		IF pattern ~ '(@[a-z0-9]+([\.-]*[a-z0-9])*)' THEN
			RETURN QUERY SELECT relay_user.host FROM relay_user WHERE domain = substring(pattern from '([a-z0-9]+([\.-]*[a-z0-9])*)') LIMIT 1;
		END IF;
	END
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION relayCreds(pattern VARCHAR(8000))
RETURNS TABLE 
(
	token VARCHAR(8000)
)
AS
$$
	BEGIN
		IF pattern ~ '[a-z0-9]+([\.-]*[a-z0-9])*@[a-z0-9]+([\.-]*[a-z0-9])*' THEN
			RETURN QUERY SELECT (username || ':' || password)::VARCHAR(8000) FROM relay_user WHERE domain = substring(substring(pattern from '(@[a-z0-9]+([\.-]*[a-z0-9])*)') from '([a-z0-9]+([\.-]*[a-z0-9])*)') LIMIT 1; 
		END IF;

		IF pattern ~ '([a-z0-9]+([\.-]*[a-z0-9])*)' THEN
			RETURN QUERY SELECT (username || ':' || password)::VARCHAR(8000) FROM relay_user WHERE domain = pattern OR host = pattern LIMIT 1;
		END IF;
	END
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION relayDomains(pattern VARCHAR(8000))
RETURNS TABLE
(
	domain VARCHAR(8000)
)
AS
$$
	BEGIN
		RETURN QUERY SELECT domain.domain FROM domain WHERE domain.domain = pattern;
	END
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION relayRecipients(pattern VARCHAR(8000))
RETURNS TABLE
(
	recipient VARCHAR(8000)
)
AS
$$
	BEGIN
		RETURN QUERY SELECT address FROM alias WHERE address = pattern;
	END
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION relayMap(pattern VARCHAR(8000))
RETURNS TABLE
(
	destiny VARCHAR(8000)
)
AS
$$
	BEGIN
		RETURN QUERY SELECT description FROM domain WHERE domain = pattern; 
	END
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION doveUser(usrName VARCHAR(8000),uuid INTEGER,guid INTEGER,path VARCHAR(4096))
RETURNS TABLE
(
	home 	VARCHAR(4096),
	mail	VARCHAR(4096),
	uid	INTEGER,
	gid	INTEGER,
	quota	VARCHAR(4096)
)
AS
$$
	BEGIN
		RETURN QUERY SELECT path, ('maildir:' || path)::VARCHAR(4096), uuid, guid, concat('dirsize:storage=',mailbox.quota)::VARCHAR(4096) FROM mailbox WHERE mailbox.username = usrName AND active = '1';	
	END
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION dovePassword(usrName VARCHAR(4096),path VARCHAR(4096),uuid INTEGER,guid INTEGER)
RETURNS TABLE
(
	usr 		VARCHAR(8000),
	password 	VARCHAR(8000),
	userdb_home	VARCHAR(4096),
	userdb_mail	VARCHAR(4096),
	userdb_uid	INTEGER,
	userdb_gid	INTEGER
)
AS
$$
	BEGIN
		RETURN QUERY SELECT mailbox.username,mailbox.password,path, ('maildir:' || path)::VARCHAR(4096),uuid,guid FROM mailbox WHERE username = usrName AND active = '1';
	END
$$
LANGUAGE plpgsql;

