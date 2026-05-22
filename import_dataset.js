const mysql = require('mysql2/promise');
const fs = require('fs');
require('dotenv').config();

// Usage: node import_dataset.js [path_to_json]
// JSON format example (array):
// [
//   {
//     "category": "COAL",
//     "quizzes": [
//       {
//         "title": "COAL Fundamentals",
//         "description": "...",
//         "duration": 15,
//         "total_marks": 10,
//         "questions": [
//           { "text": "...", "a": "..", "b": "..", "c": "..", "d": "..", "correct": "a" },
//           ...
//         ]
//       }
//     ]
//   }
// ]

(async () => {
  const file = process.argv[2] || 'dataset.json';
  if (!fs.existsSync(file)) {
    console.error(`Dataset file not found: ${file}`);
    process.exit(1);
  }

  const raw = fs.readFileSync(file, 'utf8');
  let data;
  try { data = JSON.parse(raw); } catch (err) { console.error('Invalid JSON:', err.message); process.exit(1); }

  const connection = await mysql.createConnection({
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
  });

  try {
    for (const cat of data) {
      const categoryName = cat.category || cat.name;
      if (!categoryName) continue;

      // ensure category
      const [catRows] = await connection.execute('SELECT id FROM categories WHERE name = ?', [categoryName]);
      let categoryId;
      if (catRows.length) categoryId = catRows[0].id;
      else {
        const [result] = await connection.execute('INSERT INTO categories (name, description) VALUES (?, ?)', [categoryName, cat.description || null]);
        categoryId = result.insertId;
      }

      if (!Array.isArray(cat.quizzes)) continue;
      for (const q of cat.quizzes) {
        if (!q.title) continue;
        const [quizRows] = await connection.execute('SELECT id FROM quizzes WHERE title = ? AND category_id = ?', [q.title, categoryId]);
        let quizId;
        if (quizRows.length) quizId = quizRows[0].id;
        else {
          const [ins] = await connection.execute(
            'INSERT INTO quizzes (title, description, category_id, duration_minutes, total_marks, created_by) VALUES (?, ?, ?, ?, ?, NULL)',
            [q.title, q.description || null, categoryId, q.duration || 15, q.total_marks || 0]
          );
          quizId = ins.insertId;
        }

        if (!Array.isArray(q.questions)) continue;
        for (const ques of q.questions) {
          if (!ques.text) continue;
          const [qRows] = await connection.execute('SELECT id FROM questions WHERE quiz_id = ? AND question_text = ?', [quizId, ques.text]);
          if (qRows.length) continue;
          await connection.execute(
            'INSERT INTO questions (quiz_id, question_text, option_a, option_b, option_c, option_d, correct_option, marks) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
            [quizId, ques.text, ques.a || ques.option_a || '', ques.b || ques.option_b || '', ques.c || ques.option_c || '', ques.d || ques.option_d || '', (ques.correct || 'a'), ques.marks || 1]
          );
        }
      }
    }

    console.log('Import complete');
  } catch (err) {
    console.error('Import error:', err);
  } finally {
    await connection.end();
  }
})();
