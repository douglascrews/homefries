---------- Metadata Convenience Views ----------

CREATE OR REPLACE VIEW public.all_constraints AS
SELECT tc.table_name AS tab_name
     , kcu.column_name AS col_name
     , tc.constraint_name AS name
     , tc.constraint_type AS type
     , rc.update_rule AS on_update
     , rc.delete_rule AS on_delete
     , ccu.table_name AS references_table
     , ccu.column_name AS references_field
     , cc.check_clause
     , tc.is_deferrable
     , tc.initially_deferred
     , rc.match_option AS match_type
  FROM information_schema.table_constraints tc
  LEFT JOIN information_schema.key_column_usage kcu
    ON tc.constraint_catalog = kcu.constraint_catalog
   AND tc.constraint_schema = kcu.constraint_schema
   AND tc.constraint_name = kcu.constraint_name
  LEFT JOIN information_schema.referential_constraints rc
    ON tc.constraint_catalog = rc.constraint_catalog
   AND tc.constraint_schema = rc.constraint_schema
   AND tc.constraint_name = rc.constraint_name
  LEFT JOIN information_schema.constraint_column_usage ccu
    ON rc.unique_constraint_catalog = ccu.constraint_catalog
   AND rc.unique_constraint_schema = ccu.constraint_schema
   AND rc.unique_constraint_name = ccu.constraint_name
  LEFT JOIN information_schema.check_constraints cc
    ON cc.constraint_catalog = tc.constraint_catalog
   AND cc.constraint_schema = tc.constraint_schema
   AND cc.constraint_name = tc.constraint_name
 ORDER BY tc.table_name, tc.constraint_name;

--SELECT * FROM information_schema.check_constraints ORDER BY constraint_catalog, constraint_schema, constraint_name;
CREATE OR REPLACE VIEW public.all_check_constraints AS
SELECT constraint_catalog AS cat
     , constraint_schema AS schema
     , constraint_name AS name
     , check_clause AS constraint
  FROM information_schema.check_constraints;

CREATE OR REPLACE VIEW public.all_chk_cons AS
SELECT constraint_catalog AS cat
     , constraint_schema AS schema
     , constraint_name AS name
     , SUBSTR(check_clause, 1, 60) AS constraint
  FROM information_schema.check_constraints;
--SELECT * FROM information_schema.column_domain_usage;
--SELECT * FROM information_schema.column_privileges ORDER BY grantee, table_catalog, table_schema, table_name, column_name, privilege_type;

CREATE OR REPLACE VIEW public.all_column_privileges AS
SELECT grantee
     , table_catalog AS cat
     , table_schema AS schema
     , table_name AS tab_name
     , column_name AS col_name
     , privilege_type AS type
     , grantor
     , is_grantable AS with_grant
  FROM information_schema.column_privileges;

CREATE OR REPLACE VIEW public.all_col_privs AS
SELECT grantee
     , table_catalog AS cat
     , table_schema AS schema
     , table_name AS tab_name
     , column_name AS col_name
     , privilege_type AS type
     , grantor
     , is_grantable AS with_grant
  FROM information_schema.column_privileges;
--SELECT * FROM information_schema.column_udt_usage;
--SELECT * FROM information_schema.columns ORDER BY table_catalog, table_schema, table_name, column_name, ordinal_position;

CREATE OR REPLACE VIEW public.all_table_columns AS
SELECT table_catalog AS cat
     , table_schema AS schema
     , table_name AS tab_name
     , column_name AS col_name
     , ordinal_position AS col_num
     , data_type AS data_type
     , character_maximum_length AS char_len
     , numeric_precision AS precision
     , numeric_precision_radix AS radix
     , column_default AS default
     , is_nullable AS null_ok
  FROM information_schema.columns;

CREATE OR REPLACE VIEW public.all_tab_cols AS
SELECT table_catalog AS cat
     , table_schema AS schema
     , table_name AS tab_name
     , column_name AS col_name
     , ordinal_position AS col_num
     , data_type AS data_type
     , character_maximum_length AS char_len
     , numeric_precision AS precision
     , numeric_precision_radix AS radix
     , column_default AS default
     , is_nullable AS null_ok
  FROM information_schema.columns;
--SELECT * FROM information_schema.constraint_column_usage;
--SELECT * FROM information_schema.constraint_table_usage;
--SELECT * FROM information_schema.data_type_privileges;
--SELECT * FROM information_schema.domain_constraints ORDER BY constraint_catalog, constraint_schema, constraint_name;

CREATE OR REPLACE VIEW public.all_domain_constraints AS
SELECT constraint_catalog AS cat
     , constraint_schema AS schema
     , constraint_name AS name
     , domain_catalog || '.' || domain_schema || '.' || domain_name AS constraint
  FROM information_schema.domain_constraints;

CREATE OR REPLACE VIEW public.all_domain_cons AS
SELECT constraint_catalog AS cat
     , constraint_schema AS schema
     , constraint_name AS name
     , domain_catalog || '.' || domain_schema || '.' || domain_name AS constraint
  FROM information_schema.domain_constraints;
--SELECT * FROM information_schema.domain_udt_usage;
--SELECT * FROM information_schema.domains ORDER BY domain_catalog, domain_schema, domain_name;

CREATE OR REPLACE VIEW public.all_domains AS
SELECT domain_catalog AS cat
     , domain_schema AS schema
     , domain_name AS name
     , data_type
     , character_maximum_length AS max_chars
     , character_set_catalog || '.' || character_set_schema || '.' || character_set_name AS char_set
     , collation_catalog || '.' || collation_schema || '.' || collation_name AS collation_name
     , numeric_precision || '.' || numeric_scale || ' (Base ' || numeric_precision_radix || ')' AS precision
     , datetime_precision
     , interval_type
     , interval_precision
     , domain_default
     , udt_catalog || '.' || udt_schema || '.' || udt_name AS udt
     , scope_catalog || '.' || scope_schema || '.' || scope_name AS scope
     , maximum_cardinality AS cardinality
     , dtd_identifier AS dtd_id
  FROM information_schema.domains;

CREATE OR REPLACE VIEW public.all_dom AS
SELECT domain_catalog AS cat
     , domain_schema AS schema
     , domain_name AS name
     , CASE
          WHEN data_type = 'character varying' THEN 'VARCHAR(' || COALESCE(TO_CHAR(character_maximum_length, '9'), 'MAX') || ')'
          WHEN data_type = 'integer' THEN 'INTEGER(' || numeric_precision || '.' || numeric_scale || ' B' || numeric_precision_radix || ')'
          WHEN data_type = 'timestamp with time zone' THEN 'DATETIME(TIMEZONE)'
          ELSE data_type
       END AS data_type
     , character_set_catalog || '.' || character_set_schema || '.' || character_set_name AS charset
--     , collation_catalog || '.' || collation_schema || '.' || collation_name AS coll
     , interval_type || '(' || interval_precision || ')' AS interval
     , CASE
          WHEN domain_default IS NOT NULL THEN '(yes)'
          ELSE 'NULL'
       END AS default
     , udt_catalog || '.' || udt_schema || '.' || udt_name AS udt
--     , scope_catalog || '.' || scope_schema || '.' || scope_name AS scope
--     , maximum_cardinality AS crd
     , dtd_identifier AS dtd_id
  FROM information_schema.domains;
--SELECT * FROM information_schema.element_types ORDER BY object_catalog, object_schema, object_name, object_type;

CREATE OR REPLACE VIEW public.all_element_types AS
SELECT object_catalog AS cat
     , object_schema AS schema
     , object_name AS name
     , object_type AS type
     , data_type
     , character_maximum_length AS max_chars
     , character_set_catalog || '.' || character_set_schema || '.' || character_set_name AS char_set
     , collation_catalog || '.' || collation_schema || '.' || collation_name AS collation
     , numeric_precision || '.' || numeric_scale || ' (Base ' || numeric_precision_radix || ')' AS precision
     , domain_default
     , udt_catalog || '.' || udt_schema || '.' || udt_name AS udt
     , scope_catalog || '.' || scope_schema || '.' || scope_name AS scope
     , maximum_cardinality AS cardinality
     , dtd_identifier AS dtd_id
  FROM information_schema.element_types;

CREATE OR REPLACE VIEW public.all_elem_types AS
SELECT object_catalog AS cat
     , object_schema AS schema
     , object_name AS name
     , object_type AS type
     , data_type
--     , character_maximum_length AS max_chars
--     , character_set_catalog || '.' || character_set_schema || '.' || character_set_name AS char_set
--     , collation_catalog || '.' || collation_schema || '.' || collation_name AS collation
--     , numeric_precision || '.' || numeric_scale || ' (Base ' || numeric_precision_radix || ')' AS precision
--     , domain_default
--     , udt_catalog || '.' || udt_schema || '.' || udt_name AS udt
--     , scope_catalog || '.' || scope_schema || '.' || scope_name AS scope
--     , maximum_cardinality AS cardinality
     , dtd_identifier AS dtd_id
  FROM information_schema.element_types;
--SELECT * FROM information_schema.enabled_roles;

CREATE OR REPLACE VIEW public.current_roles AS
SELECT role_name AS name
  FROM information_schema.enabled_roles;
--SELECT * FROM information_schema.information_schema_catalog_name;

CREATE OR REPLACE VIEW public.current_catalog AS
SELECT catalog_name AS name
  FROM information_schema.information_schema_catalog_name;
--SELECT * FROM information_schema.key_column_usage ORDER BY constraint_catalog, constraint_schema, constraint_name, table_catalog, table_schema, table_name, column_name, ordinal_position;

CREATE OR REPLACE VIEW public.all_constraint_columns AS
SELECT constraint_catalog AS cns_cat
     , constraint_schema AS cns_schema
     , constraint_name AS cns_name
     , table_catalog AS tab_cat
     , table_schema AS tab_schema
     , table_name AS tab_name
     , column_name AS col_name
     , ordinal_position AS col_num
     , position_in_unique_constraint
  FROM information_schema.key_column_usage;

CREATE OR REPLACE VIEW public.all_cons_cols AS
SELECT constraint_catalog AS cns_cat
     , constraint_schema AS cns_schema
     , constraint_name AS cns_name
     , table_catalog AS tab_cat
     , table_schema AS tab_schema
     , table_name AS tab_name
     , column_name AS col_name
     , ordinal_position AS col_num
