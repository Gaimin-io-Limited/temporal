ALTER TABLE executions_visibility ADD COLUMN execution_duration BIGINT NULL;
CREATE INDEX by_execution_duration ON executions_visibility (namespace_id, execution_duration, close_time DESC, start_time DESC, run_id);
