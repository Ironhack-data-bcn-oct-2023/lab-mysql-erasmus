USE erasmus;

-- What is the average age of students who have outstanding grades?
-- Provide the table with EXCELLENT if they have a 9 or 10, GOOD if they have 7 or 8, PASS if they have a 5 or 6, and FAIL if it is less than 5.

SELECT DISTINCT grade_category, round(AVG(age)) as average_age
	FROM (SELECT
	CASE
		WHEN grades >= 9 THEN "EXCELLENT"
        WHEN grades < 9 AND grades >= 7 THEN "GOOD"
        WHEN grades < 7 AND grades >= 5 THEN "PASS"
        WHEN grades < 5 THEN "FAIL"
	END AS grade_category,
    DATEDIFF(CURDATE(), dob) / 365 AS age
    FROM grades
    JOIN students ON grades.student_id = students.student_id
    ) as join_table
    GROUP BY grade_category;

-- What is the average age of students by university?  
-- THE FOLLOWING CODE DOES NOT RETURN ANY LINES, CAN'T FIGURE OUT THE ERROR

SELECT university.uni_name as university_name , ROUND(AVG(DATEDIFF(CURDATE(), students.dob) / 365)) AS average_age
FROM students
	JOIN campus
		ON students.campus_id = campus.campus_id
			JOIN university
				ON campus.university_id = university.university_id
GROUP BY university_name;


-- What is the proportion of students who failed each subject? Provide the subject name, number of students who failed, total number of students, 
-- and the proportion of students who failed (as a percentage) for each subject. 
-- Display the results in descending order of the proportion of students who failed.

SELECT
    subjects.subj_name AS subject_name,
    SUM(CASE 
    WHEN grades.grades < 5 THEN 1 
    ELSE 0 
    END) AS students_failed,
    COUNT(*) AS total_students,
    CONCAT(ROUND((SUM(CASE WHEN grades.grades < 5 THEN 1 ELSE 0 END) / COUNT(*)) * 100, 1), '%') AS proportion_failed
FROM students
	JOIN grades ON students.student_id = grades.student_id
	JOIN subjects ON grades.subject_id = subjects.subject_id
GROUP BY subjects.subj_name
ORDER BY proportion_failed DESC;


-- What is the average grade of students who have done an erasmus compared to those who have not?

SELECT
    ROUND(AVG(CASE WHEN international_agreement.student_id IS NOT NULL THEN grades.grades END), 2) AS AvgGrade_Erasmus,
    ROUND(AVG(CASE WHEN international_agreement.student_id IS NULL THEN grades.grades END), 2) AS AvgGrade_NonErasmus
FROM grades
    LEFT JOIN students  ON grades.student_id = students.student_id
        LEFT JOIN   international_agreement ON students.student_id = international_agreement.student_id;
        
-- For each university, identify the number of bachelor’s, master’s and PhD degrees awarded.Provide the university ID and name along with the count for each type of degree.

SELECT university.university_id, university.uni_name AS university_name,
    COUNT(DISTINCT CASE WHEN LEFT(bachelor.bachelor_id, 1) = 'B' THEN bachelor.bachelor_id END) AS bachelor_count,
    COUNT(DISTINCT CASE WHEN LEFT(bachelor.bachelor_id, 1) = 'M' THEN bachelor.bachelor_id END) AS master_count,
    COUNT(DISTINCT CASE WHEN LEFT(bachelor.bachelor_id, 1) = 'D' THEN bachelor.bachelor_id END) AS phd_count
FROM university
LEFT JOIN bachelor ON university.university_id = bachelor.university_id
GROUP BY university.university_id, university.uni_name;