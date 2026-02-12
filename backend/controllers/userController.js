const User = require('../models/User');
const Student = require('../models/Student');
const Faculty = require('../models/Faculty');
const { validationResult } = require('express-validator');

exports.getStudents = async (req, res) => {
  try {
    const students = await Student.find().populate('userId', 'name email');
    res.json(students);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.getStudentsList = async (req, res) => {
  try {
    const students = await Student.find().populate('userId', 'name email');
    res.json(students);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.getStudentById = async (req, res) => {
  try {
    const student = await Student.findById(req.params.id).populate('userId', 'name email');
    if (!student) return res.status(404).json({ message: 'Student not found.' });
    res.json(student);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.addStudent = async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) return res.status(400).json({ errors: errors.array() });
    const { name, email, password, rollNo, department, course } = req.body;
    const existing = await User.findOne({ email });
    if (existing) return res.status(400).json({ message: 'Email already registered.' });
    const user = await User.create({ name, email, password, role: 'student' });
    const student = await Student.create({
      userId: user._id,
      rollNo,
      department,
      course,
    });
    const userObj = await User.findById(user._id).select('-password');
    res.status(201).json({ user: userObj, student });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.updateStudent = async (req, res) => {
  try {
    const student = await Student.findById(req.params.id);
    if (!student) return res.status(404).json({ message: 'Student not found.' });
    const { rollNo, department, course } = req.body;
    if (rollNo) student.rollNo = rollNo;
    if (department) student.department = department;
    if (course) student.course = course;
    await student.save();
    if (req.body.name) {
      await User.findByIdAndUpdate(student.userId, { name: req.body.name });
    }
    const updated = await Student.findById(student._id).populate('userId', 'name email');
    res.json(updated);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.deleteStudent = async (req, res) => {
  try {
    const student = await Student.findById(req.params.id);
    if (!student) return res.status(404).json({ message: 'Student not found.' });
    await User.findByIdAndDelete(student.userId);
    await Student.findByIdAndDelete(req.params.id);
    res.json({ message: 'Student deleted.' });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.getFaculty = async (req, res) => {
  try {
    const faculty = await Faculty.find().populate('userId', 'name email');
    res.json(faculty);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.getFacultyList = async (req, res) => {
  try {
    const faculty = await Faculty.find().populate('userId', 'name');
    res.json(faculty);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.getFacultyById = async (req, res) => {
  try {
    const faculty = await Faculty.findById(req.params.id).populate('userId', 'name email');
    if (!faculty) return res.status(404).json({ message: 'Faculty not found.' });
    res.json(faculty);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.addFaculty = async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) return res.status(400).json({ errors: errors.array() });
    const { name, email, password, subjects, employeeId, department } = req.body;
    const existing = await User.findOne({ email });
    if (existing) return res.status(400).json({ message: 'Email already registered.' });
    const user = await User.create({ name, email, password, role: 'faculty' });
    const faculty = await Faculty.create({
      userId: user._id,
      employeeId: (employeeId || '').trim(),
      department: (department || '').trim(),
      subjects: Array.isArray(subjects) ? subjects : subjects ? [subjects] : [],
    });
    const userObj = await User.findById(user._id).select('-password');
    res.status(201).json({ user: userObj, faculty });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.updateFaculty = async (req, res) => {
  try {
    const faculty = await Faculty.findById(req.params.id);
    if (!faculty) return res.status(404).json({ message: 'Faculty not found.' });
    if (req.body.subjects) faculty.subjects = req.body.subjects;
    await faculty.save();
    if (req.body.name) {
      await User.findByIdAndUpdate(faculty.userId, { name: req.body.name });
    }
    const updated = await Faculty.findById(faculty._id).populate('userId', 'name email');
    res.json(updated);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.deleteFaculty = async (req, res) => {
  try {
    const faculty = await Faculty.findById(req.params.id);
    if (!faculty) return res.status(404).json({ message: 'Faculty not found.' });
    await User.findByIdAndDelete(faculty.userId);
    await Faculty.findByIdAndDelete(req.params.id);
    res.json({ message: 'Faculty deleted.' });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};
