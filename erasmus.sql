USE erasmus;

-- 1. What is the average age of students who have outstanding grades? Provide the table with EXCELLENT if they have a 9 or 10, GOOD if they have 7 or 8, PASS if they have a 5 or 6, and FAIL if it is less than 5.
SELECT CASE 	
	WHEN grades.grades >= 9 THEN 'Excellent'
	WHEN grades.grades >= 7 THEN 'Good'
	WHEN grades.grades >= 5 THEN 'Pass'
    ELSE 'Fail'
END AS grade_category,
	ROUND(AVG(YEAR(CURRENT_DATE()) - YEAR(dob))) AS average_age
FROM students
	JOIN grades ON students.student_id = grades.student_id
		GROUP BY grade_category
        ORDER BY average_age ASC;
        
-- 2. What is the average age of students by university?
SELECT
    university.uni_name,
    ROUND(AVG(YEAR(CURRENT_DATE()) - YEAR(students.dob))) AS average_age
FROM university
JOIN campus ON university.university_id = campus.university_id
JOIN students ON campus.campus_id = students.campus_id
GROUP BY university.uni_name
ORDER BY average_age DESC;

-- 3. What is the proportion of students who failed each subject? Provide the subject name, number of students who failed, total number of students, and the proportion of students who failed (as a percentage) for each subject. Display the results in descending order of the proportion of students who failed.

SELECT
    subjects.subj_name AS subject_name,
    SUM(CASE WHEN grades.grades < 5 THEN 1 ELSE 0 END) AS students_failed,
    COUNT(*) AS total_students,
    CONCAT(ROUND((SUM(CASE WHEN grades.grades < 5 THEN 1 ELSE 0 END) / COUNT(*)) * 100, 1), '%') AS proportion_failed
FROM students
	JOIN grades ON students.student_id = grades.student_id
	JOIN subjects ON grades.subject_id = subjects.subject_id
GROUP BY subjects.subj_name
ORDER BY proportion_failed DESC;

-- 4. What is the average grade of students who have done an erasmus compared to those who have not?
SELECT CASE
        WHEN erasmus.agreement_code IS NOT NULL THEN 'Erasmus'
        ELSE 'Not Erasmus'
    END AS erasmus_status,
    AVG(grades.grades) AS average_grade
FROM students
	LEFT JOIN international_agreement AS erasmus ON students.student_id = erasmus.student_id
	LEFT JOIN grades ON students.student_id = grades.student_id
GROUP BY erasmus_status;

-- 5. For each university, identify the number of bachelor’s, master’s and PhD degrees awarded.Provide the university ID and name along with the count for each type of degree.
SELECT university.university_id, university.uni_name AS university_name,
    COUNT(DISTINCT CASE WHEN LEFT(bachelor.bachelor_id, 1) = 'B' THEN bachelor.bachelor_id END) AS bachelor_count,
    COUNT(DISTINCT CASE WHEN LEFT(bachelor.bachelor_id, 1) = 'M' THEN bachelor.bachelor_id END) AS master_count,
    COUNT(DISTINCT CASE WHEN LEFT(bachelor.bachelor_id, 1) = 'D' THEN bachelor.bachelor_id END) AS phd_count
FROM university
LEFT JOIN bachelor ON university.university_id = bachelor.university_id
GROUP BY university.university_id, university.uni_name;

-- 6 Which are the top 5 universities with the highest average ranking over the years? Provide the University ID, University Name, and Average Ranking.
SELECT university.university_id, university.uni_name, 
    ROUND(AVG(ranking.intl_ranking)) AS average_ranking
	FROM ranking
		JOIN university ON university.university_id = ranking.university_id
	GROUP BY university.university_id, university.uni_name
	ORDER BY average_ranking DESC
	LIMIT 5;

-- 7. Provide de id, the name, the last name, the name of the home university and the email of the 10 students that have been on an international agreement more times.

SELECT
    students.student_id AS id,
    students.f_name AS name,
    students.l_name AS "last name",
    MAX(university.uni_name) AS "home university",
    students.email,
    COUNT(international_agreement.student_id) AS agreement_count
