CREATE OR REPLACE FUNCTION fn_create_user_table() 
    RETURNS VOID AS
	$$
   
    	BEGIN

        DROP TABLE IF EXISTS public.user;
        CREATE TABLE public.user
            (
                id serial       UNIQUE,
                email			CHARACTER VARYING COLLATE pg_catalog."default",
				fullname		CHARACTER VARYING COLLATE pg_catalog."default",
				username		CHARACTER VARYING COLLATE pg_catalog."default",
				status			CHARACTER VARYING COLLATE pg_catalog."default"
            );
        CREATE UNIQUE INDEX user_idx ON public.user (email);
       
       
		    
    	END
	$$
    LANGUAGE plpgsql
	
	-- select * from fn_create_user_table(1);
	
	
        