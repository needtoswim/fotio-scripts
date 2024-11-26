CREATE OR REPLACE FUNCTION fn_create_base_tables (gallery_id INTEGER)
    RETURNS BOOLEAN AS
	$$
    DECLARE passed BOOLEAN;
    	BEGIN

        DROP TABLE IF EXISTS public.node_list;
        CREATE TABLE public.node_list
            (
                id serial       UNIQUE,
                gallery_id      INTEGER,
                node_name       CHARACTER VARYING COLLATE pg_catalog."default"
            );
        CREATE UNIQUE INDEX node_list_idx ON public.node_list (gallery_id, node_name);
       
        DROP TABLE IF EXISTS public.gallery_node;
        CREATE TABLE public.gallery_node
            (
            id serial   UNIQUE,
            gallery_id  INTEGER,
            parent      character varying COLLATE pg_catalog."default",
            child       character varying COLLATE pg_catalog."default",
            parent_id   INTEGER,
            child_id    INTEGER
            );
        CREATE UNIQUE INDEX gallery_node_idx ON public.gallery_node (gallery_id, parent, child);

        DROP TABLE IF EXISTS public.gallery;
        CREATE TABLE public.gallery
            (
                id SERIAL       UNIQUE,
                name            character varying COLLATE pg_catalog."default",
                curator_id      INTEGER,
                status          TEXT
            );
 
        DROP TABLE IF EXISTS public.gallery_html;
        CREATE TABLE public.gallery_html
            (
		    id SERIAL	  UNIQUE,
            gallery_id    INTEGER,
		    row_source	  character varying COLLATE pg_catalog."default"
	        );
	
		    passed = 1;
            RETURN passed;
    	END
	$$
    LANGUAGE plpgsql
	
	-- select * from fn_create_base_tables(1);
	
	
        