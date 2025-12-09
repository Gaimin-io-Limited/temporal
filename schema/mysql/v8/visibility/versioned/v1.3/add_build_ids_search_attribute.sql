-- ALTER TABLE executions_visibility ADD COLUMN BuildIds JSON GENERATED ALWAYS AS (search_attributes->'$.BuildIds');
CREATE INDEX by_build_ids ON executions_visibility (namespace_id, (CAST(BuildIds AS CHAR(255) ARRAY)), close_time DESC, start_time DESC, run_id);
