                DROP TABLE IF EXISTS public.html_source;
                CREATE TABLE public.html_source
                    (
		            id serial 	UNIQUE,
                    group_id    INTEGER,
		            row_source	character varying COLLATE pg_catalog."default"
	            );
	
                DROP TABLE IF EXISTS public.group_html;
                CREATE TABLE public.group_html
                    (
	                id serial	UNIQUE,
	                group_id	INTEGER,
	                html		BLOB
	            );