--     , position_in_unique_constraint
  FROM information_schema.key_column_usage;
--SELECT * FROM information_schema.parameters;
--SELECT * FROM information_schema.referential_constraints ORDER BY constraint_name, constraint_catalog, constraint_schema;

CREATE OR REPLACE VIEW public.all_reference_constraints AS
SELECT constraint_catalog AS cat
     , constraint_schema AS schema
     , constraint_name AS name
     , unique_constraint_catalog || '.' || unique_constraint_schema || '.' || unique_constraint_name || ' (UPDATE=' || update_rule || ',DELETE=' || delete_rule || ',MATCH=' || match_option ||')' AS constraint
  FROM information_schema.referential_constraints;

CREATE OR REPLACE VIEW public.all_ref_cons AS
SELECT constraint_catalog AS cat
     , constraint_schema AS schema
     , SUBSTR(constraint_name, 1, 30) AS name
     , unique_constraint_catalog || '.' || unique_constraint_schema || '.' || unique_constraint_name || ' (UPDATE=' || update_rule || ',DELETE=' || delete_rule || ',MATCH=' || match_option ||')' AS constraint
  FROM information_schema.referential_constraints;
--SELECT * FROM information_schema.role_column_grants;
-- See also routine_privileges. This is by group, not user.
--SELECT * FROM information_schema.role_routine_grants ORDER BY grantee, specific_catalog, specific_schema, specific_name;

CREATE OR REPLACE VIEW public.dba_indexes AS
SELECT n.nspname AS schema_name
     , t.relname AS table_name
     , c.relname AS index_name
     , pg_catalog.pg_table_is_visible(c.oid) AS visible
     , pg_get_indexdef(indexrelid) AS def
     , ARRAY_TO_STRING(ARRAY_AGG(a.attname), ', ') AS column_names
  FROM pg_catalog.pg_class c
  JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
  JOIN pg_catalog.pg_index i ON i.indexrelid = c.oid
  JOIN pg_catalog.pg_class t ON i.indrelid = t.oid
  JOIN pg_catalog.pg_attribute a ON a.attrelid = c.oid
   AND a.attnum = ANY(i.indkey)
 GROUP BY n.nspname, t.relname, c.relname, pg_catalog.pg_table_is_visible(c.oid), pg_get_indexdef(indexrelid);

CREATE OR REPLACE VIEW public.all_indexes AS
SELECT n.nspname AS schema_name
     , t.relname AS table_name
     , c.relname AS index_name
     , pg_catalog.pg_table_is_visible(c.oid) AS visible
     , pg_get_indexdef(indexrelid) AS def
     , ARRAY_TO_STRING(ARRAY_AGG(a.attname), ', ') AS column_names
  FROM pg_catalog.pg_class c
  JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
  JOIN pg_catalog.pg_index i ON i.indexrelid = c.oid
  JOIN pg_catalog.pg_class t ON i.indrelid = t.oid
  JOIN pg_catalog.pg_attribute a ON a.attrelid = c.oid
   AND a.attnum = ANY(i.indkey)
 WHERE n.nspname NOT IN ('pg_catalog', 'pg_toast', 'information_schema')
   AND pg_catalog.pg_table_is_visible(c.oid) IS TRUE
 GROUP BY n.nspname, t.relname, c.relname, pg_catalog.pg_table_is_visible(c.oid), pg_get_indexdef(indexrelid);

CREATE OR REPLACE VIEW public.all_partitioned_tables AS
SELECT pgn2.nspname AS table_schema
     , pgc2.relname AS parent_table_name
     , pgc.relname AS child_table_name
  FROM pg_class pgc
  JOIN pg_namespace pgn ON pgc.relnamespace = pgn.oid
  JOIN pg_inherits pgi ON pgi.inhrelid = pgc.oid
  JOIN pg_class pgc2 ON pgi.inhparent = pgc2.oid
  JOIN pg_namespace pgn2 ON pgc2.relnamespace = pgn2.oid;

CREATE OR REPLACE VIEW public.all_procedure_privileges AS
SELECT grantee
     , specific_catalog AS spec_cat
     , specific_schema AS spec_schema
     , specific_name AS spec_name
     , routine_catalog AS proc_cat
     , routine_schema AS proc_schema
     , routine_name AS proc_name
     , privilege_type AS type
     , grantor
     , is_grantable AS with_grant
  FROM information_schema.role_routine_grants
 UNION
SELECT grantee
     , specific_catalog AS spec_cat
     , specific_schema AS spec_schema
     , specific_name AS spec_name
     , routine_catalog AS proc_cat
     , routine_schema AS proc_schema
     , routine_name AS proc_name
     , privilege_type AS type
     , grantor
     , is_grantable AS with_grant
  FROM information_schema.routine_privileges;

CREATE OR REPLACE VIEW public.all_proc_privs AS
SELECT grantee
     , specific_catalog AS s_cat
     , SUBSTR(specific_schema, 1, 12) AS spec_schema
     , SUBSTR(specific_name, 1, 25) AS spec_name
     , routine_catalog AS p_cat
     , SUBSTR(routine_schema, 1, 12) AS proc_schema
     , SUBSTR(routine_name, 1, 25) AS proc_name
     , privilege_type AS type
     , grantor
     , is_grantable AS with_grant
  FROM information_schema.role_routine_grants
 UNION
SELECT grantee
     , specific_catalog AS s_cat
     , SUBSTR(specific_schema, 1, 12) AS spec_schema
     , SUBSTR(specific_name, 1, 25) AS spec_name
     , routine_catalog AS p_cat
     , SUBSTR(routine_schema, 1, 12) AS proc_schema
     , SUBSTR(routine_name, 1, 25) AS proc_name
     , privilege_type AS type
     , grantor
     , is_grantable AS with_grant
  FROM information_schema.routine_privileges;

CREATE OR REPLACE VIEW public.all_role_table_privileges AS
SELECT grantee
     , table_catalog AS cat
     , table_schema AS schema
     , table_name AS name
     , privilege_type AS type
     , grantor
     , is_grantable AS with_grant
     , with_hierarchy AS hier
  FROM information_schema.role_table_grants;

CREATE OR REPLACE VIEW public.all_table_grants AS
SELECT grantee
     , table_catalog AS cat
     , table_schema AS schema
     , table_name AS name
     , privilege_type AS type
     , grantor
     , is_grantable AS with_grant
     , with_hierarchy AS hier
  FROM information_schema.role_table_grants;

CREATE OR REPLACE VIEW public.user_table_grants AS
SELECT grantee
     , table_catalog AS cat
     , table_schema AS schema
     , table_name AS name
     , privilege_type AS type
     , grantor
     , is_grantable AS with_grant
     , with_hierarchy AS hier
  FROM information_schema.role_table_grants
 WHERE grantee = CURRENT_USER;

CREATE OR REPLACE VIEW public.dba_role_assignments AS
WITH role_assignments AS (
     SELECT b.rolname, m.member
       FROM pg_catalog.pg_auth_members m
       JOIN pg_catalog.pg_roles b ON m.roleid = b.oid
)
SELECT r.rolname AS username
     , r.rolsuper AS is_superuser
     , r.rolinherit AS is_inherit
     , r.rolcreaterole AS can_create_role
     , r.rolcreatedb AS can_create_db
     , r.rolcanlogin AS can_login
     , r.rolconnlimit AS conn_limit
     , r.rolvaliduntil AS expires
     , r.rolreplication AS can_replicate
     , r.rolbypassrls AS bypass_rls
     , ra.rolname AS granted_role
  FROM pg_catalog.pg_roles r
  JOIN role_assignments ra ON ra.member = r.oid;

CREATE OR REPLACE VIEW public.all_role_assignments AS
WITH role_assignments AS (
     SELECT b.rolname, m.member
       FROM pg_catalog.pg_auth_members m
       JOIN pg_catalog.pg_roles b ON m.roleid = b.oid
)
SELECT r.rolname AS username
     , r.rolsuper AS is_superuser
     , r.rolinherit AS is_inherit
     , r.rolcreaterole AS can_create_role
     , r.rolcreatedb AS can_create_db
     , r.rolcanlogin AS can_login
     , r.rolconnlimit AS conn_limit
     , r.rolvaliduntil AS expires
     , r.rolreplication AS can_replicate
     , r.rolbypassrls AS bypass_rls
     , ra.rolname AS granted_role
  FROM pg_catalog.pg_roles r
  JOIN role_assignments ra ON ra.member = r.oid
 WHERE r.rolname !~ '^pg_';

CREATE OR REPLACE VIEW public.user_role_assignments AS
WITH role_assignments AS (
     SELECT b.rolname, m.member
       FROM pg_catalog.pg_auth_members m
       JOIN pg_catalog.pg_roles b ON m.roleid = b.oid
)
SELECT r.rolname AS username
     , r.rolsuper AS is_superuser
     , r.rolinherit AS is_inherit
     , r.rolcreaterole AS can_create_role
     , r.rolcreatedb AS can_create_db
     , r.rolcanlogin AS can_login
     , r.rolconnlimit AS conn_limit
     , r.rolvaliduntil AS expires
     , r.rolreplication AS can_replicate
     , r.rolbypassrls AS bypass_rls
     , ra.rolname AS granted_role
  FROM pg_catalog.pg_roles r
  JOIN role_assignments ra ON ra.member = r.oid
 WHERE r.rolname = CURRENT_USER;

CREATE OR REPLACE VIEW public.dba_table_privileges AS
SELECT r.rolname AS username
     , t.schemaname
     , t.tablename
     , has_table_privilege(r.rolname, t.schemaname || '.' || t.tablename, 'select') AS sel
     , has_table_privilege(r.rolname, t.schemaname || '.' || t.tablename, 'insert') AS ins
     , has_table_privilege(r.rolname, t.schemaname || '.' || t.tablename, 'update') AS upd
     , has_table_privilege(r.rolname, t.schemaname || '.' || t.tablename, 'delete') AS del
     , has_table_privilege(r.rolname, t.schemaname || '.' || t.tablename, 'truncate') AS trunc
     , has_table_privilege(r.rolname, t.schemaname || '.' || t.tablename, 'references') AS refer
     , has_table_privilege(r.rolname, t.schemaname || '.' || t.tablename, 'trigger') AS trig
  FROM ( SELECT schemaname, tablename FROM pg_tables
          UNION
         SELECT schemaname, viewname AS tablename FROM pg_views
          UNION
         SELECT schemaname, matviewname AS tablename FROM pg_matviews
       ) t
     , pg_roles r
 WHERE r.rolcanlogin = TRUE;