FROM students
JOIN international_agreement ON students.student_id = international_agreement.student_id
LEFT JOIN university ON international_agreement.home_university = university.university_id
WHERE students.student_id IN (
    SELECT student_id
    FROM international_agreement)
GROUP BY students.student_id, students.f_name, students.l_name, students.email
ORDER BY agreement_count DESC
LIMIT 10;

-- 8. Make a query where, by modifying the international agreement number, you can identify the id and name of the student who did the exchange, the name of the home university and the name of the city where the exchange took place.

SELECT
    students.student_id AS id,
    CONCAT(students.f_name, ' ', students.l_name) AS student_name,
    university.uni_name AS home_university,
    campus.city AS exchange_city
FROM students
JOIN international_agreement ON students.student_id = international_agreement.student_id
JOIN university ON international_agreement.home_university = university.university_id
JOIN campus ON students.campus_id = campus.campus_id
WHERE international_agreement.agreement_code = '14KK9';

## Bonus: Now you can try to use procedures to parameterize the query. https://learn.microsoft.com/es-es/sql/t-sql/statements/create-procedure-transact-sql?view=sql-server-ver16

-- 9. Find and display the number of universities offering each subject, along with the average grade for each subject.

SELECT
    subjects.subj_name AS subject_name,
    COUNT(DISTINCT university.university_id) AS universities_offering_subject,
    ROUND(AVG(grades.grades)) AS average_grade
FROM subjects
	JOIN uni_subj ON subjects.subject_id = uni_subj.subject_id
	JOIN university ON uni_subj.university_id = university.university_id
	JOIN grades ON subjects.subject_id = grades.subject_id
GROUP BY subjects.subj_name
ORDER BY subject_name ASC;  

-- 10. Find the top 5 cities with the highest percentage of students who have outstanding grades (9 or 10). Provide the city, state, and the percentage of outstanding students for each city.

SELECT
    campus.city AS city,
    campus.state AS state,
    ROUND(SUM(CASE WHEN grades.grades >= 9 THEN 1 ELSE 0 END) / COUNT(*), 2 ) * 100 AS percentage_outstanding
FROM students
JOIN campus ON students.campus_id = campus.campus_id
JOIN grades ON students.student_id = grades.student_id
GROUP BY campus.city, campus.state
HAVING percentage_outstanding IS NOT NULL
ORDER BY percentage_outstanding DESC
LIMIT 5;

-- 11. Compare the universities that send the most students with the universities that receive the most students. Do it in 2 queries.
##first query:
SELECT
    away_university AS university_id,
    uni_name AS university_name,
    COUNT(DISTINCT student_id) AS students_received
FROM international_agreement
JOIN university ON international_agreement.away_university = university.university_id
GROUP BY away_university
ORDER BY students_received DESC
LIMIT 10;

#second query: 
SELECT
    home_university AS university_id,
    uni_name AS university_name,
    COUNT(DISTINCT student_id) AS students_sent
FROM international_agreement
JOIN university ON international_agreement.home_university = university.university_id
GROUP BY home_university
ORDER BY students_sent DESC
LIMIT 10;

## Bonus: Now you can try to join both queries by using “UNION ALL” operator.


-- 12. Create a CTE that lists all students who have not signed any international agreements. Include the columns student_id, f_name, and l_name. Then, write a query to select all the rows from the CTE.

-- 13. Write a SQL query to rank universities based on their international ranking for the year 2022 in descending order. Include the following columns in the result: uni_name, intl_ranking, and the rank assigned using the window function.

-- 14. Write a query to find the students who have the highest and lowest grades for each subject. Include the columns subject_id, subj_name, student_id, f_name, l_name, and grades. Use window functions to rank the students within each subject based on their grades.

-- 15. Create a CTE that calculates the total number of subjects offered by each university. Include the columns uni_name and total_subjects. Then, write a query to select all the rows from the CTE in descending order of total subjects.
