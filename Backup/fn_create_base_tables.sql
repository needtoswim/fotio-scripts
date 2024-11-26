CREATE OR REPLACE FUNCTION fn_create_base_tables ()
    RETURNS BOOLEAN AS
	$$
    DECLARE passed BOOLEAN;
    	BEGIN

            DROP TABLE IF EXISTS public.gallery;
            CREATE TABLE public.public_gallery
                (
                    id SERIAL       UNIQUE,
                    curator_id      INTEGER,
                    gallery_name    character varying COLLATE pg_catalog."default",
                    status          TEXT
                );

            INSERT INTO gallery (curator_id, gallery_name, status)
                    VALUES 
                        (1, 'John Lyons', 'active');

            DROP TABLE IF EXISTS public.node_list;
            CREATE TABLE public.node_list
                (
                    id serial UNIQUE,
                    gallery_id  INTEGER,
                    name CHARACTER VARYING COLLATE pg_catalog."default"
                );

            CREATE UNIQUE INDEX node_list_idx ON public.node_list (gallery_id, name); 

                    
                                          
            DROP TABLE IF EXISTS public.pics_html;
            CREATE TABLE public.pics_html
                    (
	                id serial	UNIQUE,
	                gallery_id	INTEGER,
	                html		character varying COLLATE pg_catalog."default"
	            );

            CREATE UNIQUE INDEX pics_node_idx ON public.pics_node (gallery_id, parent, child);
            
            DROP TABLE IF EXISTS public.gallery_ltree;
              
            
            DROP TABLE IF EXISTS public.gallery_ltree;
            CREATE TABLE public.gallery_ltree
                (
                    id SERIAL           UNIQUE,
                    curator_id          INTEGER,
        			id serial       	UNIQUE,
        			gallery_id          INTEGER,
        			parent_txt      	TEXT,
        			child_txt       	TEXT,
       				mypath          	ltree,
        			labels          	INTEGER,
					ltree_seq			INTEGER,	
        			lowest_descendant	BOOLEAN
				);	
            CREATE INDEX path_gist_idx ON gallery_ltree USING gist(mypath);
			CREATE INDEX path_idx ON gallery_ltree USING btree(mypath);
              
            
            

                TRUNCATE TABLE gallery_tree RESTART IDENTITY;
                INSERT INTO public.gallery_tree (id, gallery_id, parent, child)
                        
                        VALUES 	(DEFAULT, 1, NULL, 'Holidays'),
    		                    (DEFAULT, 1, 'Holidays','Local'),
                                (DEFAULT, 1, 'Holidays','Overseas'),
                                (DEFAULT, 1, 'Local',   'NSW'),
                                (DEFAULT, 1, 'Local',   'WA'),
                                (DEFAULT, 1, 'NSW',     'SouthCoast'),
                                (DEFAULT, 1, 'NSW',     'Sydney'),
                                (DEFAULT, 1, 'WA',      'Perth'),
                                (DEFAULT, 1, 'Perth',   'Kings_Park'),
                                (DEFAULT, 1, 'WA',      'Nullabor'),
                                (DEFAULT, 1, 'WA',      'MargaretRiver'),
                                (DEFAULT, 1, 'Overseas','UK'),
                                (DEFAULT, 1, 'UK',      'England'),
                                (DEFAULT, 1, 'UK',      'Scotland'),
                                (DEFAULT, 1, 'UK',      'Wales'),
                                (DEFAULT, 1, 'Overseas','France'),
                                (DEFAULT, 1, 'France',  'Burgundy'),
                                (DEFAULT, 1, 'France',  'Champagne'),
                                (DEFAULT, 1, 'Kings_Park','Motor_Museum'),
                                (DEFAULT, 1, 'England','London'),
                                (DEFAULT, 1, 'London',	'The_Tower'),
                                (DEFAULT, 1,  'Paris',	'Eifull_Tower'),
                                (DEFAULT, 1,  'Sydney',	'Opera_House')
                                ;
                                
                TRUNCATE TABLE node_list RESTART IDENTITY;
                INSERT INTO node_list (gallery_id, name)
                    (Select 1, parent FROM gallery_tree GROUP BY parent ORDER BY parent);
 
                INSERT INTO node_list (gallery_id, name)
                    (Select 1, child FROM gallery_tree GROUP BY child ORDER BY child)
	                    ON CONFLICT (gallery_id, name) DO NOTHING;
        
                UPDATE gallery_node g
                    SET parent_id = n.id 
                        FROM node_list n
                        WHERE  g.parent = n.name
                        AND g.gallery_id = n.gallery_id ;

                UPDATE gallery_node g
                    SET child_id = n.id 
                        FROM node_list n
                            WHERE   g.child = n.name
				            AND     g.gallery_id = n.gallery_id ;

                DROP TABLE IF EXISTS public.html_source;
                CREATE TABLE public.html_source
                    (
		            id serial 	UNIQUE,
                    gallery_id  INTEGER,
		            row_source	character varying COLLATE pg_catalog."default"
	            );
	
            passed = 1;
            RETURN passed;
    	END
	$$
    LANGUAGE plpgsql
	
	
	
	
        