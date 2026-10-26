package com.example.attendance.service;

import com.example.attendance.dto.AttendanceResponse;
import com.example.attendance.dto.AttendanceSummary;
import com.example.attendance.dto.MarkAttendanceRequest;
import com.example.attendance.exception.DuplicateResourceException;
import com.example.attendance.model.AttendanceRecord;
import com.example.attendance.model.AttendanceStatus;
import com.example.attendance.model.Course;
import com.example.attendance.model.Student;
import com.example.attendance.repository.AttendanceRecordRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;

@Service
public class AttendanceService {

    private final AttendanceRecordRepository attendanceRepository;
    private final StudentService studentService;
    private final CourseService courseService;

    public AttendanceService(AttendanceRecordRepository attendanceRepository,
                             StudentService studentService,
                             CourseService courseService) {
        this.attendanceRepository = attendanceRepository;
        this.studentService = studentService;
        this.courseService = courseService;
    }

    @Transactional
    public AttendanceResponse mark(MarkAttendanceRequest request) {
        Student student = studentService.findById(request.studentId());
        Course course = courseService.findById(request.courseId());

        if (attendanceRepository.existsByStudentIdAndCourseIdAndDate(
                student.getId(), course.getId(), request.date())) {
            throw new DuplicateResourceException("Attendance already marked for this student, course and date");
        }

        AttendanceRecord record = new AttendanceRecord(student, course, request.date(), request.status());
        return AttendanceResponse.from(attendanceRepository.save(record));
    }

    @Transactional(readOnly = true)
    public List<AttendanceResponse> findByStudentAndCourse(Long studentId, Long courseId) {
        return attendanceRepository.findByStudentIdAndCourseId(studentId, courseId).stream()
                .map(AttendanceResponse::from)
                .toList();
    }

    @Transactional(readOnly = true)
    public List<AttendanceResponse> findByCourseAndDate(Long courseId, LocalDate date) {
        return attendanceRepository.findByCourseIdAndDate(courseId, date).stream()
                .map(AttendanceResponse::from)
                .toList();
    }

    /** PRESENT and LATE both count as attended. */
    @Transactional(readOnly = true)
    public AttendanceSummary summarize(Long studentId, Long courseId) {
        studentService.findById(studentId);
        courseService.findById(courseId);

        long total = attendanceRepository.countByStudentIdAndCourseId(studentId, courseId);
        long attended = attendanceRepository.countByStudentIdAndCourseIdAndStatus(
                studentId, courseId, AttendanceStatus.PRESENT)
                + attendanceRepository.countByStudentIdAndCourseIdAndStatus(
                studentId, courseId, AttendanceStatus.LATE);

        double percentage = total == 0 ? 0.0 : Math.round(attended * 10000.0 / total) / 100.0;
        return new AttendanceSummary(studentId, courseId, total, attended, percentage);
    }
}