DROP VIEW IF EXISTS public.all_table_privileges;
CREATE OR REPLACE VIEW public.all_table_privileges AS
SELECT r.rolname AS username
     , t.schemaname
     , t.tablename
     , has_table_privilege(r.rolname, t.schemaname || '.' || t.tablename, 'select') AS sel
     , has_table_privilege(r.rolname, t.schemaname || '.' || t.tablename, 'insert') AS ins
     , has_table_privilege(r.rolname, t.schemaname || '.' || t.tablename, 'update') AS upd
     , has_table_privilege(r.rolname, t.schemaname || '.' || t.tablename, 'delete') AS del
     , has_table_privilege(r.rolname, t.schemaname || '.' || t.tablename, 'truncate') AS trunc
     , has_table_privilege(r.rolname, t.schemaname || '.' || t.tablename, 'references') AS refer
     , has_table_privilege(r.rolname, t.schemaname || '.' || t.tablename, 'trigger') AS trig
  FROM ( SELECT schemaname, tablename FROM pg_tables
          UNION
         SELECT schemaname, viewname AS tablename FROM pg_views
          UNION
         SELECT schemaname, matviewname AS tablename FROM pg_matviews
       ) t
     , pg_roles r
 WHERE r.rolcanlogin = TRUE
   AND schemaname NOT IN ('pg_catalog', 'information_schema');

CREATE OR REPLACE VIEW public.user_table_privileges AS
SELECT r.rolname AS username
     , t.schemaname
     , t.tablename
     , has_table_privilege(r.rolname, t.schemaname || '.' || t.tablename, 'select') AS sel
     , has_table_privilege(r.rolname, t.schemaname || '.' || t.tablename, 'insert') AS ins
     , has_table_privilege(r.rolname, t.schemaname || '.' || t.tablename, 'update') AS upd
     , has_table_privilege(r.rolname, t.schemaname || '.' || t.tablename, 'delete') AS del
     , has_table_privilege(r.rolname, t.schemaname || '.' || t.tablename, 'truncate') AS trunc
     , has_table_privilege(r.rolname, t.schemaname || '.' || t.tablename, 'references') AS refer
     , has_table_privilege(r.rolname, t.schemaname || '.' || t.tablename, 'trigger') AS trig
  FROM ( SELECT schemaname, tablename FROM pg_tables
          UNION
         SELECT schemaname, viewname AS tablename FROM pg_views
          UNION
         SELECT schemaname, matviewname AS tablename FROM pg_matviews
       ) t
     , pg_roles r
 WHERE r.rolcanlogin = TRUE
   AND schemaname NOT IN ('pg_catalog', 'information_schema')
   AND r.rolname = CURRENT_USER;

DROP VIEW IF EXISTS public.all_users;
CREATE OR REPLACE VIEW public.all_users AS
SELECT pgu.usename AS username
     , pgu.usesysid AS id
     , pgu.usesuper AS superuser
     , pgu.usecreatedb AS createdb
     , pgu.userepl AS replication
     , pgu.usebypassrls AS bypass_rls
     , pgu.valuntil AS expires
     , pgu.useconfig AS userconfig
  FROM pg_catalog.pg_user pgu;

--SELECT * FROM information_schema.role_usage_grants;
-- See also role_routine_grants. This is by user, not group.
--SELECT * FROM information_schema.routine_privileges ORDER BY grantee, specific_catalog, specific_schema, specific_name, routine_catalog, routine_schema, routine_name;
--SELECT * FROM information_schema.routines;

CREATE OR REPLACE VIEW public.routines AS
SELECT *
  FROM information_schema.routines;

CREATE OR REPLACE VIEW public.dba_schemas AS
SELECT *
  FROM information_schema.schemata;

CREATE OR REPLACE VIEW public.all_schemas AS
SELECT *
  FROM information_schema.schemata
 WHERE schema_owner NOT IN ('postgres');

CREATE OR REPLACE VIEW public.user_schemas AS
SELECT *
  FROM information_schema.schemata
 WHERE schema_owner = CURRENT_USER;

CREATE OR REPLACE VIEW public.schemas AS
SELECT catalog_name AS cat
     , schema_name AS schema
     , schema_owner AS owner
     , default_character_set_catalog AS charset_cat
     , default_character_set_schema AS charset_schema
     , default_character_set_name AS charset_name
     , SUBSTR(sql_path, 1, 30) AS sql_path
  FROM information_schema.schemata;
--SELECT * FROM information_schema.sql_features;
--SELECT * FROM information_schema.sql_implementation_info;
--SELECT * FROM information_schema.sql_languages;
--SELECT * FROM information_schema.sql_packages;
--SELECT * FROM information_schema.sql_sizing;
--SELECT * FROM information_schema.sql_sizing_profiles;
--SELECT * FROM information_schema.table_constraints ORDER BY constraint_catalog, constraint_schema, constraint_name, constraint_type, table_catalog, table_schema, table_name;

CREATE OR REPLACE VIEW public.all_table_constraints AS
SELECT tc.constraint_catalog AS cat
     , tc.constraint_schema AS schema
     , tc.constraint_name AS name
     , tc.constraint_type AS type
     , tc.table_catalog AS tab_cat
     , tc.table_schema AS tab_schema
     , tc.table_name AS tab_name
     , tc.is_deferrable AS defer
     , tc.initially_deferred AS deferred
     , c.constraint
  FROM information_schema.table_constraints AS tc
  LEFT OUTER JOIN (
SELECT constraint_name
     , constraint_catalog
     , constraint_schema
     , check_clause AS constraint
  FROM information_schema.check_constraints
 UNION
SELECT constraint_name
     , constraint_catalog
     , constraint_schema
     , unique_constraint_catalog || '.' || unique_constraint_schema || '.' || unique_constraint_name || ' (UPDATE=' || update_rule || ',DELETE=' || delete_rule || ',MATCH=' || match_option ||')' AS constraint
  FROM information_schema.referential_constraints
 UNION
SELECT constraint_name
     , constraint_catalog
     , constraint_schema
     , domain_catalog || '.' || domain_schema || '.' || domain_name AS constraint
  FROM information_schema.domain_constraints
     ) AS c
    ON c.constraint_name = tc.constraint_name
   AND c.constraint_catalog = tc.constraint_catalog
   AND c.constraint_schema = tc.constraint_schema;

CREATE OR REPLACE VIEW public.all_tab_cons AS
SELECT tc.constraint_catalog || '.' || tc.constraint_schema || '.' || tc.constraint_name AS name
     , CASE
          WHEN tc.constraint_type = 'PRIMARY KEY' THEN 'PK'
          WHEN tc.constraint_type = 'FOREIGN KEY' THEN 'FK'
          WHEN tc.constraint_type = 'CHECK' THEN 'CHK'
          WHEN tc.constraint_type = 'UNIQUE' THEN 'UK'
          ELSE tc.constraint_type
       END AS type
     , tc.table_catalog || '.' || tc.table_schema || '.' || tc.table_name AS tab_name
     , tc.is_deferrable AS defer
     , tc.initially_deferred AS deferred
     , c.constraint
  FROM information_schema.table_constraints AS tc
  LEFT OUTER JOIN (
SELECT constraint_name
     , constraint_catalog
     , constraint_schema
     , check_clause AS constraint
  FROM information_schema.check_constraints
 UNION
SELECT constraint_name
     , constraint_catalog
     , constraint_schema
     , unique_constraint_catalog || '.' || unique_constraint_schema || '.' || unique_constraint_name || ' (UPDATE=' || update_rule || ',DELETE=' || delete_rule || ',MATCH=' || match_option ||')' AS constraint
  FROM information_schema.referential_constraints
 UNION
SELECT constraint_name
     , constraint_catalog
     , constraint_schema
     , domain_catalog || '.' || domain_schema || '.' || domain_name AS constraint
  FROM information_schema.domain_constraints
     ) AS c
    ON c.constraint_name = tc.constraint_name
   AND c.constraint_catalog = tc.constraint_catalog
   AND c.constraint_schema = tc.constraint_schema;
--SELECT * FROM information_schema.table_privileges;

CREATE OR REPLACE VIEW public.all_tab_privs AS
SELECT grantee
     , table_catalog AS cat
     , table_schema AS schema
     , table_name AS tab_name
     , privilege_type AS type
     , grantor
     , is_grantable AS with_grant
     , with_hierarchy AS hier
  FROM information_schema.table_privileges;
--SELECT * FROM information_schema.tables ORDER BY table_catalog, table_schema, table_name;

CREATE OR REPLACE VIEW public.dba_tables AS
SELECT table_catalog AS cat
     , table_schema AS schema
     , table_name AS name
     , is_insertable_into AS insert
     , is_typed AS typed
     , commit_action
     , self_referencing_column_name AS self_ref_col_name
     , reference_generation
     , user_defined_type_catalog AS user_def_cat
     , user_defined_type_schema AS user_def_schema
     , user_defined_type_name AS user_def_name
  FROM information_schema.tables
 WHERE table_type = 'BASE TABLE';

CREATE OR REPLACE VIEW public.all_tables AS
SELECT table_catalog AS cat
     , table_schema AS schema
     , table_name AS name
     , is_insertable_into AS insert
     , is_typed AS typed
     , commit_action
     , self_referencing_column_name AS self_ref_col_name
     , reference_generation
     , user_defined_type_catalog AS user_def_cat
     , user_defined_type_schema AS user_def_schema
     , user_defined_type_name AS user_def_name
  FROM information_schema.tables
 WHERE table_type = 'BASE TABLE'
   AND table_schema NOT IN ('information_schema', 'pg_catalog');

