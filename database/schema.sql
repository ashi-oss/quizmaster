-- Users table
CREATE TABLE IF NOT EXISTS users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(100) NOT NULL UNIQUE,
  password VARCHAR(255) NOT NULL,
  role ENUM('admin', 'student') DEFAULT 'student',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Categories table
CREATE TABLE IF NOT EXISTS categories (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  description TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Quizzes table
CREATE TABLE IF NOT EXISTS quizzes (
  id INT AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(200) NOT NULL,
  description TEXT,
  category_id INT,
  duration_minutes INT NOT NULL DEFAULT 10,
  total_marks INT NOT NULL DEFAULT 0,
  created_by INT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (category_id) REFERENCES categories(id),
  FOREIGN KEY (created_by) REFERENCES users(id)
);

-- Question bank (reusable questions)
CREATE TABLE IF NOT EXISTS question_bank (
  id INT AUTO_INCREMENT PRIMARY KEY,
  category_id INT,
  question_text TEXT NOT NULL,
  option_a VARCHAR(255) NOT NULL,
  option_b VARCHAR(255) NOT NULL,
  option_c VARCHAR(255) NOT NULL,
  option_d VARCHAR(255) NOT NULL,
  correct_option ENUM('a','b','c','d') NOT NULL,
  marks INT DEFAULT 1,
  FOREIGN KEY (category_id) REFERENCES categories(id)
);

-- Questions (linked to a specific quiz)
CREATE TABLE IF NOT EXISTS questions (
  id INT AUTO_INCREMENT PRIMARY KEY,
  quiz_id INT NOT NULL,
  question_text TEXT NOT NULL,
  option_a VARCHAR(255) NOT NULL,
  option_b VARCHAR(255) NOT NULL,
  option_c VARCHAR(255) NOT NULL,
  option_d VARCHAR(255) NOT NULL,
  correct_option ENUM('a','b','c','d') NOT NULL,
  marks INT DEFAULT 1,
  FOREIGN KEY (quiz_id) REFERENCES quizzes(id) ON DELETE CASCADE
);

-- Results table
CREATE TABLE IF NOT EXISTS results (
  id INT AUTO_INCREMENT PRIMARY KEY,
  student_id INT NOT NULL,
  quiz_id INT NOT NULL,
  score INT NOT NULL,
  total_marks INT NOT NULL,
  submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (student_id) REFERENCES users(id),
  FOREIGN KEY (quiz_id) REFERENCES quizzes(id)
);

-- User progress tracking
CREATE TABLE IF NOT EXISTS user_progress (
  id INT AUTO_INCREMENT PRIMARY KEY,
  student_id INT NOT NULL,
  quiz_id INT NOT NULL,
  questions_attempted INT DEFAULT 0,
  correct_answers INT DEFAULT 0,
  last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (student_id) REFERENCES users(id),
  FOREIGN KEY (quiz_id) REFERENCES quizzes(id)
);

-- Student analytics
CREATE TABLE IF NOT EXISTS student_analytics (
  id INT AUTO_INCREMENT PRIMARY KEY,
  student_id INT NOT NULL UNIQUE,
  total_quizzes_taken INT DEFAULT 0,
  average_score DECIMAL(5,2) DEFAULT 0.00,
  best_score INT DEFAULT 0,
  last_active TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (student_id) REFERENCES users(id)
);

-- User quiz sessions (timer tracking)
CREATE TABLE IF NOT EXISTS user_quiz_sessions (
  id INT AUTO_INCREMENT PRIMARY KEY,
  student_id INT NOT NULL,
  quiz_id INT NOT NULL,
  started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  ended_at TIMESTAMP NULL,
  status ENUM('in_progress', 'completed', 'timed_out') DEFAULT 'in_progress',
  FOREIGN KEY (student_id) REFERENCES users(id),
  FOREIGN KEY (quiz_id) REFERENCES quizzes(id)
);

-- Sample subjects and quizzes for a richer initial setup
INSERT INTO categories (name, description)
SELECT 'Mathematics', 'Math problems, fundamentals, and reasoning.'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM categories WHERE name = 'Mathematics');

INSERT INTO categories (name, description)
SELECT 'Science', 'Physics, chemistry, biology, and logical science questions.'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM categories WHERE name = 'Science');

