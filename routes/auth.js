const express = require('express');
const router = express.Router();
const { register, login } = require('../controllers/authController');
const { verifyToken, isAdmin } = require('../middleware/auth');
const db = require('../config/db');

// POST /api/auth/register
router.post('/register', register);

// POST /api/auth/login
router.post('/login', login);

// GET /api/auth/students (admin only)
router.get('/students', verifyToken, isAdmin, (req, res) => {
  db.query(
    `SELECT u.id, u.name, u.email, u.created_at,
            COALESCE(sa.total_quizzes_taken, 0) AS total_quizzes_taken,
            COALESCE(sa.average_score, 0) AS average_score,
            COALESCE(sa.best_score, 0) AS best_score
     FROM users u
     LEFT JOIN student_analytics sa ON u.id = sa.student_id
     WHERE u.role = 'student'
     ORDER BY u.created_at DESC`,
    (err, results) => {
      if (err) return res.status(500).json({ message: 'Error fetching students', error: err });
      res.json(results);
    }
  );
});

module.exports = router;