DROP FUNCTION IF EXISTS fn_test_fn_parameter;
CREATE OR REPLACE FUNCTION fn_test_fn_parameter (group_id INTEGER)
    RETURNS TABLE (p  TEXT, c  TEXT) AS
	$$
    	BEGIN
        	SELECT parent_txt, child_txt FROM group_node_ltree l
                WHERE l.group_id = $1;
        END
	$$
    LANGUAGE plpgsql
	
-- SELECT * FROM fn_test_fn_parameter(1);	