INSERT INTO categories (name, description)
SELECT 'History', 'Important historical events, dates, and people.'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM categories WHERE name = 'History');

INSERT INTO quizzes (title, description, category_id, duration_minutes, total_marks, created_by)
SELECT 'Mathematics Essentials', 'A 10-question math quiz covering basic algebra and number sense.',
       (SELECT id FROM categories WHERE name = 'Mathematics'), 15, 10, NULL
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM quizzes WHERE title = 'Mathematics Essentials');

INSERT INTO quizzes (title, description, category_id, duration_minutes, total_marks, created_by)
SELECT 'Science Fundamentals', 'A 10-question science quiz on basic concepts and facts.',
       (SELECT id FROM categories WHERE name = 'Science'), 15, 10, NULL
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM quizzes WHERE title = 'Science Fundamentals');

INSERT INTO quizzes (title, description, category_id, duration_minutes, total_marks, created_by)
SELECT 'World History Quiz', 'A 10-question quiz about major world history moments.',
       (SELECT id FROM categories WHERE name = 'History'), 15, 10, NULL
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM quizzes WHERE title = 'World History Quiz');

INSERT INTO questions (quiz_id, question_text, option_a, option_b, option_c, option_d, correct_option, marks)
SELECT q.id, 'What is 12 × 9?', '108', '92', '99', '116', 'a', 1
FROM quizzes q
WHERE q.title = 'Mathematics Essentials'
  AND NOT EXISTS (SELECT 1 FROM questions WHERE quiz_id = q.id AND question_text = 'What is 12 × 9?');

INSERT INTO questions (quiz_id, question_text, option_a, option_b, option_c, option_d, correct_option, marks)
SELECT q.id, 'What is the value of x if 2x + 5 = 13?', '2', '3', '4', '6', 'c', 1
FROM quizzes q
WHERE q.title = 'Mathematics Essentials'
  AND NOT EXISTS (SELECT 1 FROM questions WHERE quiz_id = q.id AND question_text = 'What is the value of x if 2x + 5 = 13?');

INSERT INTO questions (quiz_id, question_text, option_a, option_b, option_c, option_d, correct_option, marks)
SELECT q.id, 'A triangle has angles 40° and 60°. What is the third angle?', '60°', '70°', '80°', '90°', 'c', 1
FROM quizzes q
WHERE q.title = 'Mathematics Essentials'
  AND NOT EXISTS (SELECT 1 FROM questions WHERE quiz_id = q.id AND question_text = 'A triangle has angles 40° and 60°. What is the third angle?');

INSERT INTO questions (quiz_id, question_text, option_a, option_b, option_c, option_d, correct_option, marks)
SELECT q.id, 'What is 25% of 200?', '25', '50', '100', '150', 'b', 1
FROM quizzes q
WHERE q.title = 'Mathematics Essentials'
  AND NOT EXISTS (SELECT 1 FROM questions WHERE quiz_id = q.id AND question_text = 'What is 25% of 200?');

INSERT INTO questions (quiz_id, question_text, option_a, option_b, option_c, option_d, correct_option, marks)
SELECT q.id, 'What is 7 + 8 × 2?', '30', '23', '16', '22', 'b', 1
FROM quizzes q
WHERE q.title = 'Mathematics Essentials'
  AND NOT EXISTS (SELECT 1 FROM questions WHERE quiz_id = q.id AND question_text = 'What is 7 + 8 × 2?');

INSERT INTO questions (quiz_id, question_text, option_a, option_b, option_c, option_d, correct_option, marks)
SELECT q.id, 'What is the next number in the sequence: 2, 4, 8, 16, ?', '24', '30', '32', '34', 'c', 1
FROM quizzes q
WHERE q.title = 'Mathematics Essentials'
  AND NOT EXISTS (SELECT 1 FROM questions WHERE quiz_id = q.id AND question_text = 'What is the next number in the sequence: 2, 4, 8, 16, ?');

