-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- to be reworked, support scripts as well as database objects like functions, procedures and packages.
CREATE TABLE sobs_object
  ( script_id          NUMBER(38, 0)  GENERATED ALWAYS AS IDENTITY (NOCACHE NOCYCLE NOMAXVALUE)
  , script_name        VARCHAR2(2000)                                           NOT NULL
  , script_schema      VARCHAR2(256)  DEFAULT 'SOBS'                            NOT NULL
  , created            DATE           DEFAULT SYSDATE                           NOT NULL
  , updated            DATE           DEFAULT SYSDATE                           NOT NULL
  , created_by         VARCHAR2(256)  DEFAULT USER                              NOT NULL
  , created_by_os      VARCHAR2(256)  DEFAULT SYS_CONTEXT('USERENV', 'OS_USER') NOT NULL
  , updated_by         VARCHAR2(256)  DEFAULT USER                              NOT NULL
  , updated_by_os      VARCHAR2(256)  DEFAULT SYS_CONTEXT('USERENV', 'OS_USER') NOT NULL
  , script_description VARCHAR2(4000)
  )
;
-- description
COMMENT ON TABLE sobs_object IS 'Holds the script file names that should be executed by SOBS. Will use the alias scrt.';
COMMENT ON COLUMN sobs_object.script_id IS 'The generated unique id of the script file.';
COMMENT ON COLUMN sobs_object.script_name IS 'The name of the script file including full or relative path. Use relative path (relative to batch_base_path or repository location) to ensure running scripts from different machines.';
COMMENT ON COLUMN sobs_object.script_schema IS 'The schema the script should run in. Will cause an ALTER SESSION SET CURRENT_SCHEMA before executing the script.';
COMMENT ON COLUMN sobs_object.script_description IS 'Optional description of the script file.';
COMMENT ON COLUMN sobs_object.created IS 'Date created, managed by default and trigger.';
COMMENT ON COLUMN sobs_object.updated IS 'Date updated, managed by default and trigger.';
COMMENT ON COLUMN sobs_object.created_by IS 'DB user who created the record, managed by default and trigger.';
COMMENT ON COLUMN sobs_object.created_by_os IS 'OS user who created the record, managed by default and trigger.';
COMMENT ON COLUMN sobs_object.updated_by IS 'DB user who updated the record, managed by default and trigger.';
COMMENT ON COLUMN sobs_object.updated_by_os IS 'OS user who updated the record, managed by default and trigger.';
-- primary key
ALTER TABLE sobs_object
  ADD CONSTRAINT sobs_object_pk
  PRIMARY KEY (script_id)
  ENABLE
;
-- trigger
CREATE OR REPLACE TRIGGER sobs_object_ins_trg
  BEFORE INSERT ON sobs_object
  FOR EACH ROW
BEGIN
  :NEW.created        := SYSDATE;
  :NEW.updated        := SYSDATE;
  :NEW.created_by     := SYS_CONTEXT('USERENV', 'CURRENT_USER');
  :NEW.created_by_os  := SYS_CONTEXT('USERENV', 'OS_USER');
  :NEW.updated_by     := SYS_CONTEXT('USERENV', 'CURRENT_USER');
  :NEW.updated_by_os  := SYS_CONTEXT('USERENV', 'OS_USER');
END;
/
CREATE OR REPLACE TRIGGER sobs_object_upd_trg
  BEFORE UPDATE ON sobs_object
  FOR EACH ROW
BEGIN
  -- make sure created is not changed
  :NEW.created        := :OLD.created;
  :NEW.created_by     := :OLD.created_by;
  :NEW.created_by_os  := :OLD.created_by_os;
  :NEW.updated        := SYSDATE;
  :NEW.updated_by     := SYS_CONTEXT('USERENV', 'CURRENT_USER');
  :NEW.updated_by_os  := SYS_CONTEXT('USERENV', 'OS_USER');
END;
/