USE erasmus;

-- 1
SELECT Grade_Category, FLOOR(AVG(age)) FROM 
(SELECT grades.student_id, TIMESTAMPDIFF(YEAR,dob,CURDATE()) AS age, 
		CASE
			WHEN grades>8 THEN "EXCELLENT"
            WHEN grades<9 AND grades>6 THEN "GOOD"
            WHEN grades<7 AND grades>4 THEN "PASS"
            ELSE "FAIL"
        END AS Grade_Category
FROM grades JOIN students ON grades.student_id = students.student_id) as tab
GROUP BY Grade_Category;


-- 2
SELECT University_name, FLOOR(AVG(age)) AS average_age FROM
(SELECT uni_name AS University_name, (TIMESTAMPDIFF(YEAR,dob,CURDATE())) AS age
FROM university JOIN campus ON university.university_id = campus.university_id
				JOIN students ON campus.campus_id = students.campus_id) as tab
GROUP BY University_name
ORDER BY average_age DESC;


-- 3
SELECT subj_name, students_failed, total_students, (students_failed * 100 / total_students) as proportion_failed
FROM ( SELECT subjects.subj_name,
			   SUM(CASE WHEN grades.grades < 5 THEN 1 ELSE 0 END) AS students_failed,
			  COUNT(*) AS total_students
FROM students
	JOIN grades ON students.student_id = grades.student_id
	JOIN subjects ON grades.subject_id = subjects.subject_id
GROUP BY subjects.subj_name) as tab
GROUP BY subj_name
ORDER BY proportion_failed DESC;


-- 4
SELECT CASE
			WHEN erasmus.agreement_code IS NOT NULL THEN 'w_erasmus' ELSE 'wo_erasmus'
	   END AS erasmus_status,
	   AVG(grades.grades) AS average_grade
FROM students LEFT JOIN international_agreement ON students.student_id = international_agreement.student_id
			  JOIN grades ON students.student_id = grades.student_id
GROUP BY erasmus_status;


-- 5
SELECT * FROM bachelor;

SELECT university.university_id, university.uni_name,
    COUNT(CASE WHEN bachelor.bachelor_id LIKE 'b%' THEN bachelor.bachelor_id END) AS bachelor_count,
    COUNT(CASE WHEN bachelor.bachelor_id LIKE 'M%' THEN bachelor.bachelor_id END) AS master_count,
    COUNT(CASE WHEN bachelor.bachelor_id LIKE 'D%' THEN bachelor.bachelor_id END) AS phd_count
FROM university
LEFT JOIN bachelor ON university.university_id = bachelor.university_id
GROUP BY university.university_id, university.uni_name;

SELECT 'B001' LIKE 'm%'