INSERT INTO questions (quiz_id, question_text, option_a, option_b, option_c, option_d, correct_option, marks)
SELECT q.id, 'Which of these is a prime number?', '15', '21', '29', '33', 'c', 1
FROM quizzes q
WHERE q.title = 'Mathematics Essentials'
  AND NOT EXISTS (SELECT 1 FROM questions WHERE quiz_id = q.id AND question_text = 'Which of these is a prime number?');

INSERT INTO questions (quiz_id, question_text, option_a, option_b, option_c, option_d, correct_option, marks)
SELECT q.id, 'What is the perimeter of a rectangle with width 4 and height 7?', '22', '24', '28', '32', 'a', 1
FROM quizzes q
WHERE q.title = 'Mathematics Essentials'
  AND NOT EXISTS (SELECT 1 FROM questions WHERE quiz_id = q.id AND question_text = 'What is the perimeter of a rectangle with width 4 and height 7?');

INSERT INTO questions (quiz_id, question_text, option_a, option_b, option_c, option_d, correct_option, marks)
SELECT q.id, 'Which fraction is equal to 0.75?', '3/4', '2/3', '1/4', '4/5', 'a', 1
FROM quizzes q
WHERE q.title = 'Mathematics Essentials'
  AND NOT EXISTS (SELECT 1 FROM questions WHERE quiz_id = q.id AND question_text = 'Which fraction is equal to 0.75?');

INSERT INTO questions (quiz_id, question_text, option_a, option_b, option_c, option_d, correct_option, marks)
SELECT q.id, 'What is 5²?', '10', '15', '20', '25', 'd', 1
FROM quizzes q
WHERE q.title = 'Mathematics Essentials'
  AND NOT EXISTS (SELECT 1 FROM questions WHERE quiz_id = q.id AND question_text = 'What is 5²?');

INSERT INTO questions (quiz_id, question_text, option_a, option_b, option_c, option_d, correct_option, marks)
SELECT q.id, 'Which number is even?', '13', '19', '22', '27', 'c', 1
FROM quizzes q
WHERE q.title = 'Mathematics Essentials'
  AND NOT EXISTS (SELECT 1 FROM questions WHERE quiz_id = q.id AND question_text = 'Which number is even?');

INSERT INTO questions (quiz_id, question_text, option_a, option_b, option_c, option_d, correct_option, marks)
SELECT q.id, 'What is the value of 45 ÷ 9?', '5', '6', '7', '8', 'a', 1
FROM quizzes q
WHERE q.title = 'Mathematics Essentials'
  AND NOT EXISTS (SELECT 1 FROM questions WHERE quiz_id = q.id AND question_text = 'What is the value of 45 ÷ 9?');

INSERT INTO questions (quiz_id, question_text, option_a, option_b, option_c, option_d, correct_option, marks)
SELECT q.id, 'What is the sum of 14 and 27?', '41', '42', '43', '44', 'a', 1
FROM quizzes q
WHERE q.title = 'Mathematics Essentials'
  AND NOT EXISTS (SELECT 1 FROM questions WHERE quiz_id = q.id AND question_text = 'What is the sum of 14 and 27?');

INSERT INTO questions (quiz_id, question_text, option_a, option_b, option_c, option_d, correct_option, marks)
SELECT q.id, 'Which of these is a multiple of 6?', '14', '18', '22', '25', 'b', 1
FROM quizzes q
WHERE q.title = 'Mathematics Essentials'
  AND NOT EXISTS (SELECT 1 FROM questions WHERE quiz_id = q.id AND question_text = 'Which of these is a multiple of 6?');

INSERT INTO questions (quiz_id, question_text, option_a, option_b, option_c, option_d, correct_option, marks)
SELECT q.id, 'What is the chemical symbol for water?', 'H2O', 'CO2', 'NaCl', 'O2', 'a', 1
FROM quizzes q
WHERE q.title = 'Science Fundamentals'
  AND NOT EXISTS (SELECT 1 FROM questions WHERE quiz_id = q.id AND question_text = 'What is the chemical symbol for water?');

INSERT INTO questions (quiz_id, question_text, option_a, option_b, option_c, option_d, correct_option, marks)
SELECT q.id, 'Which planet is known as the Red Planet?', 'Venus', 'Mars', 'Jupiter', 'Mercury', 'b', 1
FROM quizzes q
WHERE q.title = 'Science Fundamentals'
  AND NOT EXISTS (SELECT 1 FROM questions WHERE quiz_id = q.id AND question_text = 'Which planet is known as the Red Planet?');

