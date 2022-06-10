/*BEGIN*/
	CREATE EXTENSION pgcrypto;

	CREATE TYPE hashes AS ENUM
	(
		'clear',
		'sha1',
		'md5',
		'null'
	);

/*
	CREATE TYPE types AS ENUM
	(
		'object',
		'widget',
		'window'
	);
*/

	CREATE OR REPLACE FUNCTION addUser(usr VARCHAR(255), pass VARCHAR(255),pschema hashes)
	RETURNS boolean AS 
	$$
		DECLARE 
			passHash VARCHAR(255);
		BEGIN	
			CASE pschema
				WHEN 'clear'	THEN passHash = pass;
				WHEN 'sha1' 	THEN passHash = encode(digest(pass,'sha1'),'hex');
				WHEN 'md5'	THEN passHash = encode(digest(pass,'md5'),'hex');
				WHEN 'null'	THEN passHash = null;
				ELSE RETURN false;
			END CASE;

			IF ((pschema <> 'null') AND (length(passHash) = 0)) OR ((pschema = 'null') AND (pass <> null)) THEN
				RETURN false;
			END IF;

			INSERT INTO users (name,pass,expired,newpass) VALUES (usr,passHash,'f','f');

			RETURN true;
		END
	$$ 
	LANGUAGE plpgsql;

	CREATE OR REPLACE FUNCTION addGroup(grp VARCHAR(255))
	RETURNS boolean AS
	$$
		BEGIN

			IF ( SELECT COUNT(*) FROM groups WHERE groups.name = grp ) <> 0 THEN
				RETURN false;
			END IF;

			INSERT INTO groups (name) VALUES (grp);
			RETURN true;
		END
	$$
	LANGUAGE plpgsql;

	CREATE OR REPLACE FUNCTION userIsMember(usr VARCHAR(255),VARIADIC grp VARCHAR(255)[])
	RETURNS boolean AS
	$$
		BEGIN
			/*
			IF ( SELECT COUNT(*) FROM ( SELECT groups.name AS grp FROM groups WHERE groups.guid IN ( SELECT user_group.guid FROM user_group WHERE uuid IN 
				( SELECT users.uuid FROM users WHERE users.name=usr ))) AS Mid WHERE  Mid.grp=grp ) <> 0 THEN
				RETURN true;
			ELSE
				RETURN false;
			END IF;
			*/
			
			IF ( SELECT COUNT(*) FROM ( SELECT groups.name AS GrpName FROM groups WHERE groups.guuid IN 
				( SELECT user_group.guuid FROM user_group WHERE user_group.uuid IN 
					( SELECT users.uuid FROM users WHERE users.name = usr )) ) AS MID WHERE MID.GrpName IN grp ) THEN
				RETURN true;
			ELSE
				RETURN false;
			END IF;
		END
	$$
	LANGUAGE plpgsql;

	CREATE OR REPLACE FUNCTION groupAddMember(usr VARCHAR(255),grp VARCHAR(255))
	RETURNS boolean AS
	$$
		DECLARE
			usrID INTEGER;
			grpID INTEGER;
		BEGIN
			IF userIsMember(usr,grp) THEN
				RETURN false;
			END IF;

			/*usrID :=*/
			SELECT users.uuid INTO usrID FROM users WHERE users.name = usr;
			IF usrID IS NULL THEN
				RETURN false;
			END IF;
			
			/*grpID :=*/ 
			SELECT groups.guid INTO grpID FROM groups WHERE groups.name = grp;
			IF grpID IS NULL THEN
				RETURN false;
			END IF;
			
			INSERT INTO user_group (uuid,guid) VALUES (usrID,grpID);
			RETURN true;
		END 
	$$
	LANGUAGE plpgsql;

	CREATE OR REPLACE FUNCTION userID(usr VARCHAR(255))
	RETURNS integer AS
	$$
		DECLARE 
			ret INTEGER;
		BEGIN
			IF ( SELECT COUNT(*) FROM users WHERE users.name = usr ) = 1 THEN
				SELECT users.uuid INTO ret FROM users WHERE users.name = usr;
				RETURN ret;
			ELSE
				RETURN -1;
			END IF;
		END
	$$
	LANGUAGE plpgsql;
	
	CREATE OR REPLACE FUNCTION groupID(grp VARCHAR(255))
	RETURNS integer AS
	$$
		DECLARE 
			ret INTEGER;
		BEGIN
			IF ( SELECT COUNT(*) FROM groups WHERE groups.name = grp ) THEN
				SELECT groups.guid INTO ret FROM groups WHERE groups.name = grp;
				RETURN ret;
			ELSE
				RETURN -1;
			END IF;
		END
	$$
	LANGUAGE plpgsql;
	
	CREATE OR REPLACE FUNCTION userDel(usr VARCHAR(255))
	RETURNS boolean AS
	$$
		DECLARE
			usrID INTEGER;
		BEGIN
			/*usrID :=*/ 
			SELECT users.uuid INTO usrID FROM users WHERE users.name = usr;
			IF usrID IS NULL THEN
				RETURN false;
			END IF;
			
			IF (SELECT COUNT(*) FROM user_group WHERE user_group.uuid = usrID) THEN
				DELETE FROM user_group WHERE user_group.uuid = usrID;
			END IF;
			
			DELETE FROM users WHERE users.name = usr;
			
			RETURN true;
		END
	$$
	LANGUAGE plpgsql;

	CREATE OR REPLACE FUNCTION groupDelMember(usr VARCHAR(255),grp VARCHAR(255))
	RETURNS boolean AS
	$$
		DECLARE
			usrID INTEGER;
			grpID INTEGER;
		BEGIN
			IF userIsMember(usr,grp) = false THEN
				RETURN false;
			END IF;
			
			/*usrID := */
			SELECT users.uuid INTO usrID FROM users WHERE users.name = usr;
			IF usrID IS NULL THEN
				RETURN false;
			END IF;
			
			/*grpID := */
			SELECT groups.guid INTO grpID FROM groups WHERE groups.name = grp;
			IF grpID IS NULL THEN
				RETURN false;
			END IF;
			
			IF (SELECT COUNT(*) FROM user_group WHERE user_group.uuid = usrID AND user_group.guid = grpID) = 0 THEN
				RETURN false;
			END IF;
			
			DELETE FROM user_group WHERE user_group.uuid = usrID AND user_group.guid = grpID;
			RETURN true;
		END
	$$
	LANGUAGE plpgsql;
	
	CREATE OR REPLACE FUNCTION userExist(usr VARCHAR(255))
	RETURNS boolean AS
	$$
		BEGIN
			IF ( SELECT COUNT(*) FROM users WHERE users.name = usr ) = 1 THEN
				RETURN true;
			ELSE
				RETURN false;
			END IF;
		END
	$$
	LANGUAGE plpgsql;
	
	CREATE OR REPLACE FUNCTION groupExist(grp VARCHAR(255))
	RETURNS boolean AS
	$$
		BEGIN
			IF ( SELECT COUNT(*) FROM groups WHERE groups.name = grp ) = 1 THEN
				RETURN true;
			ELSE
				RETURN false;
			END IF;
		END
	$$
	LANGUAGE plpgsql;
	
	CREATE OR REPLACE FUNCTION groupDel(grp VARCHAR(255))
	RETURNS boolean AS
	$$
		BEGIN
			IF NOT groupExist(grp) THEN
				RETURN false;
			END IF;
			
			IF ( SELECT COUNT(*) FROM user_group WHERE user_group.guid IN (SELECT groups.guid FROM groups WHERE groups.name = grp)) THEN
				DELETE FROM user_group WHERE user_group.guid IN ( SELECT groups.guid FROM groups WHERE groups.name = grp);
			END IF;
			
			DELETE FROM groups WHERE groups.name = grp;
			
			RETURN true;
		END
	$$
	LANGUAGE plpgsql;
	
	CREATE OR REPLACE FUNCTION passwdUser(usr VARCHAR(255), newPass VARCHAR(255),pschema hashes)
	RETURNS boolean AS
	$$
		DECLARE 
			passHash VARCHAR(255);
		BEGIN
			CASE pschema
				WHEN 'clear'	THEN passHash = newPass;
				WHEN 'sha1'	THEN passHash = encode(digest(newPass,'sha1'),'hex');
				WHEN 'md5'	THEN passHash = encode(digest(newPass,'md5'),'hex');
				ELSE RETURN false;
			END CASE;

			IF length(passHash) = 0 THEN
				RETURN false;
			END IF;

			UPDATE users SET pass=passHash WHERE name=usr;
			RETURN true;
		END
	$$
	LANGUAGE plpgsql;

	CREATE OR REPLACE FUNCTION passUser(usr VARCHAR(255))
	RETURNS TABLE 
	(
		password VARCHAR(255)
	)	
	AS
	$$
		BEGIN
			RETURN QUERY SELECT pass FROM users WHERE name=usr;
		END
	$$
	LANGUAGE plpgsql;

	CREATE OR REPLACE FUNCTION loginUser(usr VARCHAR(255),pass VARCHAR(255),pschema hashes)
	RETURNS BOOLEAN
	AS
	$$
		DECLARE 
                        passHash VARCHAR(255);
			storedHash VARCHAR(255);
		BEGIN
			CASE pschema
                                WHEN 'clear'    THEN passHash = newPass;
                                WHEN 'sha1'     THEN passHash = encode(digest(pass,'sha1'),'hex');
                                WHEN 'md5'      THEN passHash = encode(digest(pass,'md5'),'hex');
                                ELSE RETURN false;
                        END CASE;
		
			IF length(passHash) = 0 THEN
      				RETURN false;
                        END IF;

			storedHash := (SELECT password FROM passUser(usr));
			return (storedHash = passHash);
		END
	$$
	LANGUAGE plpgsql;

	CREATE OR REPLACE FUNCTION isActiveUser(usr VARCHAR(255))
	RETURNS TABLE 
	(
		expired	BOOLEAN
	)
	AS
	$$
		BEGIN
			RETURN QUERY SELECT expired FROM users WHERE name=usr;
		END
	$$
	LANGUAGE plpgsql;

	CREATE OR REPLACE FUNCTION optionsUser(usr VARCHAR(255)) 
	RETURNS TABLE
	(
		expired BOOLEAN,
		new_pass BOOLEAN,
		pass_null BOOLEAN
	)
	AS
	$$
		BEGIN
			RETURN QUERY SELECT users.expired,users.newpass,false FROM users WHERE name=usr;
		END
	$$
	LANGUAGE plpgsql;

	CREATE OR REPLACE FUNCTION setNode(surl VARCHAR(8000),jdata JSON)
	RETURNS INTEGER
	AS
	$$
		DECLARE
			item RECORD;
		BEGIN
			IF NOT hasNode(surl,true) THEN
				RETURN addNode(surl,jdata);
			END IF;

			item := getNode(surl);
			UPDATE nodes SET data=jdata::jsonb WHERE nodes.nodeid = item.nodeid;
			RETURN item.nodeid;
		END	
	$$
	LANGUAGE plpgsql;

	CREATE OR REPLACE FUNCTION addNode(surl VARCHAR(8000),data JSON)
	RETURNS INTEGER
	AS
	$$
		DECLARE 
			itemid INTEGER;
		BEGIN 
			IF  hasNode(surl,true) THEN
				RETURN 0;
			END IF;
			
			INSERT INTO nodes (data) VALUES (data::jsonb) RETURNING nodes.nodeid INTO itemid;
			
			INSERT INTO paths (url,nodeid) VALUES (surl,itemid);

			RETURN itemid;
		END
	$$
	LANGUAGE plpgsql;

	CREATE OR REPLACE FUNCTION linkNode(surl VARCHAR(8000),durl VARCHAR(8000))
	RETURNS INTEGER
	AS
	$$
		DECLARE
			itemid INTEGER;
		BEGIN
			IF ( SELECT COUNT(url) FROM paths WHERE url = durl ) > 0 THEN
				RETURN 0;
			END IF;
			INSERT INTO paths (url,nodeid) SELECT durl,nodeid FROM paths WHERE url=surl RETURNING paths.nodeid INTO itemid;
			RETURN itemid;
		END
	$$
	LANGUAGE plpgsql;

	CREATE OR REPLACE FUNCTION delNode(surl VARCHAR(8000))
	RETURNS BOOLEAN
	AS
	$$
		DECLARE
			itemid INTEGER;
		BEGIN
			itemid := ( SELECT nodeid FROM paths WHERE url=surl);
			DELETE FROM paths WHERE url=surl AND nodeid = itemid;

			IF (SELECT COUNT(paths.url) FROM paths WHERE paths.nodeid = itemid ) = 0 THEN
				DELETE FROM nodes WHERE nodeid = itemid;
			END IF;
			
			RETURN true;
		END
	$$
	LANGUAGE plpgsql;

	CREATE OR REPLACE FUNCTION hasNode(surl VARCHAR(8000),strict BOOLEAN)
	RETURNS BOOLEAN
	AS
	$$
		BEGIN
			IF char_length(substring(surl from '(([A-Za-z]+)(/[A-Za-z0-9]+)*)')) <> char_length(surl) THEN
				RETURN false;
			END IF;
		
			IF strict = false THEN
				IF ( SELECT COUNT(nodes.nodeid) FROM nodes,paths WHERE paths.url IN
                         ( SELECT PathId.url FROM (SELECT paths.nodeid AS id,paths.url AS url,char_length(paths.url) AS length 
                                FROM paths WHERE surl LIKE paths.url || '%' ORDER BY length DESC LIMIT 1 ) AS PathId) AND paths.nodeid = nodes.nodeid ) <> 0 THEN
					RETURN true;
				ELSE
					RETURN false;
				END IF;
			ELSE
				IF ( SELECT COUNT(nodes.nodeid) FROM nodes WHERE nodes.nodeid IN ( SELECT paths.nodeid FROM paths WHERE url = surl ) ) <> 0  THEN
					RETURN true;
				ELSE
					RETURN false;
				END IF;
			END IF;
		END
	$$
	LANGUAGE plpgsql;
	
	CREATE OR REPLACE FUNCTION getNode(surl VARCHAR(8000))
	RETURNS TABLE
	(
		nodeid		INTEGER,
		url 		VARCHAR(8000),
		data		JSONB,
		tstamp		TIMESTAMP
	)
	AS
	$$		
		BEGIN
			IF char_length(substring(surl from '(([A-Za-z]+)(/[A-Za-z0-9]+)*)')) <> char_length(surl) THEN
				RETURN;
			END IF;
			
			RETURN QUERY SELECT nodes.nodeid,paths.url,nodes.data,nodes.time FROM nodes,paths WHERE paths.url IN
			 ( SELECT PathId.url FROM (SELECT paths.nodeid AS id,paths.url AS url,char_length(paths.url) AS length 
				FROM paths WHERE surl LIKE paths.url || '%' ORDER BY length DESC LIMIT 1 ) AS PathId) AND paths.nodeid = nodes.nodeid;
		END
	$$
	LANGUAGE plpgsql;

	CREATE OR REPLACE FUNCTION getNodes(intags JSON)
	RETURNS TABLE
	(
		nodeid	INTEGER,
		url	VARCHAR(8000),
		data	JSONB,
		tstamp	TIMESTAMP
	)
	AS
	$$
		DECLARE
			tagsArray TEXT[];
			item RECORD;
		BEGIN
			FOR item IN select * FROM json_array_elements_text(intags) LOOP
				tagsArray := array_append(tagsArray,item.value);
			END LOOP;

			RETURN QUERY SELECT nodes.nodeid,paths.url,nodes.data,nodes.time FROM nodes,paths WHERE nodes.data->'tags' ?| tagsText;
		END
	$$
	LANGUAGE plpgsql;

	CREATE OR REPLACE FUNCTION getPermissions(userName VARCHAR(255), surl VARCHAR(8000))
	RETURNS VARCHAR(3)
	AS
	$$
		DECLARE 
			nodeData RECORD;
			ret VARCHAR(3);
		BEGIN
			nodeData := getNode(surl);
			IF nodeData IS NULL THEN
				RETURN NULL;
			END IF;
			
			IF nodeData.data->'owner' = userName THEN
				ret := node.data->'owner_perm';
				RETURN ret;
			END IF;
			
			IF userIsMember(userName,nodeData.data->'group') IS true THEN
				ret := node.data->'group_perm';
				RETURN ret;
			END IF;
			
			ret := node.data->'other_perm';
			return ret;
		END
	$$
	LANGUAGE plpgsql;

	CREATE OR REPLACE FUNCTION canRead(userName VARCHAR(255),surl VARCHAR(8000))
	RETURNS BOOLEAN
	AS
	$$
		DECLARE 
			perms VARCHAR(3);
		BEGIN
			perms := getPermissions(userName,surl);
			IF perms = NULL THEN 
				RETURN false;
			END IF;
			
			RETURN ( perms[0] = 'r' );
		END
	$$
	LANGUAGE plpgsql;
	
	CREATE OR REPLACE FUNCTION canWrite(userName VARCHAR(255),surl VARCHAR(8000))
	RETURNS BOOLEAN
	AS
	$$
		DECLARE
			perms VARCHAR(3);
		BEGIN
			perms := getPermissions(userName,surl);
			IF perms = NULL THEN 
				RETURN false;
			END IF;
			
			RETURN ( perms[1] = 'w' );
		END
	$$
	LANGUAGE plpgsql;
	
	CREATE OR REPLACE FUNCTION canExecute(userName VARCHAR(255),surl VARCHAR(8000))
	RETURNS BOOLEAN
	AS
	$$
		DECLARE
			perms VARCHAR(3);
		BEGIN
			perms := getPermissions(userName,surl);
			IF perms = NULL THEN
				RETURN false;
			END IF;
			
			RETURN ( perms[2] = 'x' );
		END
	$$
	LANGUAGE plpgsql;

	CREATE TABLE IF NOT EXISTS users 
	(
		uuid	SERIAL 		UNIQUE NOT NULL,
		name	VARCHAR(255) 	PRIMARY KEY,
		pass	VARCHAR(255) 	,
		expired	BOOLEAN		NOT NULL,
		newpass	BOOLEAN		NOT NULL
	);

	CREATE TABLE IF NOT EXISTS groups
	(
		guid	SERIAL		UNIQUE NOT NULL,
		name	VARCHAR(255)	PRIMARY KEY
	);

	CREATE TABLE IF NOT EXISTS user_group
	(
		uuid	INTEGER		REFERENCES users (uuid),
		guid	INTEGER		REFERENCES groups (guid)
	);

	CREATE TABLE IF NOT EXISTS nodes
	(
		nodeid	SERIAL		PRIMARY KEY,
		time	TIMESTAMP	default (now()),
		data	JSONB		NOT NULL
	);

	CREATE TABLE IF NOT EXISTS paths
	(
		url 	VARCHAR(8000)	PRIMARY KEY,
		nodeid	INTEGER 	REFERENCES nodes (nodeid)
	);

	CREATE INDEX idxNode	 	ON nodes USING gin (data);
	CREATE INDEX idxNodeTags 	ON nodes USING gin ((data -> 'tags'));
	CREATE INDEX idxNodeName 	ON nodes USING gin ((data -> 'name'));
	CREATE INDEX idxNodeType 	ON nodes USING gin ((data -> 'type'));
	CREATE INDEX idxNodeOwner 	ON nodes USING gin ((data -> 'owner'));
	CREATE INDEX idxNodeGroup	ON nodes USING gin ((data -> 'group'));
	CREATE INDEX idxNodeOwnerPerm	ON nodes USING gin ((data -> 'owner_perm'));
	CREATE INDEX idxNodeGroupPerm	ON nodes USING gin ((data -> 'group_perm'));
	CREATE INDEX idxNodeOtherPerm	ON nodes USING gin ((data -> 'other_perm'));
/*END*/