CREATE OR REPLACE VIEW public.user_foreign_tables AS
SELECT table_catalog AS cat
     , table_schema AS schema
     , table_name AS name
     , is_insertable_into AS insert
     , is_typed AS typed
     , commit_action
     , self_referencing_column_name AS self_ref_col_name
     , reference_generation
     , user_defined_type_catalog AS user_def_cat
     , user_defined_type_schema AS user_def_schema
     , user_defined_type_name AS user_def_name
  FROM information_schema.tables
 WHERE table_type = 'BASE TABLE'
   AND table_schema = CURRENT_SCHEMA;

CREATE OR REPLACE VIEW public.all_tabs AS
SELECT table_catalog AS cat
     , table_schema AS schema
     , table_name AS name
     , is_insertable_into AS ins
     , is_typed AS typed
     , commit_action AS commit
     , self_referencing_column_name AS self_ref
     , reference_generation AS ref_gen
     , user_defined_type_catalog || '.' || user_defined_type_schema || '.' || user_defined_type_name AS user_def_name
  FROM information_schema.tables
 WHERE table_type = 'BASE TABLE';

--SELECT * FROM information_schema.triggered_update_columns ORDER BY event_object_catalog, event_object_schema, event_object_table, event_object_column, trigger_catalog, trigger_schema, trigger_name;

CREATE OR REPLACE VIEW public.dba_foreign_tables AS
SELECT table_catalog AS cat
     , table_schema AS schema
     , table_name AS name
     , is_insertable_into AS insert
     , is_typed AS typed
     , commit_action
     , self_referencing_column_name AS self_ref_col_name
     , reference_generation
     , user_defined_type_catalog AS user_def_cat
     , user_defined_type_schema AS user_def_schema
     , user_defined_type_name AS user_def_name
  FROM information_schema.tables
 WHERE table_type = 'FOREIGN TABLE';

CREATE OR REPLACE VIEW public.all_foreign_tables AS
SELECT table_catalog AS cat
     , table_schema AS schema
     , table_name AS name
     , is_insertable_into AS insert
     , is_typed AS typed
     , commit_action
     , self_referencing_column_name AS self_ref_col_name
     , reference_generation
     , user_defined_type_catalog AS user_def_cat
     , user_defined_type_schema AS user_def_schema
     , user_defined_type_name AS user_def_name
  FROM information_schema.tables
 WHERE table_type = 'FOREIGN TABLE'
   AND table_schema NOT IN ('information_schema', 'pg_catalog');

CREATE OR REPLACE VIEW public.user_tables AS
SELECT table_catalog AS cat
     , table_schema AS schema
     , table_name AS name
     , is_insertable_into AS insert
     , is_typed AS typed
     , commit_action
     , self_referencing_column_name AS self_ref_col_name
     , reference_generation
     , user_defined_type_catalog AS user_def_cat
     , user_defined_type_schema AS user_def_schema
     , user_defined_type_name AS user_def_name
  FROM information_schema.tables
 WHERE table_type = 'BASE TABLE'
   AND table_schema = CURRENT_SCHEMA;

CREATE OR REPLACE VIEW public.user_foreign_tables AS
SELECT table_catalog AS cat
     , table_schema AS schema
     , table_name AS name
     , is_insertable_into AS insert
     , is_typed AS typed
     , commit_action
     , self_referencing_column_name AS self_ref_col_name
     , reference_generation
     , user_defined_type_catalog AS user_def_cat
     , user_defined_type_schema AS user_def_schema
     , user_defined_type_name AS user_def_name
  FROM information_schema.tables
 WHERE table_type = 'FOREIGN TABLE'
   AND table_schema = CURRENT_SCHEMA;

CREATE OR REPLACE VIEW public.all_trigger_columns AS
SELECT event_object_catalog AS cat
     , event_object_schema AS schema
     , event_object_table AS tab_name
     , event_object_column AS col_name
     , trigger_catalog AS trig_cat
     , trigger_schema AS trig_schema
     , trigger_name AS trig_name
  FROM information_schema.triggered_update_columns;

CREATE OR REPLACE VIEW public.all_trig_cols AS
SELECT event_object_catalog AS cat
     , event_object_schema AS schema
     , event_object_table AS tab_name
     , event_object_column AS col_name
     , trigger_catalog AS trig_cat
     , trigger_schema AS trig_schema
     , trigger_name AS trig_name
  FROM information_schema.triggered_update_columns;
--SELECT * FROM information_schema.triggers ORDER BY trigger_catalog, trigger_schema, trigger_name, action_timing, event_manipulation, action_orientation;

CREATE OR REPLACE VIEW public.all_triggers AS
SELECT trigger_catalog AS cat
     , trigger_schema AS schema
     , trigger_name AS name
     , action_timing AS timing
     , event_manipulation AS event
     , action_orientation AS each
     , event_object_catalog AS tab_cat
     , event_object_schema AS tab_schema
     , event_object_table AS tab_name
     , action_order
     , action_condition
     , action_statement
     , action_reference_old_table AS old_tab_name
     , action_reference_new_table AS new_tab_name
     , action_reference_old_row AS old_row
     , action_reference_new_row AS new_row
     , created
  FROM information_schema.triggers;

CREATE OR REPLACE VIEW public.all_trigs AS
SELECT trigger_catalog AS cat
     , trigger_schema AS schema
     , trigger_name AS name
     , action_timing AS timing
     , event_manipulation AS event
     , action_orientation AS each
     , event_object_catalog AS t_cat
     , event_object_schema AS t_schema
     , event_object_table AS tab_name
--     , action_order
--     , action_condition
     , action_statement
--     , action_reference_old_table AS old_tab_name
--     , action_reference_new_table AS new_tab_name
--     , action_reference_old_row AS old_row
--     , action_reference_new_row AS new_row
--     , created
  FROM information_schema.triggers;
--SELECT * FROM information_schema.usage_privileges;
--SELECT * FROM information_schema.view_column_usage ORDER BY view_catalog, view_schema, view_name, table_catalog, table_schema, table_name, column_name;

CREATE OR REPLACE VIEW public.all_view_columns AS
SELECT view_catalog AS cat
     , view_schema AS schema
     , view_name AS name
     , table_catalog AS tab_cat
     , table_schema AS tab_schema
     , table_name AS tab_name
     , column_name AS col_name
  FROM information_schema.view_column_usage;

CREATE OR REPLACE VIEW public.all_vw_cols AS
SELECT view_catalog AS cat
     , SUBSTR(view_schema, 1, 12) AS schema
     , view_name AS name
     , table_catalog AS t_cat
     , SUBSTR(table_schema, 1, 12) AS tab_schema
     , table_name AS tab_name
     , column_name AS col_name
  FROM information_schema.view_column_usage;
--SELECT * FROM information_schema.view_table_usage ORDER BY view_catalog, view_schema, view_name, table_catalog, table_schema, table_name;
--SELECT * FROM information_schema.views ORDER BY table_catalog, table_schema, table_name;

CREATE OR REPLACE VIEW public.dba_views AS
SELECT table_catalog AS cat
     , table_schema AS schema
     , table_name AS name
     , check_option AS check
     , is_updatable AS update
     , is_insertable_into AS insert
     , is_trigger_updatable AS trig_update
     , is_trigger_deletable AS trig_delete
     , is_trigger_insertable_into AS trig_insert
     , view_definition
  FROM information_schema.views;

CREATE OR REPLACE VIEW public.all_views AS
SELECT table_catalog AS cat
     , table_schema AS schema
     , table_name AS name
     , check_option AS check
     , is_updatable AS update
     , is_insertable_into AS insert
     , is_trigger_updatable AS trig_update
     , is_trigger_deletable AS trig_delete
     , is_trigger_insertable_into AS trig_insert
     , view_definition
  FROM information_schema.views
 WHERE table_schema NOT IN ('information_schema', 'pg_catalog');

CREATE OR REPLACE VIEW public.dba_vws AS
SELECT table_catalog AS cat
     , table_schema AS schema
     , table_name AS name
     , check_option AS check
     , is_updatable AS update
     , is_insertable_into AS insert
     , is_trigger_updatable AS trig_update
     , is_trigger_deletable AS trig_delete
     , is_trigger_insertable_into AS trig_insert
--     , view_definition
  FROM information_schema.views;

CREATE OR REPLACE VIEW public.all_vws AS
SELECT table_catalog AS cat
     , table_schema AS schema
     , table_name AS name
     , check_option AS check
     , is_updatable AS update
     , is_insertable_into AS insert
     , is_trigger_updatable AS trig_update
     , is_trigger_deletable AS trig_delete
     , is_trigger_insertable_into AS trig_insert
--     , view_definition
  FROM information_schema.views
 WHERE table_schema NOT IN ('information_schema', 'pg_catalog');

CREATE OR REPLACE VIEW public.all_sequences AS
SELECT relname AS name
     , relhaspkey AS pk
     , relhasrules AS rules
     , relhastriggers AS trigs
     , relhassubclass AS subclass
     , relispopulated AS populated
  FROM pg_class
 WHERE relkind = 'S'
   AND relnamespace IN
     ( SELECT oid
         FROM pg_namespace
        WHERE nspname NOT LIKE 'pg_%'
          AND nspname != 'information_schema'
      );

CREATE OR REPLACE VIEW public.dba_procs AS
SELECT n.nspname AS schema
     , p.proname AS name
     , OIDVECTORTYPES(p.proargtypes) AS args
     , REPLACE(((((n.nspname::TEXT || '.') || p.proname::TEXT) || '(') || OIDVECTORTYPES(p.proargtypes)) || ')', ' ', '') AS signature
     , t1.typname AS return_type
     , a.rolname AS owner
     , l.lanname AS language
     , p.prosrc AS body
  FROM pg_proc p
  LEFT JOIN pg_namespace n ON n.oid = p.pronamespace
  LEFT JOIN pg_type t1 ON p.prorettype = t1.oid
  LEFT JOIN pg_roles a ON p.proowner = a.oid
  LEFT JOIN pg_language l ON p.prolang = l.oid;

