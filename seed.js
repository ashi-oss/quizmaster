const mysql = require('mysql2/promise');
require('dotenv').config();

(async () => {
  const connection = await mysql.createConnection({
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
  });

  const categories = [
    { name: 'Mathematics', description: 'Math problems, fundamentals, and reasoning.' },
    { name: 'Science', description: 'Physics, chemistry, biology, and logical science questions.' },
    { name: 'History', description: 'Important historical events, dates, and people.' }
  ];

  const quizData = [
    {
      title: 'Mathematics Essentials',
      description: 'A 10-question math quiz covering basic algebra and number sense.',
      category: 'Mathematics',
      duration: 15,
      total_marks: 10,
      questions: [
        ['What is 12 × 9?', '108', '92', '99', '116', 'a'],
        ['What is the value of x if 2x + 5 = 13?', '2', '3', '4', '6', 'c'],
        ['A triangle has angles 40° and 60°. What is the third angle?', '60°', '70°', '80°', '90°', 'c'],
        ['What is 25% of 200?', '25', '50', '100', '150', 'b'],
        ['What is 7 + 8 × 2?', '30', '23', '16', '22', 'b'],
        ['What is the next number in the sequence: 2, 4, 8, 16, ?', '24', '30', '32', '34', 'c'],
        ['Which of these is a prime number?', '15', '21', '29', '33', 'c'],
        ['What is the perimeter of a rectangle with width 4 and height 7?', '22', '24', '28', '32', 'a'],
        ['Which fraction is equal to 0.75?', '3/4', '2/3', '1/4', '4/5', 'a'],
        ['What is 5²?', '10', '15', '20', '25', 'd']
      ]
    },
    {
      title: 'Science Fundamentals',
      description: 'A 10-question science quiz on basic concepts and facts.',
      category: 'Science',
      duration: 15,
      total_marks: 10,
      questions: [
        ['What is the chemical symbol for water?', 'H2O', 'CO2', 'NaCl', 'O2', 'a'],
        ['Which planet is known as the Red Planet?', 'Venus', 'Mars', 'Jupiter', 'Mercury', 'b'],
        ['What type of animal is a frog?', 'Mammal', 'Reptile', 'Amphibian', 'Bird', 'c'],
        ['What force pulls objects toward Earth?', 'Magnetism', 'Gravity', 'Friction', 'Electricity', 'b'],
        ['Which gas do plants use during photosynthesis?', 'Oxygen', 'Carbon dioxide', 'Nitrogen', 'Hydrogen', 'b'],
        ['What is the freezing point of water in Celsius?', '0°C', '32°C', '100°C', '-10°C', 'a'],
        ['Which organ pumps blood through the body?', 'Lung', 'Brain', 'Heart', 'Liver', 'c'],
        ['Which substance is used as fuel in a car engine?', 'Water', 'Petrol', 'Salt', 'Sand', 'b'],
        ['What bright object is at the center of our solar system?', 'Moon', 'Earth', 'Sun', 'Venus', 'c'],
        ['Which of the following is not a state of matter?', 'Solid', 'Liquid', 'Gas', 'Color', 'd']
      ]
    },
    {
      title: 'World History Quiz',
      description: 'A 10-question quiz about major world history moments.',
      category: 'History',
      duration: 15,
      total_marks: 10,
      questions: [
        ['Who was the first President of the United States?', 'George Washington', 'Abraham Lincoln', 'Thomas Jefferson', 'John Adams', 'a'],
        ['Which ancient civilization built the pyramids?', 'Romans', 'Greeks', 'Egyptians', 'Mayans', 'c'],
        ['In which year did World War II end?', '1942', '1945', '1948', '1951', 'b'],
        ['Who discovered America in 1492?', 'Marco Polo', 'Christopher Columbus', 'Ferdinand Magellan', 'James Cook', 'b'],
        ['The Berlin Wall fell in which decade?', '1950s', '1960s', '1970s', '1980s', 'd'],
        ['Which empire was ruled by Julius Caesar?', 'Persian', 'Roman', 'Ottoman', 'Mongol', 'b'],
        ['What was the name of the ship that carried passengers to America in 1620?', 'Mayflower', 'Santa Maria', 'Endeavour', 'Beagle', 'a'],
        ['Which U.S. document begins with "We the People"?', 'Bill of Rights', 'Declaration of Independence', 'Constitution', 'Gettysburg Address', 'c'],
        ['What year did the Titanic sink?', '1905', '1912', '1920', '1930', 'b'],
        ['Which African country was never colonized by a European power?', 'Egypt', 'South Africa', 'Ethiopia', 'Nigeria', 'c']
      ]
    }
  ];

  try {
    for (const category of categories) {
      const [rows] = await connection.execute('SELECT id FROM categories WHERE name = ?', [category.name]);
      if (!rows.length) {
        await connection.execute('INSERT INTO categories (name, description) VALUES (?, ?)', [category.name, category.description]);
      }
    }

    for (const quiz of quizData) {
      const [categoryRow] = await connection.execute('SELECT id FROM categories WHERE name = ?', [quiz.category]);
      if (!categoryRow.length) continue;
      const categoryId = categoryRow[0].id;

      const [quizRows] = await connection.execute('SELECT id FROM quizzes WHERE title = ?', [quiz.title]);
      let quizId;
      if (quizRows.length) {
        quizId = quizRows[0].id;
      } else {
        const [result] = await connection.execute(
          'INSERT INTO quizzes (title, description, category_id, duration_minutes, total_marks, created_by) VALUES (?, ?, ?, ?, ?, NULL)',
          [quiz.title, quiz.description, categoryId, quiz.duration, quiz.total_marks]
        );
        quizId = result.insertId;
      }

      for (const [text, a, b, c, d, correct] of quiz.questions) {
        const [questionRows] = await connection.execute(
          'SELECT id FROM questions WHERE quiz_id = ? AND question_text = ?', [quizId, text]
        );
        if (!questionRows.length) {
          await connection.execute(
            'INSERT INTO questions (quiz_id, question_text, option_a, option_b, option_c, option_d, correct_option, marks) VALUES (?, ?, ?, ?, ?, ?, ?, 1)',
            [quizId, text, a, b, c, d, correct]
          );
        }
      }
    }

    console.log('Sample subjects and quizzes added successfully.');
  } catch (error) {
    console.error('Seeding error:', error);
  } finally {
    await connection.end();
  }
})();
