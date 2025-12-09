ALTER TABLE executions_visibility ADD COLUMN root_workflow_id VARCHAR(255) NULL;
ALTER TABLE executions_visibility ADD COLUMN root_run_id      VARCHAR(255) NULL;
CREATE INDEX by_root_workflow_id  ON executions_visibility (namespace_id, root_workflow_id, close_time DESC, start_time DESC, run_id);
CREATE INDEX by_root_run_id       ON executions_visibility (namespace_id, root_run_id, close_time DESC, start_time DESC, run_id);