CREATE OR REPLACE VIEW public.all_procs AS
SELECT n.nspname AS schema
     , p.proname AS name
     , OIDVECTORTYPES(p.proargtypes) AS args
     , REPLACE(((((n.nspname::TEXT || '.') || p.proname::TEXT) || '(') || OIDVECTORTYPES(p.proargtypes)) || ')', ' ', '') AS signature
     , t1.typname AS return_type
     , a.rolname AS owner
     , l.lanname AS language
     , p.prosrc AS body
  FROM pg_proc p
  LEFT JOIN pg_namespace n ON n.oid = p.pronamespace
  LEFT JOIN pg_type t1 ON p.prorettype = t1.oid
  LEFT JOIN pg_roles a ON p.proowner = a.oid
  LEFT JOIN pg_language l ON p.prolang = l.oid
 WHERE a.rolname NOT IN ('rdsadmin');

--DROP VIEW public.my_sess;
--DROP VIEW public.v_user_sess;
--DROP VIEW public.user_sess;
--DROP VIEW public.all_sess;
--DROP VIEW public.dba_sess;
--DROP VIEW public.my_sessions;
--DROP VIEW public.v_user_sessions;
--DROP VIEW public.user_sessions;
--DROP VIEW public.all_sessions;
--DROP VIEW public.dba_sessions;

CREATE OR REPLACE VIEW public.dba_sessions AS
SELECT usename AS user_name
     , application_name AS app_name
     , client_addr
     , pid
     , DATE_TRUNC('second', backend_start) AS login_datetime
     , DATE_TRUNC('second', AGE(NOW(), xact_start)) AS xact_elapsed
     , DATE_TRUNC('second', AGE(NOW(), query_start)) AS query_elapsed
     , DATE_TRUNC('second', AGE(NOW(), DATE_TRUNC('second', backend_start))) AS login_time
--     , CASE waiting WHEN 't' THEN 'WAIT' ELSE 'BUSY' END AS wait -- v9.5-
     , state -- v9.6+
     , REGEXP_REPLACE(query, '[ \t\n]+', ' ', 'g') AS query
  FROM pg_stat_activity;

CREATE OR REPLACE VIEW public.all_sessions AS
SELECT usename AS user_name
     , application_name AS app_name
     , client_addr
     , pid
     , DATE_TRUNC('second', backend_start) AS login_datetime
     , DATE_TRUNC('second', AGE(NOW(), xact_start)) AS xact_elapsed
     , DATE_TRUNC('second', AGE(NOW(), query_start)) AS query_elapsed
     , DATE_TRUNC('second', AGE(NOW(), DATE_TRUNC('second', backend_start))) AS login_time
--     , CASE waiting WHEN 't' THEN 'WAIT' ELSE 'BUSY' END AS wait -- v9.5-
     , state -- v9.6+
     , REGEXP_REPLACE(query, '[ \t\n]+', ' ', 'g') AS query
  FROM pg_stat_activity
 WHERE usename NOT IN ('rdsadmin')
    OR query != '<insufficient privilege>';

CREATE OR REPLACE VIEW public.user_sessions AS
SELECT usename AS user_name
     , application_name AS app_name
     , client_addr
     , pid
     , DATE_TRUNC('second', backend_start) AS login_datetime
     , DATE_TRUNC('second', AGE(NOW(), xact_start)) AS xact_elapsed
     , DATE_TRUNC('second', AGE(NOW(), query_start)) AS query_elapsed
     , DATE_TRUNC('second', AGE(NOW(), DATE_TRUNC('second', backend_start))) AS login_time
--     , CASE waiting WHEN 't' THEN 'WAIT' ELSE 'BUSY' END AS wait -- v9.5-
     , state -- v9.6+
     , REGEXP_REPLACE(query, '[ \t\n]+', ' ', 'g') AS query
  FROM pg_stat_activity
 WHERE usename = CURRENT_USER;

CREATE OR REPLACE VIEW public.my_sessions AS
SELECT usename AS user_name
     , application_name AS app_name
     , client_addr
     , pid
     , DATE_TRUNC('second', backend_start) AS login_datetime
     , DATE_TRUNC('second', AGE(NOW(), xact_start)) AS xact_elapsed
     , DATE_TRUNC('second', AGE(NOW(), query_start)) AS query_elapsed
     , DATE_TRUNC('second', AGE(NOW(), DATE_TRUNC('second', backend_start))) AS login_time
--     , CASE waiting WHEN 't' THEN 'WAIT' ELSE 'BUSY' END AS wait -- v9.5-
     , state -- v9.6+
     , REGEXP_REPLACE(query, '[ \t\n]+', ' ', 'g') AS query
  FROM pg_stat_activity
 WHERE
     ( usename NOT IN ('rdsadmin')
    OR query != '<insufficient privilege>'
     )
   AND client_addr IN
     ( SELECT client_addr
         FROM pg_stat_activity
        WHERE query = CURRENT_QUERY()
          AND usename = CURRENT_USER
     );

CREATE OR REPLACE VIEW public.dba_sess AS
SELECT usename AS user_name
     , SUBSTRING(application_name FROM 1 FOR 20) AS app_name
     , client_addr
     , pid
     , DATE_TRUNC('second', AGE(NOW(), DATE_TRUNC('second', backend_start))) AS login_time
     , state
     , REGEXP_REPLACE(query, '[ \t\n]+', ' ', 'g') AS query
  FROM pg_stat_activity;

CREATE OR REPLACE VIEW public.all_sess AS
SELECT usename AS user_name
     , SUBSTRING(application_name FROM 1 FOR 20) AS app_name
     , client_addr
     , pid
     , DATE_TRUNC('second', AGE(NOW(), DATE_TRUNC('second', backend_start))) AS login_time
     , state
     , REGEXP_REPLACE(query, '[ \t\n]+', ' ', 'g') AS query
  FROM pg_stat_activity
 WHERE usename NOT IN ('rdsadmin')
    OR query != '<insufficient privilege>';

CREATE OR REPLACE VIEW public.user_sess AS
SELECT usename AS user_name
     , SUBSTRING(application_name FROM 1 FOR 20) AS app_name
     , client_addr
     , pid
     , DATE_TRUNC('second', AGE(NOW(), DATE_TRUNC('second', backend_start))) AS login_time
     , state
     , REGEXP_REPLACE(query, '[ \t\n]+', ' ', 'g') AS query
  FROM pg_stat_activity
 WHERE usename = CURRENT_USER;

CREATE OR REPLACE VIEW public.my_sess AS
SELECT usename AS user_name
     , SUBSTRING(application_name FROM 1 FOR 20) AS app_name
     , client_addr
     , pid
     , DATE_TRUNC('second', AGE(NOW(), DATE_TRUNC('second', backend_start))) AS login_time
     , state
     , REGEXP_REPLACE(query, '[ \t\n]+', ' ', 'g') AS query
  FROM pg_stat_activity
 WHERE
     ( usename NOT IN ('rdsadmin')
    OR query != '<insufficient privilege>'
     )
   AND client_addr IN
     ( SELECT client_addr
         FROM pg_stat_activity
        WHERE query = CURRENT_QUERY()
          AND usename = CURRENT_USER
     );

CREATE OR REPLACE VIEW public.dba_locks AS
SELECT a.datname AS database
     , c.relname AS blocked_object
     , l.transactionid AS xact_id
     , l.mode
     , l.granted
     , a.usename AS user_name
     , l.pid
     , DATE_TRUNC('second', a.query_start) AS query_datetime
     , DATE_TRUNC('second', AGE(NOW(), a.query_start)) AS age
     , REGEXP_REPLACE(a.query, '[ \t\n]+', ' ', 'g') AS blocking_statement
  FROM pg_locks l
  JOIN pg_stat_activity a ON a.pid = l.pid
  JOIN pg_class c ON c.oid = l.relation;

CREATE OR REPLACE VIEW public.all_locks AS
SELECT a.datname AS database
     , c.relname AS blocked_object
     , l.transactionid AS xact_id
     , l.mode
     , l.granted
     , a.usename AS user_name
     , l.pid
     , DATE_TRUNC('second', a.query_start) AS query_datetime
     , DATE_TRUNC('second', AGE(NOW(), a.query_start)) AS age
     , REGEXP_REPLACE(a.query, '[ \t\n]+', ' ', 'g') AS blocking_statement
  FROM pg_locks l
  JOIN pg_stat_activity a ON a.pid = l.pid
  JOIN pg_class c ON c.oid = l.relation
 WHERE a.query NOT IN ('<insufficient privilege>')
   AND
     ( usename != CURRENT_USER
    OR AGE(NOW(), a.query_start) > interval '0 second'
     );

CREATE OR REPLACE VIEW public.dba_transactions AS
SELECT *
  FROM pg_prepared_xacts;

CREATE OR REPLACE VIEW public.v_sql_rewrite AS
SELECT c.relname AS obj_name
     , rw.rulename
     , rw.ev_type
     , rw.ev_enabled
     , rw.is_instead
     , rw.ev_qual
     , rw.ev_action
  FROM pg_rewrite rw
  JOIN pg_class c ON c.oid = rw.ev_class;

CREATE OR REPLACE VIEW public.dba_vacuum AS
SELECT schemaname AS schema_name
     , relname AS tab_name
     , last_vacuum
     , last_autovacuum
     , last_analyze
     , last_autoanalyze
  FROM pg_stat_all_tables;

CREATE OR REPLACE VIEW public.all_vacuum AS
SELECT schemaname AS schema_name
     , relname AS tab_name
     , last_vacuum
     , last_autovacuum
     , last_analyze
     , last_autoanalyze
  FROM pg_stat_all_tables
 WHERE schemaname NOT IN ('public', 'pg_toast', 'pg_catalog', 'information_schema');

CREATE OR REPLACE VIEW public.user_vacuum AS
SELECT schemaname AS schema_name
     , relname AS tab_name
     , last_vacuum
     , last_autovacuum
     , last_analyze
     , last_autoanalyze
  FROM pg_stat_all_tables
 WHERE schemaname = CURRENT_SCHEMA;

