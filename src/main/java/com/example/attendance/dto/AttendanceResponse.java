package com.example.attendance.dto;

import com.example.attendance.model.AttendanceRecord;
import com.example.attendance.model.AttendanceStatus;

import java.time.LocalDate;

public record AttendanceResponse(
        Long id,
        Long studentId,
        String studentName,
        Long courseId,
        String courseCode,
        LocalDate date,
        AttendanceStatus status
) {

    public static AttendanceResponse from(AttendanceRecord record) {
        return new AttendanceResponse(
                record.getId(),
                record.getStudent().getId(),
                record.getStudent().getName(),
                record.getCourse().getId(),
                record.getCourse().getCode(),
                record.getDate(),
                record.getStatus()
        );
    }
}
