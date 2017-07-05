--liquibase formatted sql

--changeset id:2 author:falko.gloeckler dbms:mysql

--preconditions onFail:HALT onError:HALT
SET FOREIGN_KEY_CHECKS=0;

CREATE TABLE IF NOT EXISTS projects2 (
        `id`                 BIGINT     UNSIGNED PRIMARY KEY AUTO_INCREMENT,
        `title`              VARCHAR(200)       COMMENT 'Title of the project',
        `description`        TEXT       COMMENT 'Abstract of the project',
        `startDate`          DATE       COMMENT 'Date of project start',
        `endDate`            DATE       COMMENT 'Date of project end',
        `remarks`            TEXT       COMMENT 'Remarks related to the project',
        `officialProjectID`  VARCHAR(200)       COMMENT 'The project''s identifier or reference that is assigned by official instances (e.g. the funding agency,  GEPRIS ID, other funding ID)'
) COMMENT 'main table';
-- rollback drop table projects2;