INSERT INTO questions (quiz_id, question_text, option_a, option_b, option_c, option_d, correct_option, marks)
SELECT q.id, 'What type of animal is a frog?', 'Mammal', 'Reptile', 'Amphibian', 'Bird', 'c', 1
FROM quizzes q
WHERE q.title = 'Science Fundamentals'
  AND NOT EXISTS (SELECT 1 FROM questions WHERE quiz_id = q.id AND question_text = 'What type of animal is a frog?');

INSERT INTO questions (quiz_id, question_text, option_a, option_b, option_c, option_d, correct_option, marks)
SELECT q.id, 'What force pulls objects toward Earth?', 'Magnetism', 'Gravity', 'Friction', 'Electricity', 'b', 1
FROM quizzes q
WHERE q.title = 'Science Fundamentals'
  AND NOT EXISTS (SELECT 1 FROM questions WHERE quiz_id = q.id AND question_text = 'What force pulls objects toward Earth?');

INSERT INTO questions (quiz_id, question_text, option_a, option_b, option_c, option_d, correct_option, marks)
SELECT q.id, 'Which gas do plants use during photosynthesis?', 'Oxygen', 'Carbon dioxide', 'Nitrogen', 'Hydrogen', 'b', 1
FROM quizzes q
WHERE q.title = 'Science Fundamentals'
  AND NOT EXISTS (SELECT 1 FROM questions WHERE quiz_id = q.id AND question_text = 'Which gas do plants use during photosynthesis?');

INSERT INTO questions (quiz_id, question_text, option_a, option_b, option_c, option_d, correct_option, marks)
SELECT q.id, 'What is the freezing point of water in Celsius?', '0°C', '32°C', '100°C', '-10°C', 'a', 1
FROM quizzes q
WHERE q.title = 'Science Fundamentals'
  AND NOT EXISTS (SELECT 1 FROM questions WHERE quiz_id = q.id AND question_text = 'What is the freezing point of water in Celsius?');

INSERT INTO questions (quiz_id, question_text, option_a, option_b, option_c, option_d, correct_option, marks)
SELECT q.id, 'Which organ pumps blood through the body?', 'Lung', 'Brain', 'Heart', 'Liver', 'c', 1
FROM quizzes q
WHERE q.title = 'Science Fundamentals'
  AND NOT EXISTS (SELECT 1 FROM questions WHERE quiz_id = q.id AND question_text = 'Which organ pumps blood through the body?');

INSERT INTO questions (quiz_id, question_text, option_a, option_b, option_c, option_d, correct_option, marks)
SELECT q.id, 'Which substance is used as fuel in a car engine?', 'Water', 'Petrol', 'Salt', 'Sand', 'b', 1
FROM quizzes q
WHERE q.title = 'Science Fundamentals'
  AND NOT EXISTS (SELECT 1 FROM questions WHERE quiz_id = q.id AND question_text = 'Which substance is used as fuel in a car engine?');

INSERT INTO questions (quiz_id, question_text, option_a, option_b, option_c, option_d, correct_option, marks)
SELECT q.id, 'What bright object is at the center of our solar system?', 'Moon', 'Earth', 'Sun', 'Venus', 'c', 1
FROM quizzes q
WHERE q.title = 'Science Fundamentals'
  AND NOT EXISTS (SELECT 1 FROM questions WHERE quiz_id = q.id AND question_text = 'What bright object is at the center of our solar system?');

INSERT INTO questions (quiz_id, question_text, option_a, option_b, option_c, option_d, correct_option, marks)
SELECT q.id, 'Who was the first President of the United States?', 'George Washington', 'Abraham Lincoln', 'Thomas Jefferson', 'John Adams', 'a', 1
FROM quizzes q
WHERE q.title = 'World History Quiz'
  AND NOT EXISTS (SELECT 1 FROM questions WHERE quiz_id = q.id AND question_text = 'Who was the first President of the United States?');

