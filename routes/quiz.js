const express = require('express');
const router = express.Router();
const { verifyToken, isAdmin } = require('../middleware/auth');
const { createQuiz, getAllQuizzes, getQuizById, addQuestion, deleteQuiz, submitQuiz } = require('../controllers/quizController');

// Student + Admin
router.get('/', verifyToken, getAllQuizzes);
router.get('/:id', verifyToken, getQuizById);

// Admin only
router.post('/create', verifyToken, isAdmin, createQuiz);
router.post('/add-question', verifyToken, isAdmin, addQuestion);
router.delete('/:id', verifyToken, isAdmin, deleteQuiz);

// Student — submit quiz
router.post('/submit', verifyToken, submitQuiz);

module.exports = router;