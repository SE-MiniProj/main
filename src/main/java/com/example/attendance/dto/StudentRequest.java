package com.example.attendance.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;

public record StudentRequest(
        @NotBlank String rollNumber,
        @NotBlank String name,
        @NotBlank @Email String email
) {
}
