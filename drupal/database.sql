CREATE OR REPLACE FUNCTION clearDrupalCache() 
RETURNS void AS
$$
DECLARE
	row     record;
BEGIN
    FOR row IN 
        SELECT
            table_schema,
            table_name
        FROM
            information_schema.tables
        WHERE
            table_type = 'BASE TABLE'
        AND
            table_schema = 'public'
        AND
            table_name ILIKE ( 'cache' || '%')
    LOOP
        EXECUTE 'TRUNCATE ' || quote_ident(row.table_schema) || '.' || quote_ident(row.table_name);
        RAISE INFO 'Truncate table: %', quote_ident(row.table_schema) || '.' || quote_ident(row.table_name);
    END LOOP;
END
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION clearDrupalSessions()
RETURNS void AS
$$
BEGIN
	DELETE FROM sessions;
END
$$
LANGUAGE plpgsql;
	
CREATE OR REPLACE FUNCTION chownDatabase(usr VARCHAR(255))
RETURNS void AS
$$
DECLARE 
	trow RECORD;
BEGIN
	FOR trow IN select tablename from pg_tables where schemaname = 'public' LOOP
		EXECUTE 'alter table ' || quote_ident(trow.tablename) || ' owner to ' || quote_ident(usr);
	END LOOP;

	FOR trow IN select sequence_name from information_schema.sequences where sequence_schema = 'public' LOOP
		EXECUTE 'alter table ' || quote_ident(trow.sequence_name) || ' owner to ' || quote_ident(usr);
	END LOOP;

	FOR trow IN select table_name from information_schema.views where table_schema = 'public' LOOP
		EXECUTE 'alter table ' || quote_ident(trow.table_name) || ' owner to ' || quote_ident(usr);
	END LOOP;
END
$$
LANGUAGE plpgsql;
