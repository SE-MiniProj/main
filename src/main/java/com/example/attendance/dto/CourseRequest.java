package com.example.attendance.dto;

import jakarta.validation.constraints.NotBlank;

public record CourseRequest(
        @NotBlank String code,
        @NotBlank String name
) {
}
