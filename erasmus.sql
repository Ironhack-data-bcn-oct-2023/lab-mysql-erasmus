USE erasmus;

-- 1 What is the average age of students who have outstanding grades? Provide the table with EXCELLENT if they have a 9 or 10, 
-- GOOD if they have 7 or 8, PASS if they have a 5 or 6, and FAIL if it is less than 5.

SELECT 
    CASE 
        WHEN grades > 8 THEN 'EXCELLENT'
        WHEN grades > 6 THEN 'GOOD'
        WHEN grades >= 5 THEN 'PASS'
        ELSE 'FAIL'
    END as grade_category,
round(AVG(DATEDIFF(NOW(), dob)/365)) AS AGE
FROM students
join grades ON students.student_id = grades.student_id
GROUP BY grade_category;

-- 2 What is the average age of students by university?

SELECT uni_name, round(AVG(DATEDIFF(NOW(), dob)/365)) AS avg_age
FROM students
JOIN campus ON students.campus_id = campus.campus_id
JOIN university ON campus.university_id = university.university_id
GROUP BY university.uni_name
ORDER BY avg_age DESC;


-- 3 What is the proportion of students who failed each subject? Provide the subject name, number of students who failed, 
-- total number of students, and the proportion of students who failed (as a percentage) for each subject. 
-- Display the results in descending order of the proportion of students who failed.

SELECT subj_name,
	COUNT(grades.student_id) AS number_students,
    COUNT(CASE WHEN grades < 5 THEN 1 END) AS students_failed,
    ROUND(COUNT(CASE WHEN grades < 5 THEN 1 END) * 100.0 / COUNT(*),2) AS failed_proportion
FROM grades
JOIN subjects ON grades.subject_id = subjects.subject_id
GROUP BY subj_name
ORDER BY failed_proportion DESC;

-- 4 What is the average grade of students who have done an erasmus compared to those who have not?

SELECT 'Erasmus' AS Erasmus_Status,
ROUND(AVG(grades.grades), 2) AS Avg_Grades
FROM grades
JOIN students ON grades.student_id = students.student_id
JOIN international_agreement ON students.student_id = international_agreement.student_id
UNION ALL
SELECT 'Non-Erasmus' AS Erasmus_Status,
ROUND(AVG(grades.grades), 2) AS Avg_Grades
FROM grades
LEFT JOIN students ON grades.student_id = students.student_id
left join international_agreement on students.student_id = international_agreement.student_id
WHERE international_agreement.student_id IS NULL;

-- 5 For each university, identify the number of bachelor’s, master’s and PhD degrees awarded.
-- Provide the university ID and name along with the count for each type of degree.

SELECT uni_name, university.university_id,
    COUNT(CASE WHEN LEFT(bachelor_id, 1) = 'B' THEN 1 END) AS n_bachelor,
    COUNT(CASE WHEN LEFT(bachelor_id, 1) = 'M' THEN 1 END) AS n_master,
    COUNT(CASE WHEN LEFT(bachelor_id, 1) = 'D' THEN 1 END) AS n_phd
FROM bachelor
    JOIN university ON bachelor.university_id = university.university_id
    GROUP BY university.university_id;

