package com.example.attendance.repository;

import com.example.attendance.model.AttendanceRecord;
import com.example.attendance.model.AttendanceStatus;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDate;
import java.util.List;

public interface AttendanceRecordRepository extends JpaRepository<AttendanceRecord, Long> {

    boolean existsByStudentIdAndCourseIdAndDate(Long studentId, Long courseId, LocalDate date);

    List<AttendanceRecord> findByStudentIdAndCourseId(Long studentId, Long courseId);

    List<AttendanceRecord> findByCourseIdAndDate(Long courseId, LocalDate date);

    long countByStudentIdAndCourseId(Long studentId, Long courseId);

    long countByStudentIdAndCourseIdAndStatus(Long studentId, Long courseId, AttendanceStatus status);
}
