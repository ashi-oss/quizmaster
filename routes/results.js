const express = require('express');
const router = express.Router();
const { verifyToken, isAdmin } = require('../middleware/auth');
const db = require('../config/db');

// Student: view own results
router.get('/my', verifyToken, (req, res) => {
  db.query(
    `SELECT r.*, q.title AS quiz_title
     FROM results r
     JOIN quizzes q ON r.quiz_id = q.id
     WHERE r.student_id = ?
     ORDER BY r.submitted_at DESC`,
    [req.user.id],
    (err, results) => {
      if (err) return res.status(500).json({ message: 'Error fetching results', error: err });
      res.json(results);
    }
  );
});

// Admin: view all results
router.get('/all', verifyToken, isAdmin, (req, res) => {
  db.query(
    `SELECT r.*, u.name AS student_name, q.title AS quiz_title
     FROM results r
     JOIN users u ON r.student_id = u.id
     JOIN quizzes q ON r.quiz_id = q.id
     ORDER BY r.submitted_at DESC`,
    (err, results) => {
      if (err) return res.status(500).json({ message: 'Error fetching results', error: err });
      res.json(results);
    }
  );
});

// Leaderboard
router.get('/leaderboard', verifyToken, (req, res) => {
  db.query(
    `SELECT
       u.name AS student_name,
       COUNT(r.id) AS total_attempts,
       ROUND(AVG(r.score / r.total_marks * 100), 1) AS avg_pct,
       ROUND(MAX(r.score / r.total_marks * 100), 1) AS best_pct
     FROM results r
     JOIN users u ON r.student_id = u.id
     GROUP BY u.id, u.name
     ORDER BY avg_pct DESC
     LIMIT 50`,
    (err, results) => {
      if (err) return res.status(500).json({ message: 'Error fetching leaderboard', error: err });
      res.json(results);
    }
  );
});

module.exports = router;