INSERT INTO questions (quiz_id, question_text, option_a, option_b, option_c, option_d, correct_option, marks)
SELECT q.id, 'Which ancient civilization built the pyramids?', 'Romans', 'Greeks', 'Egyptians', 'Mayans', 'c', 1
FROM quizzes q
WHERE q.title = 'World History Quiz'
  AND NOT EXISTS (SELECT 1 FROM questions WHERE quiz_id = q.id AND question_text = 'Which ancient civilization built the pyramids?');

INSERT INTO questions (quiz_id, question_text, option_a, option_b, option_c, option_d, correct_option, marks)
SELECT q.id, 'In which year did World War II end?', '1942', '1945', '1948', '1951', 'b', 1
FROM quizzes q
WHERE q.title = 'World History Quiz'
  AND NOT EXISTS (SELECT 1 FROM questions WHERE quiz_id = q.id AND question_text = 'In which year did World War II end?');

INSERT INTO questions (quiz_id, question_text, option_a, option_b, option_c, option_d, correct_option, marks)
SELECT q.id, 'Who discovered America in 1492?', 'Marco Polo', 'Christopher Columbus', 'Ferdinand Magellan', 'James Cook', 'b', 1
FROM quizzes q
WHERE q.title = 'World History Quiz'
  AND NOT EXISTS (SELECT 1 FROM questions WHERE quiz_id = q.id AND question_text = 'Who discovered America in 1492?');

INSERT INTO questions (quiz_id, question_text, option_a, option_b, option_c, option_d, correct_option, marks)
SELECT q.id, 'The Berlin Wall fell in which decade?', '1950s', '1960s', '1970s', '1980s', 'd', 1
FROM quizzes q
WHERE q.title = 'World History Quiz'
  AND NOT EXISTS (SELECT 1 FROM questions WHERE quiz_id = q.id AND question_text = 'The Berlin Wall fell in which decade?');

INSERT INTO questions (quiz_id, question_text, option_a, option_b, option_c, option_d, correct_option, marks)
SELECT q.id, 'Which empire was ruled by Julius Caesar?', 'Persian', 'Roman', 'Ottoman', 'Mongol', 'b', 1
FROM quizzes q
WHERE q.title = 'World History Quiz'
  AND NOT EXISTS (SELECT 1 FROM questions WHERE quiz_id = q.id AND question_text = 'Which empire was ruled by Julius Caesar?');

INSERT INTO questions (quiz_id, question_text, option_a, option_b, option_c, option_d, correct_option, marks)
SELECT q.id, 'What was the name of the ship that carried passengers to America in 1620?', 'Mayflower', 'Santa Maria', 'Endeavour', 'Beagle', 'a', 1
FROM quizzes q
WHERE q.title = 'World History Quiz'
  AND NOT EXISTS (SELECT 1 FROM questions WHERE quiz_id = q.id AND question_text = 'What was the name of the ship that carried passengers to America in 1620?');

INSERT INTO questions (quiz_id, question_text, option_a, option_b, option_c, option_d, correct_option, marks)
SELECT q.id, 'Which U.S. document begins with "We the People"?', 'Bill of Rights', 'Declaration of Independence', 'Constitution', 'Gettysburg Address', 'c', 1
FROM quizzes q
WHERE q.title = 'World History Quiz'
  AND NOT EXISTS (SELECT 1 FROM questions WHERE quiz_id = q.id AND question_text = 'Which U.S. document begins with "We the People"?');

INSERT INTO questions (quiz_id, question_text, option_a, option_b, option_c, option_d, correct_option, marks)
SELECT q.id, 'What year did the Titanic sink?', '1905', '1912', '1920', '1930', 'b', 1
FROM quizzes q
WHERE q.title = 'World History Quiz'
  AND NOT EXISTS (SELECT 1 FROM questions WHERE quiz_id = q.id AND question_text = 'What year did the Titanic sink?');

INSERT INTO questions (quiz_id, question_text, option_a, option_b, option_c, option_d, correct_option, marks)
SELECT q.id, 'Which African country was never colonized by a European power?', 'Egypt', 'South Africa', 'Ethiopia', 'Nigeria', 'c', 1
FROM quizzes q
WHERE q.title = 'World History Quiz'
  AND NOT EXISTS (SELECT 1 FROM questions WHERE quiz_id = q.id AND question_text = 'Which African country was never colonized by a European power?');