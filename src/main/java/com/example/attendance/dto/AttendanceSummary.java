package com.example.attendance.dto;

public record AttendanceSummary(
        Long studentId,
        Long courseId,
        long totalClasses,
        long attended,
        double percentage
) {
}
