-- ALTER TABLE executions_visibility ADD COLUMN TemporalPauseInfo JSON GENERATED ALWAYS AS (search_attributes->'$.TemporalPauseInfo');
CREATE INDEX by_temporal_pause_info ON executions_visibility (namespace_id, (CAST(TemporalPauseInfo AS CHAR(255) ARRAY)), close_time DESC, start_time DESC, run_id);
