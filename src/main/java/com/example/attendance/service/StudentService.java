package com.example.attendance.service;

import com.example.attendance.dto.StudentRequest;
import com.example.attendance.exception.DuplicateResourceException;
import com.example.attendance.exception.ResourceNotFoundException;
import com.example.attendance.model.Student;
import com.example.attendance.repository.StudentRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class StudentService {

    private final StudentRepository studentRepository;

    public StudentService(StudentRepository studentRepository) {
        this.studentRepository = studentRepository;
    }

    @Transactional
    public Student create(StudentRequest request) {
        if (studentRepository.existsByRollNumber(request.rollNumber())) {
            throw new DuplicateResourceException("Roll number already exists: " + request.rollNumber());
        }
        if (studentRepository.existsByEmail(request.email())) {
            throw new DuplicateResourceException("Email already exists: " + request.email());
        }
        return studentRepository.save(new Student(request.rollNumber(), request.name(), request.email()));
    }

    @Transactional(readOnly = true)
    public List<Student> findAll() {
        return studentRepository.findAll();
    }

    @Transactional(readOnly = true)
    public Student findById(Long id) {
        return studentRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Student not found: " + id));
    }

    @Transactional
    public Student update(Long id, StudentRequest request) {
        Student student = findById(id);
        student.setRollNumber(request.rollNumber());
        student.setName(request.name());
        student.setEmail(request.email());
        return studentRepository.save(student);
    }

    @Transactional
    public void delete(Long id) {
        studentRepository.delete(findById(id));
    }
}
