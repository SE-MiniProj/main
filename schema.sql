-- =============================================================
-- Attendance Management System - database schema (MySQL 8)
-- =============================================================

CREATE DATABASE IF NOT EXISTS attendance_db
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE attendance_db;

-- -------------------------------------------------------------
-- users: admins, teachers and students share one table;
-- the role column decides what a user can do.
-- -------------------------------------------------------------
CREATE TABLE users (
    id            BIGINT       NOT NULL AUTO_INCREMENT,
    email         VARCHAR(255) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name     VARCHAR(150) NOT NULL,
    role          ENUM('ADMIN', 'TEACHER', 'STUDENT') NOT NULL,
    roll_number   VARCHAR(30)  NULL,
    is_active     BOOLEAN      NOT NULL DEFAULT TRUE,
    created_at    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
                               ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (id),
    CONSTRAINT uq_users_email       UNIQUE (email),
    CONSTRAINT uq_users_roll_number UNIQUE (roll_number),
    -- every student must have a roll number
    CONSTRAINT chk_users_student_roll
        CHECK (role <> 'STUDENT' OR roll_number IS NOT NULL)
) ENGINE = InnoDB;

-- -------------------------------------------------------------
-- courses: the catalogue entry (e.g. CS301 Operating Systems)
-- -------------------------------------------------------------
CREATE TABLE courses (
    id          BIGINT       NOT NULL AUTO_INCREMENT,
    code        VARCHAR(20)  NOT NULL,
    name        VARCHAR(150) NOT NULL,
    description TEXT         NULL,
    credits     TINYINT      NOT NULL DEFAULT 4,
    created_at  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (id),
    CONSTRAINT uq_courses_code UNIQUE (code),
    CONSTRAINT chk_courses_credits CHECK (credits > 0)
) ENGINE = InnoDB;

-- -------------------------------------------------------------
-- sections: one offering of a course in a term, taught by a teacher
-- -------------------------------------------------------------
CREATE TABLE sections (
    id           BIGINT      NOT NULL AUTO_INCREMENT,
    course_id    BIGINT      NOT NULL,
    teacher_id   BIGINT      NOT NULL,
    section_name VARCHAR(20) NOT NULL,            -- e.g. 'A', 'B'
    term         VARCHAR(20) NOT NULL,            -- e.g. '2026-ODD'
    room         VARCHAR(50) NULL,
    capacity     SMALLINT    NULL,
    created_at   TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (id),
    CONSTRAINT uq_sections_offering UNIQUE (course_id, section_name, term),
    CONSTRAINT chk_sections_capacity CHECK (capacity IS NULL OR capacity > 0),
    CONSTRAINT fk_sections_course
        FOREIGN KEY (course_id)  REFERENCES courses (id) ON DELETE RESTRICT,
    CONSTRAINT fk_sections_teacher
        FOREIGN KEY (teacher_id) REFERENCES users (id)   ON DELETE RESTRICT
) ENGINE = InnoDB;

CREATE INDEX idx_sections_teacher ON sections (teacher_id);

-- -------------------------------------------------------------
-- enrollments: which student is in which section
-- -------------------------------------------------------------
CREATE TABLE enrollments (
    id          BIGINT    NOT NULL AUTO_INCREMENT,
    student_id  BIGINT    NOT NULL,
    section_id  BIGINT    NOT NULL,
    status      ENUM('ACTIVE', 'DROPPED', 'COMPLETED') NOT NULL DEFAULT 'ACTIVE',
    enrolled_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (id),
    CONSTRAINT uq_enrollment_student_section UNIQUE (student_id, section_id),
    CONSTRAINT fk_enrollments_student
        FOREIGN KEY (student_id) REFERENCES users (id)    ON DELETE RESTRICT,
    CONSTRAINT fk_enrollments_section
        FOREIGN KEY (section_id) REFERENCES sections (id) ON DELETE RESTRICT
) ENGINE = InnoDB;

CREATE INDEX idx_enrollments_section ON enrollments (section_id);

-- -------------------------------------------------------------
-- attendance_sessions: one class meeting of a section
-- -------------------------------------------------------------
CREATE TABLE attendance_sessions (
    id           BIGINT       NOT NULL AUTO_INCREMENT,
    section_id   BIGINT       NOT NULL,
    session_date DATE         NOT NULL,
    start_time   TIME         NOT NULL,
    end_time     TIME         NOT NULL,
    topic        VARCHAR(255) NULL,
    created_by   BIGINT       NOT NULL,
    created_at   TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (id),
    CONSTRAINT uq_session_slot UNIQUE (section_id, session_date, start_time),
    CONSTRAINT chk_session_times CHECK (end_time > start_time),
    CONSTRAINT fk_sessions_section
        FOREIGN KEY (section_id) REFERENCES sections (id) ON DELETE RESTRICT,
    CONSTRAINT fk_sessions_created_by
        FOREIGN KEY (created_by) REFERENCES users (id)    ON DELETE RESTRICT
) ENGINE = InnoDB;

CREATE INDEX idx_sessions_date ON attendance_sessions (session_date);

-- -------------------------------------------------------------
-- attendance_records: one row per student per session
-- -------------------------------------------------------------
CREATE TABLE attendance_records (
    id         BIGINT    NOT NULL AUTO_INCREMENT,
    session_id BIGINT    NOT NULL,
    student_id BIGINT    NOT NULL,
    status     ENUM('PRESENT', 'ABSENT', 'LATE', 'EXCUSED') NOT NULL,
    remarks    VARCHAR(255) NULL,
    marked_by  BIGINT    NOT NULL,
    marked_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (id),
    -- a student can have at most one record per session
    CONSTRAINT uq_attendance_student_session UNIQUE (student_id, session_id),
    CONSTRAINT fk_records_session
        FOREIGN KEY (session_id) REFERENCES attendance_sessions (id) ON DELETE CASCADE,
    CONSTRAINT fk_records_student
        FOREIGN KEY (student_id) REFERENCES users (id)               ON DELETE RESTRICT,
    CONSTRAINT fk_records_marked_by
        FOREIGN KEY (marked_by)  REFERENCES users (id)               ON DELETE RESTRICT
) ENGINE = InnoDB;

-- The unique key above is led by student_id; this index serves
-- "show everyone's attendance for this session" lookups.
CREATE INDEX idx_records_session ON attendance_records (session_id);
