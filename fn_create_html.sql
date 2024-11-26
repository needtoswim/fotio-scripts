
-- SELECT * FROM fn_create_html (1);
CREATE OR REPLACE FUNCTION fn_create_html (g_id INTEGER)
    RETURNS BOOLEAN AS
	$$
    DECLARE passed BOOLEAN;
    	BEGIN
			DROP TABLE IF EXISTS span;
			CREATE TABLE span (
   				id SERIAL	UNIQUE,
				gallery_id	INTEGER,
				table_no	INTEGER,
				ltree_id	INTEGER,
				child		TEXT,
				row_source	CHARACTER VARYING COLLATE pg_catalog."default"
			);

			INSERT INTO span (gallery_id, table_no, ltree_id, child)
				(SELECT 1, l.gallery_id, l.id, n.child FROM gallery_node_ltree l
	 				INNER JOIN gallery_node n
	 				ON l.child_txt = n.child_id::TEXT
				 	AND n.gallery_id = $1
	 				WHERE lowest_descendant IS NULL);
		
			UPDATE span
				SET row_source = CONCAT('<li><span class="caret">', child,'</span>');

-- SELECT * FROM span;

			DROP TABLE IF EXISTS nest;
			CREATE TABLE nest (
   				id SERIAL	UNIQUE,
                table_no	INTEGER,   
				gallery_id	INTEGER,
				ltree_id	INTEGER,
				row_source	CHARACTER VARYING COLLATE pg_catalog."default"
			);

			INSERT INTO nest (table_no, gallery_id,  ltree_id)
					(SELECT 2, l.gallery_id, l.id FROM gallery_node_ltree l
	 		 			WHERE lowest_descendant IS NULL
						  AND l.gallery_id = $1);

			UPDATE nest
				SET row_source	= '<ul class="nested">';		  
				
			DROP TABLE IF EXISTS descendant;
			CREATE TABLE descendant (
   				id SERIAL	UNIQUE,
				table_no	INTEGER,
                gallery_id	INTEGER,
				ltree_id	INTEGER,
				child		TEXT,
				row_source	CHARACTER VARYING COLLATE pg_catalog."default"
			);

			INSERT INTO descendant (table_no, gallery_id, ltree_id, child)
				(SELECT 3, l.gallery_id, l.id, n.child FROM gallery_node_ltree l
	 				INNER JOIN gallery_node n
	 				ON l.child_txt = n.child_id::TEXT
				 	AND l.gallery_id = $1
	 				WHERE lowest_descendant IS TRUE);
		
			UPDATE descendant
				SET row_source = CONCAT('<li>', child,'</li>');
	

			DROP TABLE IF EXISTS gap;
			CREATE TABLE gap (
   				id SERIAL	UNIQUE,
				gallery_id	INTEGER,
				table_no	INTEGER,
				ltree_id	INTEGER,
				step		INTEGER,
				row_source	CHARACTER VARYING COLLATE pg_catalog."default"
			);

			WITH cte AS (
				SELECT 
					id AS ltree_id,
					gallery_id,
					labels
				FROM gallery_node_ltree
				ORDER BY id
			), cte2 AS (
			SELECT
				ltree_id,
				gallery_id,
				labels,
				LAG(labels,1) OVER (
				ORDER BY ltree_id
			) previous_labels
			FROM
				cte
			)	
			
			INSERT INTO gap (table_no, ltree_id, gallery_id, step)
				SELECT 
					4, 
					ltree_id,
					gallery_id,
					(labels - previous_labels) as step
			FROM 
				cte2
				WHERE (labels - previous_labels) < 0;

			DROP TABLE IF EXISTS gap_literal;
			CREATE TEMPORARY TABLE gap_literal (
   				id SERIAL		UNIQUE,
				gallery_id		INTEGER,
				step			INTEGER,
				step_literal	CHARACTER VARYING COLLATE pg_catalog."default"
			);

			INSERT INTO gap_literal (step, step_literal)
			VALUES
                (1,'</ul>'),
    			(2,'</ul></ul>'),
                (3,'</ul></ul><ul>'),
				(4,'</ul></ul></ul></ul>'),
				(5,'</ul></ul></ul></ul></ul>'),
				(6,'</ul></ul></ul></ul></ul></ul>'),
				(7,'</ul></ul></ul></ul></ul></ul></ul>'),
				(8,'</ul></ul></ul></ul></ul></ul></ul><ul>'),
				(9,'</ul></ul></ul></ul></ul></ul></ul></ul></ul>'),
				(10,'</ul></ul></ul></ul></ul></ul></ul></ul></ul></ul>')
			;

			UPDATE gap g
				SET row_source = l.step_literal
				FROM gap_literal l
				WHERE ABS(g.step) = l.step;  
	
            
            DROP TABLE IF EXISTS html_work;
			CREATE TABLE html_work (
                id SERIAL   UNIQUE,
                gallery_id  INTEGER,
				ltree_id    INTEGER,
				ltree_seq	INTEGER,
				html_pre   	CHARACTER VARYING COLLATE pg_catalog."default",
                html_row   	CHARACTER VARYING COLLATE pg_catalog."default",
				html_post   CHARACTER VARYING COLLATE pg_catalog."default",
				html_source CHARACTER VARYING COLLATE pg_catalog."default"
            );

			        
            INSERT INTO html_work (gallery_id, ltree_id)
				SELECT gallery_id, ltree_id FROM span 
					UNION 
				SELECT gallery_id, ltree_id FROM descendant
					ORDER BY ltree_id;

			UPDATE html_work h 
				SET ltree_seq = l.id
				FROM gallery_node_ltree l 
				WHERE h.ltree_id = l.id;	

			UPDATE html_work h
				SET html_row = s.row_source 
				FROM span s
				WHERE h.ltree_id = s.ltree_id;	
				
			UPDATE html_work h
				SET html_row = row_source 
				FROM descendant d
				WHERE h.ltree_id = d.ltree_id;	

			UPDATE html_work h
				SET html_post = n.row_source
				FROM nest n
				WHERE h.ltree_id = n.ltree_id;

			UPDATE html_work h
				SET html_pre = g.row_source
					FROM gap g
					WHERE h.ltree_id = g.ltree_id;

			UPDATE html_work h
				SET html_pre = COALESCE(html_pre, ' ');
				
			UPDATE html_work h
				SET html_post = COALESCE(html_post, ' ');

			UPDATE html_work
				SET html_pre = '<ul id="myUL>"';	

			UPDATE html_work
				SET html_source = CONCAT(html_pre, html_row, html_post);	

			passed = 1;
            RETURN passed;
    	END
	$$
    LANGUAGE plpgsql