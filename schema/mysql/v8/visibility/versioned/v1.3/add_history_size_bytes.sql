ALTER TABLE executions_visibility ADD COLUMN history_size_bytes BIGINT NULL;
CREATE INDEX by_history_size_bytes ON executions_visibility (namespace_id, history_size_bytes, close_time DESC, start_time DESC, run_id);