CREATE OR REPLACE VIEW public.dba_foreign_keys AS
SELECT c.conname AS constraint_name
     , ( SELECT n.nspname
           FROM pg_namespace AS n
          WHERE n.oid = c.connamespace
       ) AS constraint_schema
     , tf.name AS from_table
     , ( SELECT STRING_AGG(QUOTE_IDENT(a.attname), ', ' ORDER BY t.seq)
           FROM ( SELECT ROW_NUMBER() OVER (ROWS UNBOUNDED PRECEDING) AS seq
                       , attnum
                    FROM UNNEST(c.conkey) AS t(attnum)
                ) AS t
          INNER JOIN pg_attribute AS a ON a.attrelid = c.conrelid AND a.attnum = t.attnum
       ) AS from_cols
     , tt.name AS to_table
     , ( SELECT STRING_AGG(QUOTE_IDENT(a.attname), ', ' ORDER BY t.seq)
           FROM ( SELECT ROW_NUMBER() OVER (ROWS UNBOUNDED PRECEDING) AS seq
                       , attnum
                    FROM UNNEST(c.confkey) AS t(attnum)
                ) AS t
          INNER JOIN pg_attribute AS a ON a.attrelid = c.confrelid AND a.attnum = t.attnum
       ) AS to_cols
     , CASE confupdtype
          WHEN 'r' THEN 'restrict'
          WHEN 'c' THEN 'cascade'
          WHEN 'n' THEN 'set null'
          WHEN 'd' THEN 'set default'
          WHEN 'a' THEN 'no action'
          ELSE NULL
       END AS on_update
     , CASE confdeltype
          WHEN 'r' THEN 'restrict'
          WHEN 'c' THEN 'cascade'
          WHEN 'n' THEN 'set null'
          WHEN 'd' THEN 'set default'
          WHEN 'a' THEN 'no action'
          ELSE NULL
       END AS on_delete
     , CASE confmatchtype::text
          WHEN 'f' THEN 'full'
          WHEN 'p' THEN 'partial'
          WHEN 'u' THEN 'simple'
          WHEN 's' THEN 'simple'
          ELSE NULL
       END AS match_type -- In earlier postgres docs, simple was 'u'nspecified, but current versions use 's'imple.  text cast is required.
     , pg_catalog.pg_get_constraintdef(c.oid, TRUE) AS condef
  FROM pg_catalog.pg_constraint AS c
 INNER JOIN ( SELECT pg_class.oid, QUOTE_IDENT(pg_namespace.nspname) || '.' || QUOTE_IDENT(pg_class.relname) AS name
                FROM pg_class
               INNER JOIN pg_namespace ON pg_class.relnamespace = pg_namespace.oid
            ) AS tf ON tf.oid = c.conrelid
 INNER JOIN ( SELECT pg_class.oid, QUOTE_IDENT(pg_namespace.nspname) || '.' || QUOTE_IDENT(pg_class.relname) AS name
                FROM pg_class
               INNER JOIN pg_namespace ON pg_class.relnamespace = pg_namespace.oid
            ) AS tt ON tt.oid = c.confrelid
 WHERE c.contype = 'f';

CREATE OR REPLACE VIEW public.dba_functions AS
SELECT n.nspname AS schema
     , r.rolname AS owner
     , p.proname AS name
     , pg_catalog.pg_get_function_arguments(p.oid) AS args
     , pg_catalog.pg_get_function_result(p.oid) AS returns
     , CASE
          WHEN p.proisagg THEN 'agg'
          WHEN p.proiswindow THEN 'window'
          WHEN p.prorettype = 'pg_catalog.trigger'::PG_CATALOG.REGTYPE THEN 'trigger'
          ELSE 'normal'
       END AS type
 FROM pg_catalog.pg_proc p
 LEFT JOIN pg_catalog.pg_namespace n ON n.oid = p.pronamespace
 LEFT JOIN pg_roles r ON n.nspowner = r.oid
WHERE pg_catalog.pg_function_is_visible(p.oid);

CREATE OR REPLACE VIEW public.all_functions AS
SELECT n.nspname AS schema
     , r.rolname AS owner
     , p.proname AS name
     , pg_catalog.pg_get_function_arguments(p.oid) AS args
     , pg_catalog.pg_get_function_result(p.oid) AS returns
     , CASE
          WHEN p.proisagg THEN 'agg'
          WHEN p.proiswindow THEN 'window'
          WHEN p.prorettype = 'pg_catalog.trigger'::PG_CATALOG.REGTYPE THEN 'trigger'
          ELSE 'normal'
       END AS type
 FROM pg_catalog.pg_proc p
 LEFT JOIN pg_catalog.pg_namespace n ON n.oid = p.pronamespace
 LEFT JOIN pg_roles r ON n.nspowner = r.oid
WHERE pg_catalog.pg_function_is_visible(p.oid)
  AND n.nspname NOT IN ('pg_catalog', 'information_schema');

CREATE OR REPLACE VIEW public.user_functions AS
SELECT n.nspname AS schema
     , r.rolname AS owner
     , p.proname AS name
     , pg_catalog.pg_get_function_arguments(p.oid) AS args
     , pg_catalog.pg_get_function_result(p.oid) AS returns
     , CASE
          WHEN p.proisagg THEN 'agg'
          WHEN p.proiswindow THEN 'window'
          WHEN p.prorettype = 'pg_catalog.trigger'::PG_CATALOG.REGTYPE THEN 'trigger'
          ELSE 'normal'
       END AS type
 FROM pg_catalog.pg_proc p
 LEFT JOIN pg_catalog.pg_namespace n ON n.oid = p.pronamespace
 LEFT JOIN pg_roles r ON n.nspowner = r.oid
WHERE pg_catalog.pg_function_is_visible(p.oid)
  AND n.nspname = CURRENT_USER;

GRANT ALL ON ALL TABLES IN SCHEMA public TO public;




---------- Useful DevOps Queries as Views ----------

CREATE OR REPLACE VIEW devops_queries_by_cpu
    AS
SELECT ROUND(( 100 * total_time / SUM(total_time) over ())::NUMERIC, 2) AS percent
     , ROUND(total_time::NUMERIC, 2) AS total
     , calls
     , ROUND(mean_time::NUMERIC, 2) AS mean
     , stddev_time
     , REGEXP_REPLACE(query, '[\t\n]+', '', 'g') AS query
FROM pg_stat_statements
ORDER BY total_time DESC
LIMIT 10;

CREATE OR REPLACE VIEW devops_list_sessions
    AS
  WITH current_sessions AS
     ( SELECT usename AS user_name
            , application_name AS app_name
            , client_addr
            , pid
            , DATE_TRUNC('second', backend_start) AS login_datetime
            , DATE_TRUNC('second', xact_start) AS xact_datetime
            , DATE_TRUNC('second', query_start) AS query_datetime
            , DATE_TRUNC('second', CURRENT_TIMESTAMP) - DATE_TRUNC('second', backend_start) AS login_elapsed
            , DATE_TRUNC('second', CURRENT_TIMESTAMP) - DATE_TRUNC('second', xact_start) AS xact_elapsed
            , DATE_TRUNC('second', CURRENT_TIMESTAMP) - DATE_TRUNC('second', query_start) AS query_elapsed
--            , CASE waiting WHEN 't' THEN 'WAIT' ELSE 'BUSY' END AS wait -- v9.5-
            , state -- v9.6+
            , REGEXP_REPLACE(query, '[ \t\n]+', ' ', 'g') AS query
         FROM pg_stat_activity
        WHERE usename NOT IN ('rdsadmin')
     )
SELECT *
--     , pg_cancel_backend(pid)
--     , pg_terminate_backend(pid)
  FROM current_sessions
 WHERE query_elapsed > INTERVAL '5 minutes'
   AND app_name NOT LIKE 'pgAdmin%'
 ORDER BY query_elapsed DESC;

!
CREATE OR REPLACE VIEW devops_disk_size_by_table
    AS
SELECT table_name
     , PG_SIZE_PRETTY(table_size) AS table_size
     , PG_SIZE_PRETTY(indexes_size) AS indexes_size
     , PG_SIZE_PRETTY(total_size) AS total_size
  FROM
     ( SELECT table_name
            , PG_TABLE_SIZE(table_name) AS table_size
            , PG_INDEXES_SIZE(table_name) AS indexes_size
            , PG_TOTAL_RELATION_SIZE(table_name) AS total_size
         FROM
            ( SELECT (table_schema || '.' || table_name) AS table_name
                FROM information_schema.tables
            ) AS all_tables
        ORDER BY total_size DESC
     ) AS pretty_sizes;

CREATE OR REPLACE VIEW devops_running_queries
    AS -- Requires pg_stat_statements added to postgresql.conf::shared_preload_libraries and
       -- CREATE EXTENSION IF NOT EXISTS pg_stat_statements;
SELECT rolname AS role
     , calls
     , (total_time::INTEGER / 1000) * INTERVAL '1 second' AS total_time
     , ROUND((total_time / calls)::NUMERIC, 3) AS per_call
     , rows
     , 100.0 * shared_blks_hit / NULLIF(shared_blks_hit + shared_blks_read, 0) AS hit_percent
     , REGEXP_REPLACE(query, '[ \t\n]+', ' ', 'g') AS query
  FROM pg_stat_statements
  JOIN pg_roles r ON r.oid = userid
 WHERE calls > 100
   AND rolname NOT LIKE '%backup'
 ORDER BY total_time / calls DESC;

