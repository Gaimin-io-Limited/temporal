-- ALTER TABLE executions_visibility ADD COLUMN TemporalWorkerDeploymentVersion    VARCHAR(255) GENERATED ALWAYS AS (search_attributes->>"$.TemporalWorkerDeploymentVersion");
-- ALTER TABLE executions_visibility ADD COLUMN TemporalWorkflowVersioningBehavior VARCHAR(255) GENERATED ALWAYS AS (search_attributes->>"$.TemporalWorkflowVersioningBehavior");
-- ALTER TABLE executions_visibility ADD COLUMN TemporalWorkerDeployment           VARCHAR(255) GENERATED ALWAYS AS (search_attributes->>"$.TemporalWorkerDeployment");

CREATE INDEX by_temporal_worker_deployment_version    ON executions_visibility (namespace_id, TemporalWorkerDeploymentVersion, close_time DESC, start_time DESC, run_id);
CREATE INDEX by_temporal_workflow_versioning_behavior ON executions_visibility (namespace_id, TemporalWorkflowVersioningBehavior, close_time DESC, start_time DESC, run_id);
CREATE INDEX by_temporal_worker_deployment            ON executions_visibility (namespace_id, TemporalWorkerDeployment, close_time DESC, start_time DESC, run_id);
