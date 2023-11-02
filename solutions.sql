USE erasmus

--1
SELECT
  CASE
    WHEN g.grades >= 9 THEN 'EXCELLENT'
    WHEN g.grades >= 7 THEN 'GOOD'
    WHEN g.grades >= 5 THEN 'PASS'
    ELSE 'FAIL'
  END AS grade_category,
  ROUND(AVG(DATEDIFF(CURDATE(), s.dob) / 365)) AS average_age
FROM students s
JOIN grades g ON s.student_id = g.student_id
GROUP BY grade_category;

--2
SELECT u.uni_name, ROUND(AVG(DATEDIFF(CURDATE(), s.dob) / 365)) AS average_age
FROM university u
JOIN campus c ON c.university_id = u.university_id
JOIN students s ON s.campus_id = c.campus_id
GROUP BY u.uni_name;

--3
SELECT
  s.subj_name,
  COUNT(CASE WHEN g.grades < 5 THEN 1 END) AS num_failed,
  COUNT(*) AS total_students,
  CONCAT(ROUND((COUNT(CASE WHEN g.grades < 5 THEN 1 END) * 100.0 / COUNT(*)), 2), '%') AS proportion_failed
FROM grades g
JOIN subjects s ON g.subject_id = s.subject_id
GROUP BY s.subj_name
ORDER BY proportion_failed DESC;

-- 4
SELECT 'Erasmus' AS Erasmus_Status, round(avg(grades.grades), 2) AS Avg_Grades
  FROM grades
  JOIN students ON grades.student_id = students.student_id
  JOIN international_agreement ON students.student_id = international_agreement.student_id
  UNION ALL

SELECT 'Non-Erasmus' AS Erasmus_Status, round(avg(grades.grades), 2) AS Avg_Grades
  FROM grades
  LEFT JOIN students ON grades.student_id = students.student_id
  LEFT JOIN international_agreement ON students.student_id = international_agreement.student_id
  WHERE international_agreement.student_id IS NULL;
	
-- 5      
SELECT university.university_id, university.uni_name, COUNT(CASE WHEN LEFT(bachelor.bachelor_id, 1) = 'B' THEN 1 END) AS COUNT_Bachelor, COUNT(CASE WHEN LEFT(bachelor.bachelor_id, 1) = 'M' THEN 1 END) AS COUNT_Master, COUNT(CASE WHEN LEFT(bachelor.bachelor_id, 1) = 'D' THEN 1 END) AS COUNT_PHD
  FROM bachelor
  JOIN university ON bachelor.university_id = university.university_id
  GROUP BY university.university_id;