CREATE OR REPLACE VIEW devops_bloated_tables
    AS -- https://www.citusdata.com/blog/2017/10/20/monitoring-your-bloat-in-postgres/
  WITH constants AS -- define some constants for sizes of things for reference down the query and easy maintenance
     ( SELECT current_setting('block_size')::numeric AS bs, 23 AS hdr, 8 AS ma
     )
     , no_stats AS -- screen out table who have attributes which dont have stats, such AS JSON
     ( SELECT table_schema
            , table_name
            , n_live_tup::numeric AS est_rows
            , PG_TABLE_SIZE(relid)::numeric AS table_size
         FROM information_schema.columns
         JOIN pg_stat_user_tables AS psut
           ON table_schema = psut.schemaname
          AND table_name = psut.relname
         LEFT OUTER JOIN pg_stats
           ON table_schema = pg_stats.schemaname
          AND table_name = pg_stats.tablename
          AND column_name = attname
        WHERE attname IS NULL
          AND table_schema NOT IN ('pg_catalog', 'information_schema')
        GROUP BY table_schema, table_name, relid, n_live_tup
     )
     , null_headers AS -- calculate null header sizes omitting tables which dont have complete stats and attributes which aren't visible
     ( SELECT hdr+1+(SUM(CASE WHEN null_frac <> 0 THEN 1 ELSE 0 END)/8) AS nullhdr
            , SUM((1-null_frac)*avg_width) AS datawidth
            , MAX(null_frac) AS maxfracsum
            , schemaname
            , tablename
            , hdr
            , ma
            , bs
         FROM pg_stats CROSS JOIN constants
         LEFT OUTER JOIN no_stats
           ON schemaname = no_stats.table_schema
          AND tablename = no_stats.table_name
        WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
          AND no_stats.table_name IS NULL
          AND EXISTS
            ( SELECT 1
                FROM information_schema.columns
               WHERE schemaname = columns.table_schema
                 AND tablename = columns.table_name
            )
        GROUP BY schemaname, tablename, hdr, ma, bs
     )
     , data_headers AS -- estimate header and row size
     ( SELECT ma
            , bs
            , hdr
            , schemaname
            , tablename
            , (datawidth+(hdr+ma-(CASE WHEN hdr%ma=0 THEN ma ELSE hdr%ma END)))::numeric AS datahdr
            , (maxfracsum*(nullhdr+ma-(CASE WHEN nullhdr%ma=0 THEN ma ELSE nullhdr%ma END))) AS nullhdr2
         FROM null_headers
     )
     , table_estimates AS-- make estimates of how large the table should be based on row and page size
     ( SELECT schemaname
            , tablename
            , bs
            , reltuples::numeric AS est_rows
            , relpages * bs AS table_bytes
            , CEIL((reltuples*(datahdr + nullhdr2 + 4 + ma - (CASE WHEN datahdr%ma=0 THEN ma ELSE datahdr%ma END))/(bs-20))) * bs AS expected_bytes
            , reltoastrelid
         FROM data_headers
         JOIN pg_class ON tablename = relname
         JOIN pg_namespace ON relnamespace = pg_namespace.oid
          AND schemaname = nspname
        WHERE pg_class.relkind = 'r'
     )
     , estimates_with_toast AS -- add in estimated TOAST table sizes estimate based on 4 toast tuples per page because we dont have anything better; also append the no_data tables
     ( SELECT schemaname
            , tablename
            , TRUE AS can_estimate
            , est_rows
            , table_bytes + (COALESCE(toast.relpages, 0) * bs) AS table_bytes
            , expected_bytes + (CEIL(COALESCE(toast.reltuples, 0) / 4 ) * bs) AS expected_bytes
         FROM table_estimates LEFT OUTER JOIN pg_class AS toast
           ON table_estimates.reltoastrelid = toast.oid
          AND toast.relkind = 't'
     )
     , table_estimates_plus AS -- add some extra metadata to the table data and calculations to be reused including whether we cant estimate it or whether we think it might be compressed
     ( SELECT current_database() AS databasename
            , schemaname
            , tablename
            , can_estimate
            , est_rows
            , CASE
                  WHEN table_bytes > 0 THEN table_bytes::NUMERIC
                 ELSE NULL::NUMERIC
              END AS table_bytes
            , CASE
                 WHEN expected_bytes > 0 THEN expected_bytes::NUMERIC
                 ELSE NULL::NUMERIC
              END AS expected_bytes
            , CASE
                 WHEN expected_bytes > 0 AND table_bytes > 0 AND expected_bytes <= table_bytes THEN (table_bytes - expected_bytes)::NUMERIC
                 ELSE 0::NUMERIC
              END AS bloat_bytes
         FROM estimates_with_toast
        UNION ALL
       SELECT current_database() AS databasename
            , table_schema
            , table_name
            , FALSE
            , est_rows
            , table_size
            , NULL::NUMERIC
            , NULL::NUMERIC
         FROM no_stats
     )
     , bloat_data AS -- do final math calculations and formatting
     ( SELECT current_database() AS databasename
            , schemaname
            , tablename
            , can_estimate
            , table_bytes
            , ROUND(table_bytes/(1024^2)::NUMERIC,3) AS table_mb
            , expected_bytes
            , ROUND(expected_bytes/(1024^2)::NUMERIC,3) AS expected_mb
            , ROUND(bloat_bytes*100/table_bytes) AS pct_bloat
            , ROUND(bloat_bytes/(1024::NUMERIC^2),2) AS mb_bloat
            , table_bytes
            , expected_bytes
            , est_rows
         FROM table_estimates_plus
     )
-- filter output for bloated tables
SELECT databasename, schemaname, tablename, can_estimate, est_rows, pct_bloat, mb_bloat, table_mb
  FROM bloat_data
       -- this where clause defines which tables actually appear in the bloat chart
       -- example below filters for tables which are either 50%
       -- bloated and more than 20mb in size, or more than 25%
       -- bloated and more than 1GB in size
 WHERE ( pct_bloat >= 50 AND mb_bloat >= 20 )
    OR ( pct_bloat >= 25 AND mb_bloat >= 1000 )
 ORDER BY pct_bloat DESC;

CREATE OR REPLACE VIEW devops_blocking_queries
    AS
  WITH locking_queries AS
     ( SELECT DISTINCT l.pid
            , DATE_TRUNC('second', psa.query_start) AS query_start
            , DATE_TRUNC('second', age(NOW(), psa.query_start)) AS age
            , client_addr as client
            , wait_event
            , state
            , REGEXP_REPLACE(psa.query, '[ \t\n]+', ' ', 'g') AS query
         FROM pg_locks l
         JOIN pg_stat_activity psa ON psa.pid = l.pid
        WHERE age(now(), psa.query_start) > INTERVAL '1 minutes'
     )
SELECT pid, age, query_start, client, wait_event, state, query
     , 'pg_cancel_backend(' || pid || ')' AS cancel_command
  FROM locking_queries
 ORDER BY age DESC;

CREATE OR REPLACE VIEW devops_database_settings
    AS
SELECT * FROM pg_settings;

CREATE OR REPLACE VIEW devops_kill_all_sessions
    AS
SELECT 'pg_terminate_backend(' || pid || ')' AS kill_command
  FROM pg_stat_activity
 WHERE pid <> pg_backend_pid() -- don't kill my own connection!
   AND datname = current_database();  -- don't kill the connections to other databases

CREATE OR REPLACE VIEW devops_last_vacuum_datetime
    AS
SELECT 'VACUUM ANALYZE VERBOSE ' || schemaname || '.' || relname || ';' AS cmd
     , schemaname
     , relname AS tablename
     , last_vacuum
     , last_autovacuum
     , last_analyze
     , last_autoanalyze
  FROM pg_stat_user_tables
 WHERE COALESCE(last_analyze, '1970-01-01') < CURRENT_TIMESTAMP - INTERVAL '1 day'
   AND schemaname LIKE '%'
   AND relname LIKE '%'
 ORDER BY last_analyze ASC, schemaname ASC, relname DESC;

CREATE OR REPLACE VIEW devops_missing_indexes -- full table scans > index scans
    AS
SELECT schemaname AS schema_name
     , relname AS table_name
     , CASE idx_scan
          WHEN 0 THEN 'infinity'::TEXT
          ELSE (seq_scan / idx_scan)::TEXT
       END AS FTS_index_ratio
     , (seq_scan > idx_scan) AS "missing_index?"
     , PG_SIZE_PRETTY(pg_relation_size((schemaname || '.' || relname)::regclass)) AS size
     , seq_scan
     , idx_scan
     , CASE
          WHEN last_analyze IS NULL AND last_autoanalyze IS NULL THEN 'never'::TEXT
          ELSE (now() - (GREATEST(last_analyze, last_autoanalyze)))::TEXT
       END AS time_since_last_analyze
     , CASE
          WHEN last_vacuum IS NULL AND last_autovacuum IS NULL THEN 'never'::TEXT
          ELSE (now() - (GREATEST(last_vacuum, last_autovacuum)))::TEXT
       END AS time_since_last_vacuum
     , last_analyze
     , last_vacuum
     , last_autoanalyze
     , last_autovacuum
  FROM pg_stat_all_tables
 WHERE schemaname NOT IN ('public', 'pg_catalog', 'pg_toast')
   AND schemaname LIKE '%'
   AND relname LIKE '%'
   AND pg_relation_size((schemaname || '.' || relname)::regclass) > 80000
   AND seq_scan > idx_scan
   AND
     ( ( last_analyze IS NULL AND last_autoanalyze IS NULL )
    OR ( NOW() - GREATEST(last_analyze, last_autoanalyze) > INTERVAL '1 week')
     )
 ORDER BY (CASE idx_scan WHEN 0 THEN 9223372036854775807 ELSE (seq_scan / idx_scan)::BIGINT END) DESC
     , seq_scan DESC
     , pg_relation_size((schemaname || '.' || relname)::regclass) DESC;

CREATE OR REPLACE VIEW devops_needs_autoanalyze
    AS
  WITH vacuum_analyze AS
     ( SELECT schemaname
            , pgsat.relname AS tablename
            , current_setting('autovacuum_analyze_threshold')::INT +
              (current_setting('autovacuum_analyze_scale_factor')::REAL * pgc.reltuples::REAL)::INT
              AS analyze_threshold
            , GREATEST(n_tup_ins, n_tup_upd, n_tup_del) AS n_tup_mod
            , n_mod_since_analyze
            , last_analyze
            , last_autoanalyze
            , analyze_count
            , autoanalyze_count
         FROM pg_catalog.pg_stat_all_tables pgsat
         JOIN pg_class pgc ON pgc.relname = pgsat.relname
        WHERE GREATEST(n_tup_ins, n_tup_upd, n_tup_del) > 0
          AND schemaname NOT IN ('pg_catalog', 'pg_toast')
     )
SELECT * from vacuum_analyze
 WHERE n_mod_since_analyze > analyze_threshold
 ORDER BY (n_mod_since_analyze - analyze_threshold) DESC;

