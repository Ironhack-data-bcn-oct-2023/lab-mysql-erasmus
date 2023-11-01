USE erasmus;

-- What is the average age of students who have outstanding grades?
	-- EXCELLENT if they have a 9 or 10
    -- GOOD if they have 7 or 8
    -- PASS if they have a 5 or 6
    -- FAIL if it is less than 5
SELECT CASE
	WHEN grades >= 9 THEN "EXCELLENT"
	WHEN grades >= 7 THEN "GOOD"
    WHEN grades >= 5 THEN "PASS"
    ELSE "FAIL"
END AS Grade_Category,
ROUND(AVG( YEAR(now()) - YEAR(dob) )) AS Average_Age
FROM grades
	JOIN students
		ON grades.student_id = students.student_id
GROUP BY Grade_Category
ORDER BY Average_Age;

--  What is the average age of students by university?
SELECT uni_name,
ROUND(AVG(YEAR(now()) - YEAR(students.dob))) AS average_age
FROM university
	JOIN campus
		ON university.university_id = campus.university_id
	JOIN students
		ON campus.campus_id = students.campus_id
GROUP BY uni_name
ORDER BY average_age DESC;

-- What is the proportion of students who failed each subject?


-- What is the average grade of students who have done an erasmus compared to those who have not?
SELECT CASE
	WHEN international_agreement.agreement_code IS NOT NULL THEN "Erasmus"
    ELSE 'Not Erasmus'
END AS Erasmus_Status,
    AVG(grades.grades) AS AVG_Grade
FROM students
    LEFT JOIN international_agreement
		ON students.student_id = international_agreement.student_id
    LEFT JOIN grades
		ON students.student_id = grades.student_id
GROUP BY Erasmus_Status;

-- For each university, identify the number of bachelor’s, master’s and PhD degrees awarded.
SELECT university.university_id, university.uni_name,
    SUM(LEFT(bachelor.bachelor_id, 1) = 'B') AS Bachelor_Count,
    SUM(LEFT(bachelor.bachelor_id, 1) = 'M') AS Master_Count,
    SUM(LEFT(bachelor.bachelor_id, 1) = 'D') AS Phd_Count
FROM university
	JOIN bachelor
		ON university.university_id = bachelor.university_id
GROUP BY university.university_id;

-- Which are the top 5 universities with the highest average ranking over the years?
SELECT university.University_ID, uni_name AS University_Name,
ROUND(AVG(intl_ranking)) AS Average_Ranking
FROM ranking
	JOIN university
		ON ranking.university_id = university.university_id
GROUP BY university.university_id
ORDER BY Average_Ranking DESC
LIMIT 5;

-- Provide the id, the name, the last name, the name of the home university and the email of the 10 students
-- that have been on an international agreement more times.
SELECT students.student_id, f_name, l_name,
MAX(university.uni_name) AS Home_University, email,
COUNT(international_agreement.home_university) AS Agreement_Count
FROM students
	JOIN international_agreement
		ON students.student_id = international_agreement.student_id
	JOIN university
		ON international_agreement.home_university = university.university_id
GROUP BY students.student_id, f_name, l_name, email
ORDER BY Agreement_Count DESC
LIMIT 10;

-- Make a query where, by modifying the international agreement number, you can identify the id and name of the student who did the exchange, 
-- the name of the home university and the name of the city where the exchange took place.
SELECT agreement_code, students.student_id,
students.f_name AS Student_First_Name,
students.l_name AS Student_Last_name,
university.uni_name AS Home_University,
(SELECT uni_name FROM university WHERE university.university_id = international_agreement.away_university) AS Away_University
FROM students
	JOIN international_agreement
		ON students.student_id = international_agreement.student_id
	JOIN university
		ON international_agreement.home_university = university.university_id
	JOIN campus
		ON students.campus_id = campus.campus_id
WHERE agreement_code = "9OP82";

-- Find and display the number of universities offering each subject, along with the average grade for each subject.
SELECT subjects.subj_name AS Subject,
ROUND(AVG(grades.grades)) AS Average_Grade,
COUNT(DISTINCT university.university_id) AS Num_Universidades
FROM subjects
	JOIN uni_subj
		ON subjects.subject_id = uni_subj.subject_id
	JOIN university
		ON uni_subj.university_id = university.university_id
	JOIN grades
		ON subjects.subject_id = grades.subject_id
GROUP BY subjects.subj_name
ORDER BY Subject ASC;

-- Find the top 5 cities with the highest percentage of students who have outstanding grades (9 or 10).
	-- No entiendo donde está el error
SELECT campus.City, campus.State,
SUM(grades.grades >= 9) / COUNT(grades.student_id) * 100 AS Percentage_Outstanding
FROM grades
	JOIN students
		ON grades.student_id = students.student_id
	JOIN campus
		ON students.campus_id = campus.campus_id
GROUP BY campus.city, campus.state
ORDER BY percentage_outstanding DESC
LIMIT 5;

