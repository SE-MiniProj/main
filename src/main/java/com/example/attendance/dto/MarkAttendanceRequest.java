package com.example.attendance.dto;

import com.example.attendance.model.AttendanceStatus;
import jakarta.validation.constraints.NotNull;

import java.time.LocalDate;

public record MarkAttendanceRequest(
        @NotNull Long studentId,
        @NotNull Long courseId,
        @NotNull LocalDate date,
        @NotNull AttendanceStatus status
) {
}
