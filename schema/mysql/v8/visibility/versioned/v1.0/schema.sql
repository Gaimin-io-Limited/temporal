CREATE TABLE executions_visibility (
  namespace_id            CHAR(64)      NOT NULL,
  run_id                  CHAR(64)      NOT NULL,
  start_time              DATETIME(6)   NOT NULL,
  execution_time          DATETIME(6)   NOT NULL,
  workflow_id             VARCHAR(255)  NOT NULL,
  workflow_type_name      VARCHAR(255)  NOT NULL,
  status                  INT           NOT NULL,  -- enum WorkflowExecutionStatus {RUNNING, COMPLETED, FAILED, CANCELED, TERMINATED, CONTINUED_AS_NEW, TIMED_OUT}
  close_time              DATETIME(6)   NULL,
  history_length          BIGINT        NULL,
  memo                    BLOB          NULL,
  encoding                VARCHAR(64)   NOT NULL,
  task_queue              VARCHAR(255)  NOT NULL DEFAULT '',
  search_attributes       JSON          NULL,

  -- Each search attribute has its own generated column.
  -- For string types (keyword and text), we need to unquote the json string,
  -- ie., use `->>` instead of `->` operator.
  -- For text types, the generated column need to be STORED instead of VIRTUAL,
  -- so we can create a full-text search index.
  -- For datetime type, MySQL can't cast datetime string with timezone to
  -- datetime type directly, so we need to call CONVERT_TZ to convert to UTC.
  -- Check the `custom_search_attributes` table for complete set of examples.

  -- Predefined search attributes
  TemporalChangeVersion         JSON          GENERATED ALWAYS AS (search_attributes->"$.TemporalChangeVersion") STORED,
  BinaryChecksums               JSON          GENERATED ALWAYS AS (search_attributes->"$.BinaryChecksums") STORED,
  BatcherUser                   VARCHAR(255)  GENERATED ALWAYS AS (search_attributes->>"$.BatcherUser") STORED,
  TemporalScheduledStartTime    DATETIME(6)   GENERATED ALWAYS AS (
    CONVERT_TZ(
      REGEXP_REPLACE(search_attributes->>"$.TemporalScheduledStartTime", 'Z|[+-][0-9]{2}:[0-9]{2}$', ''),
      SUBSTR(REPLACE(search_attributes->>"$.TemporalScheduledStartTime", 'Z', '+00:00'), -6, 6),
      '+00:00'
    )
  ) STORED,
  TemporalScheduledById         VARCHAR(255)  GENERATED ALWAYS AS (search_attributes->>"$.TemporalScheduledById") STORED,
  TemporalSchedulePaused        BOOLEAN       GENERATED ALWAYS AS (search_attributes->"$.TemporalSchedulePaused") STORED,
  TemporalNamespaceDivision     VARCHAR(255)  GENERATED ALWAYS AS (search_attributes->>"$.TemporalNamespaceDivision") STORED,
  BuildIds                      JSON          GENERATED ALWAYS AS (search_attributes->"$.BuildIds") STORED,
  TemporalPauseInfo            JSON          GENERATED ALWAYS AS (search_attributes->"$.TemporalPauseInfo") STORED,
  TemporalWorkerDeploymentVersion    VARCHAR(255)    GENERATED ALWAYS AS (search_attributes->>"$.TemporalWorkerDeploymentVersion") STORED,
  TemporalWorkflowVersioningBehavior VARCHAR(255)    GENERATED ALWAYS AS (search_attributes->>"$.TemporalWorkflowVersioningBehavior") STORED,
  TemporalWorkerDeployment           VARCHAR(255)    GENERATED ALWAYS AS (search_attributes->>"$.TemporalWorkerDeployment") STORED,

  PRIMARY KEY (namespace_id, run_id)
);

CREATE INDEX by_type_start_time ON executions_visibility (namespace_id, workflow_type_name, status, start_time DESC, run_id);
CREATE INDEX by_workflow_id_start_time ON executions_visibility (namespace_id, workflow_id, status, start_time DESC, run_id);
CREATE INDEX by_status_by_start_time ON executions_visibility (namespace_id, status, start_time DESC, run_id);
CREATE INDEX by_type_close_time ON executions_visibility (namespace_id, workflow_type_name, status, close_time DESC, run_id);
CREATE INDEX by_workflow_id_close_time ON executions_visibility (namespace_id, workflow_id, status, close_time DESC, run_id);
CREATE INDEX by_status_by_close_time ON executions_visibility (namespace_id, status, close_time DESC, run_id);
