CREATE OR REPLACE FUNCTION fn_create_gallery_table ()
    RETURNS VOID AS
	$$
   
    	BEGIN

        DROP TABLE IF EXISTS public.gallery;
        CREATE TABLE public.gallery
            (
                id SERIAL       UNIQUE,
                name            character varying COLLATE pg_catalog."default",
                curator_id      INTEGER,
                status          TEXT
            );
 
         CREATE UNIQUE INDEX gallery_idx ON public.gallery(name);
         CREATE UNIQUE INDEX gallery_curator_idx ON public.gallery(curator_id);
            
    	END
	$$
    LANGUAGE plpgsql
	
	-- select * from fn_create_gallery_table();
	
	
	
        