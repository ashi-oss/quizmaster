const db = require('../config/db');

// CREATE QUIZ (admin only)
const createQuiz = (req, res) => {
  const { title, description, category_id, duration_minutes, total_marks } = req.body;
  const created_by = req.user.id;

  db.query(
    'INSERT INTO quizzes (title, description, category_id, duration_minutes, total_marks, created_by) VALUES (?, ?, ?, ?, ?, ?)',
    [title, description, category_id, duration_minutes, total_marks, created_by],
    (err, result) => {
      if (err) return res.status(500).json({ message: 'Error creating quiz', error: err });
      res.status(201).json({ message: 'Quiz created!', quizId: result.insertId });
    }
  );
};

// GET ALL QUIZZES
const getAllQuizzes = (req, res) => {
  db.query(
    `SELECT q.*, c.name AS category
     FROM quizzes q
     LEFT JOIN users u ON q.created_by = u.id
     LEFT JOIN categories c ON q.category_id = c.id`,
    (err, results) => {
      if (err) return res.status(500).json({ message: 'Error fetching quizzes', error: err });
      res.json(results);
    }
  );
};

// GET SINGLE QUIZ WITH RANDOM QUESTIONS FROM BANK
const getQuizById = (req, res) => {
  const { id } = req.params;

  db.query('SELECT * FROM quizzes WHERE id = ?', [id], (err, quizResults) => {
    if (err) return res.status(500).json({ message: 'Error fetching quiz', error: err });
    if (quizResults.length === 0) return res.status(404).json({ message: 'Quiz not found' });

    const quiz = quizResults[0];

    db.query(
      'SELECT * FROM question_bank WHERE category_id = ? ORDER BY RAND() LIMIT 10',
      [quiz.category_id],
      (err, questions) => {
        if (err) return res.status(500).json({ message: 'Error fetching questions', error: err });
        res.json({ quiz, questions });
      }
    );
  });
};

// ADD QUESTION TO QUIZ (admin only)
const addQuestion = (req, res) => {
  const { quiz_id, question_text, option_a, option_b, option_c, option_d, correct_option, marks } = req.body;

  db.query(
    'INSERT INTO questions (quiz_id, question_text, option_a, option_b, option_c, option_d, correct_option, marks) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
    [quiz_id, question_text, option_a, option_b, option_c, option_d, correct_option, marks || 1],
    (err, result) => {
      if (err) return res.status(500).json({ message: 'Error adding question', error: err });
      res.status(201).json({ message: 'Question added!', questionId: result.insertId });
    }
  );
};

// DELETE QUIZ (admin only)
const deleteQuiz = (req, res) => {
  const { id } = req.params;
  db.query('DELETE FROM quizzes WHERE id = ?', [id], (err) => {
    if (err) return res.status(500).json({ message: 'Error deleting quiz', error: err });
    res.json({ message: 'Quiz deleted successfully!' });
  });
};

// SUBMIT QUIZ (student)
const submitQuiz = (req, res) => {
  const { quiz_id, answers } = req.body;
  const student_id = req.user.id;

  db.query('SELECT * FROM quizzes WHERE id = ?', [quiz_id], (err, quizResults) => {
    if (err) return res.status(500).json({ message: 'Database error', error: err });

    const answeredIds = Object.keys(answers).map(Number);
    if (!answeredIds.length) return res.status(400).json({ message: 'No answers submitted' });

    db.query(
      'SELECT * FROM question_bank WHERE id IN (?)',
      [answeredIds],
      (err, questions) => {
        if (err) return res.status(500).json({ message: 'Error fetching questions', error: err });

        let score = 0;
        let total_marks = questions.length;

        questions.forEach((q) => {
          if (answers[q.id] && answers[q.id] === q.correct_option) {
            score += q.marks;
          }
        });

        db.query(
          'INSERT INTO results (student_id, quiz_id, score, total_marks) VALUES (?, ?, ?, ?)',
          [student_id, quiz_id, score, total_marks],
          (err) => {
            if (err) return res.status(500).json({ message: 'Error saving result', error: err });

            db.query(
              `INSERT INTO student_analytics (student_id, total_quizzes_taken, average_score, best_score)
               VALUES (?, 1, ?, ?)
               ON DUPLICATE KEY UPDATE
                 total_quizzes_taken = total_quizzes_taken + 1,
                 average_score = (average_score * (total_quizzes_taken - 1) + ?) / total_quizzes_taken,
                 best_score = GREATEST(best_score, ?)`,
              [student_id, score, score, score, score]
            );

            res.json({
              message: 'Quiz submitted!',
              score,
              total_marks,
              percentage: ((score / total_marks) * 100).toFixed(1) + '%'
            });
          }
        );
      }
    );
  });
};
module.exports = { createQuiz, getAllQuizzes, getQuizById, addQuestion, deleteQuiz, submitQuiz };