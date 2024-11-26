CREATE OR REPLACE FUNCTION fn_create_ltree (gallery_id INTEGER)
    RETURNS BOOLEAN AS
	$$
    DECLARE passed BOOLEAN;
    	BEGIN
			DROP EXTENSION IF EXISTS ltree CASCADE;
			CREATE EXTENSION ltree;
			DROP TABLE IF EXISTS t_orga CASCADE;

			CREATE TABLE t_orga
				(
					parent_txt TEXT,
					child_txt TEXT,
					UNIQUE (parent_txt , child_txt)
				);

			INSERT INTO t_orga (parent_txt, child_txt)
				SELECT 	parent_id::Text,
					child_id::Text
					FROM gallery_node;

			DROP VIEW IF EXISTS t_orga_mat CASCADE;
			CREATE MATERIALIZED VIEW t_orga_mat AS
				WITH RECURSIVE x AS (
    					SELECT *, child_txt::ltree AS mypath
        					FROM t_orga
        					WHERE parent_txt IS NULL
    			UNION ALL
        			SELECT y.parent_txt, y.child_txt, ltree_addtext(x.mypath, y.child_txt) AS mypath
            			FROM x, t_orga AS y
            			WHERE x.child_txt = y.parent_txt
					)
			SELECT * FROM x;

			DROP TABLE IF EXISTS public.gallery_node_ltree;
			CREATE TABLE public.gallery_node_ltree
    			(
        			id serial       	UNIQUE,
        			gallery_id        	INTEGER,
        			parent_txt      	TEXT,
        			child_txt       	TEXT,
       				mypath          	ltree,
        			labels          	INTEGER,
					ltree_seq			INTEGER,	
        			lowest_descendant	BOOLEAN,
        			nested          	BOOLEAN
    			);

			CREATE INDEX path_gist_idx ON gallery_node_ltree USING gist(mypath);
			CREATE INDEX path_idx ON gallery_node_ltree USING btree(mypath);
	
			INSERT INTO gallery_node_ltree (gallery_id, parent_txt, child_txt, mypath, labels)
				SELECT	$1,
						parent_txt,
		   				child_txt,
						mypath,
		   				nlevel(mypath)
				FROM t_orga_mat
					ORDER BY mypath;

			UPDATE gallery_node_ltree
				SET lowest_descendant = TRUE
					WHERE child_txt NOT IN
						(SELECT parent_txt FROM gallery_node_ltree
							WHERE parent_txt IS NOT NULL);	
 			passed = 1;
            RETURN passed;
    	END
	$$
    LANGUAGE plpgsql

-- select * from fn_create_ltree (1);