CREATE OR REPLACE VIEW devops_needs_autovacuum
    AS
  WITH vacuum_analyze AS
     ( SELECT schemaname
            , pgsat.relname AS tablename
            , current_setting('autovacuum_vacuum_threshold')::INT + 
              (current_setting('autovacuum_vacuum_scale_factor')::REAL * pgc.reltuples::REAL)::INT
              AS vacuum_threshold
            , n_dead_tup
            , last_vacuum
            , last_autovacuum
            , vacuum_count
            , autovacuum_count
         FROM pg_catalog.pg_stat_all_tables pgsat
         JOIN pg_class pgc ON pgc.relname = pgsat.relname
        WHERE n_dead_tup > 0
          AND schemaname NOT IN ('pg_catalog', 'pg_toast')
     )
SELECT * from vacuum_analyze
 WHERE n_dead_tup > vacuum_threshold
 ORDER BY (n_dead_tup - vacuum_threshold) DESC;

CREATE OR REPLACE VIEW devops_table_size
    AS
SELECT c.relname
     , PG_SIZE_PRETTY(PG_TABLE_SIZE(c.oid)) AS table_size
  FROM pg_class c
 ORDER BY PG_TABLE_SIZE(c.oid) DESC
 LIMIT 50;

CREATE OR REPLACE VIEW devops_should_vacuum -- Tables the engine thinks should be vacuumed
    AS
  WITH vbt AS 
     ( SELECT setting AS autovacuum_vacuum_threshold
         FROM pg_settings
        WHERE name = 'autovacuum_vacuum_threshold'
     )
     , vsf AS
     ( SELECT setting AS autovacuum_vacuum_scale_factor
         FROM pg_settings
        WHERE name = 'autovacuum_vacuum_scale_factor'
     )
     , fma AS
     ( SELECT setting AS autovacuum_freeze_max_age
         FROM pg_settings
        WHERE name = 'autovacuum_freeze_max_age'
     )
     , sto AS
     ( SELECT opt_oid
            , SPLIT_PART(setting, '=', 1) AS param
            , SPLIT_PART(setting, '=', 2) AS value
         FROM 
            ( SELECT oid opt_oid
                   , UNNEST(reloptions) setting
                FROM pg_class
            ) AS opt
     )
SELECT '"' || ns.nspname || '"."' || c.relname || '"' AS relation
     , PG_SIZE_PRETTY(PG_TABLE_SIZE(c.oid)) AS table_size
     , AGE(relfrozenxid) AS xid_age
     , COALESCE(cfma.value::FLOAT, autovacuum_freeze_max_age::FLOAT) AS autovacuum_freeze_max_age
     , (COALESCE(cvbt.value::FLOAT, autovacuum_vacuum_threshold::FLOAT) + 
        COALESCE(cvsf.value::FLOAT, autovacuum_vacuum_scale_factor::FLOAT) * PG_TABLE_SIZE(c.oid)
       ) AS autovacuum_vacuum_tuples
     , n_dead_tup AS dead_tuples
  FROM pg_class c
  JOIN pg_namespace ns ON ns.oid = c.relnamespace
  JOIN pg_stat_all_tables stat ON stat.relid = c.oid
  JOIN vbt ON (1=1)
  JOIN vsf ON (1=1)
  JOIN fma on (1=1)
  LEFT JOIN sto cvbt ON cvbt.param = 'autovacuum_vacuum_threshold' AND c.oid = cvbt.opt_oid
  LEFT JOIN sto cvsf ON cvsf.param = 'autovacuum_vacuum_scale_factor' AND c.oid = cvsf.opt_oid
  LEFT JOIN sto cfma ON cfma.param = 'autovacuum_freeze_max_age' AND c.oid = cfma.opt_oid
 WHERE c.relkind = 'r'
   AND nspname <> 'pg_catalog'
   AND
     ( AGE(relfrozenxid) >= COALESCE(cfma.value::FLOAT, autovacuum_freeze_max_age::FLOAT)
    OR COALESCE(cvbt.value::FLOAT, autovacuum_vacuum_threshold::FLOAT) + COALESCE(cvsf.value::FLOAT, autovacuum_vacuum_scale_factor::FLOAT) * PG_TABLE_SIZE(c.oid) <= n_dead_tup
    OR 1 = 1
     )
 ORDER BY AGE(relfrozenxid) DESC;

CREATE OR REPLACE VIEW devops_unused_indexes
    AS
SELECT indexrelid::regclass AS index
     , relid::regclass AS table
     , idx_scan AS number_of_scans
     , 'DROP INDEX ' || indexrelid::regclass || ';' AS drop_statement
  FROM pg_stat_user_indexes
  JOIN pg_index USING (indexrelid)
 WHERE indisunique is false
   AND idx_scan = 0
 ORDER BY idx_scan ASC;

CREATE OR REPLACE VIEW devops_analyze_status
    AS
SELECT relname AS tablename
     , last_vacuum
     , last_autovacuum
     , last_analyze
     , last_autoanalyze
  FROM pg_stat_user_tables
 ORDER BY last_analyze ASC;

CREATE OR REPLACE VIEW devops_current_users
    AS
SELECT * FROM pg_stat_activity;

CREATE OR REPLACE VIEW devops_defined_users
    AS
SELECT * from pg_user;

CREATE OR REPLACE VIEW devops_child_tables
    AS
SELECT nmsp_parent.nspname AS parent_schema
     , parent.relname AS parent
     , nmsp_child.nspname AS child_schema
     , child.relname AS child
  FROM pg_inherits
  JOIN pg_class parent ON pg_inherits.inhparent = parent.oid
  JOIN pg_class child ON pg_inherits.inhrelid = child.oid
  JOIN pg_namespace nmsp_parent ON nmsp_parent.oid = parent.relnamespace
  JOIN pg_namespace nmsp_child ON nmsp_child.oid = child.relnamespace
 WHERE nmsp_parent.nspname = nmsp_child.nspname -- schemas match
   AND parent.relname LIKE '%'
 ORDER BY child;

-- http://www.alberton.info/postgresql_meta_info.html
CREATE OR REPLACE FUNCTION public.function_args(
  IN funcname character varying,
  IN schema character varying,
  OUT pos integer,
  OUT direction character,
  OUT argname character varying,
  OUT datatype character varying)
RETURNS SETOF RECORD AS $$DECLARE
  rettype character varying;
  argtypes oidvector;
  allargtypes oid[];
  argmodes "char"[];
  argnames text[];
  mini integer;
  maxi integer;
BEGIN
  /* get object ID of function */
  SELECT INTO rettype, argtypes, allargtypes, argmodes, argnames
         CASE
         WHEN pg_proc.proretset
         THEN 'setof ' || pg_catalog.format_type(pg_proc.prorettype, NULL)
         ELSE pg_catalog.format_type(pg_proc.prorettype, NULL) END,
         pg_proc.proargtypes,
         pg_proc.proallargtypes,
         pg_proc.proargmodes,
         pg_proc.proargnames
    FROM pg_catalog.pg_proc
         JOIN pg_catalog.pg_namespace
         ON (pg_proc.pronamespace = pg_namespace.oid)
   WHERE pg_proc.prorettype <> 'pg_catalog.cstring'::pg_catalog.regtype
     AND (pg_proc.proargtypes[0] IS NULL
      OR pg_proc.proargtypes[0] <> 'pg_catalog.cstring'::pg_catalog.regtype)
     AND NOT pg_proc.proisagg
     AND pg_proc.proname = funcname
     AND pg_namespace.nspname = schema
     AND pg_catalog.pg_function_is_visible(pg_proc.oid);

  /* bail out if not found */
  IF NOT FOUND THEN
    RETURN;
  END IF;

  /* return a row for the return value */
  pos = 0;
  direction = 'o'::char;
  argname = 'RETURN VALUE';
  datatype = rettype;
  RETURN NEXT;

  /* unfortunately allargtypes is NULL if there are no OUT parameters */
  IF allargtypes IS NULL THEN
    mini = array_lower(argtypes, 1); maxi = array_upper(argtypes, 1);
  ELSE
    mini = array_lower(allargtypes, 1); maxi = array_upper(allargtypes, 1);
  END IF;
  IF maxi < mini THEN RETURN; END IF;

  /* loop all the arguments */
  FOR i IN mini .. maxi LOOP
    pos = i - mini + 1;
    IF argnames IS NULL THEN
      argname = NULL;
    ELSE
      argname = argnames[pos];
    END IF;
    IF allargtypes IS NULL THEN
      direction = 'i'::char;
      datatype = pg_catalog.format_type(argtypes[i], NULL);
    ELSE
      direction = argmodes[i];
      datatype = pg_catalog.format_type(allargtypes[i], NULL);
    END IF;
    RETURN NEXT;
  END LOOP;

  RETURN;
END;$$ LANGUAGE plpgsql STABLE STRICT SECURITY INVOKER;
COMMENT ON FUNCTION public.function_args(character varying, character
varying)
IS $$For a function name and schema, this procedure selects for each
argument the following data:
- position in the argument list (0 for the return value)
- direction 'i', 'o', or 'b'
- name (NULL if not defined)
- data type$$;

CREATE OR REPLACE VIEW public.dba_databases
    AS
SELECT datname FROM pg_database;

CREATE OR REPLACE VIEW public.all_databases
    AS
SELECT datname AS database
  FROM dba_databases
 WHERE datname NOT IN ('template0', 'template1');

CREATE OR REPLACE VIEW public.devops_version
    AS
SELECT version();

CREATE OR REPLACE VIEW devops_replication_status
    AS
SELECT client_addr
     , state
     , sent_location
     , write_location
     , flush_location
     , replay_location
  FROM pg_stat_replication;

CREATE OR REPLACE VIEW devops_user_roles
    AS
  WITH RECURSIVE cte
    AS
     ( SELECT pg_roles.oid
            , pg_roles.rolname AS role_name
            , pg_roles.rolname as granted_to
         FROM pg_roles
        WHERE pg_roles.rolname = CURRENT_USER
        UNION ALL
       SELECT m.roleid
            , pgr.rolname AS role_name
            , pgr2.rolname AS granted_to
         FROM cte cte_1
         JOIN pg_auth_members m ON m.member = cte_1.oid
         JOIN pg_roles pgr ON pgr.oid = m.roleid
         join pg_roles pgr2 ON pgr2.oid = m.member
     )
SELECT DISTINCT granted_to, role_name
  FROM cte
 ORDER BY granted_to, role_name;
