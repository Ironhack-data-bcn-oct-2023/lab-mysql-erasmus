USE erasmus;


-- 1. What is the average age of students who have outstanding grades? Provide the table with EXCELLENT if they have a 9 or 10, GOOD if they have 7 or 8, PASS if they have a 5 or 6, and FAIL if it is less than 5.
-- grades -- students
-- greades -- student_id


SELECT
	CASE 
		WHEN grades.grades BETWEEN 9 AND 10 THEN 'Excellent'
        WHEN grades.grades BETWEEN 7 AND 8 THEN 'GOOD'
        WHEN grades.grades BETWEEN 5 AND 6 THEN 'PASS'
        ELSE 'FAIL'
        END as Performance, 
        ROUND(avg(YEAR(now()) - YEAR(dob))) as avgAge

FROM students 
	JOIN grades ON students.student_id = grades.student_id
    GROUP BY Performance
    ORDER BY avgAge DESC;
    
-- 2. What is the average age of students by university?
-- university: university_id, uni_name, tuition_per_credit
-- students: student_id, f_name, l_name, dob, address, city, state, language_1, language_2, phone_no, zip, email, campus_id
-- international agreement: agreement_code, home_university(= university_id), away_university(=univiersity_id), student_id

SELECT ROUND(avg(YEAR(now()) - YEAR(dob))) as avgAge, university.uni_name FROM students
	JOIN campus ON students.campus_id = campus.campus_id
		JOIN university ON campus.university_id = university.university_id
			GROUP BY university.uni_name
            ORDER BY avgage DESC;
  
            
-- 3. What is the proportion of students who failed each subject? Provide the subject name, number of students who 
-- failed, total number of students, and the proportion of students who failed (as a percentage) for each subject. 
-- Display the results in descending order of the proportion of students who failed.
-- Subject: subject_id, subj_name, credits
-- students: student_id, f_name, l_name, dob, address, city, state, language_1, language_2, phone_no, zip, email, campus_id
-- grades: student_id, subject_id, grades

-- students, subject
-- SELECT % Students (Failed) 


SELECT 
subj_name,  
COUNT(CASE WHEN grades < 5 THEN 1 END) AS count_failed, 
ROUND ((COUNT(CASE WHEN grades < 5 THEN 1 END)/COUNT(*))*100, 2) as failed_perc,
count(*) As All_Student FROM grades
JOIN subjects ON grades.subject_id = subjects.subject_id
	GROUP BY subjects.subj_name
		ORDER BY failed_perc DESC;

-- 4. What is the average grade of students who have done an erasmus compared to those who have not?
    -- students: student_id, f_name, l_name, dob, address, city, state, language_1, language_2, phone_no, zip, email, campus_id
    -- grades: student_id, subject_id, grades
    -- international agreement: agreement_code, home_university(= university_id), away_university(=univiersity_id), student_id



SELECT
    ROUND(AVG(CASE WHEN international_agreement.student_id IS NOT NULL THEN grades.grades END), 2) AS AvgGrade_Erasmus,
    ROUND(AVG(CASE WHEN international_agreement.student_id IS NULL THEN grades.grades END), 2) AS AvgGrade_NonErasmus
FROM grades 
	LEFT JOIN students  ON grades.student_id = students.student_id
		LEFT JOIN 	international_agreement ON students.student_id = international_agreement.student_id;
	
-- 5. For each university, identify the number of bachelor’s, 
-- master’s and PhD degrees awarded.Provide the university ID and name along with the count for each type of degree.
	-- university: university_id, uni_name, tuition_per_credit
	-- bachelor: bachelor_id, bachelor_name, university_id, no_semesters, total_min_credits
    -- bachelor_id (B001 = Bachelor, M017 = Master , D012 = PHD)


SELECT university.university_id, university.uni_name,
    COUNT(CASE WHEN LEFT(bachelor.bachelor_id, 1) = 'B' THEN 1 END) AS COUNT_Bachelor,
	COUNT(CASE WHEN LEFT(bachelor.bachelor_id, 1) = 'M' THEN 1 END) AS COUNT_Master,
	COUNT(CASE WHEN LEFT(bachelor.bachelor_id, 1) = 'D' THEN 1 END) AS COUNT_PHD
FROM bachelor
	JOIN university ON bachelor.university_id = university.university_id
    GROUP BY university.university_id;

-- 6. Which are the top 5 universities with the highest average ranking over the years? 
-- Provide the University ID, University Name, and Average Ranking.
	-- ranking: intl_ranking, year_ranking, university_id
	-- university: university_id, uni_name, tuition_per_credit
SELECT university.university_id, university.uni_name,avg(intl_ranking) as avg_ranking
FROM ranking
	JOIN university ON ranking.university_id = university.university_id
		GROUP BY university.university_id
			ORDER BY avg_ranking DESC
				LIMIT 5;

-- 7. Provide the id, the name, the last name, the name of the home university 
-- and the email of the 10 students that have been on an international agreement more times.
    -- international_agreement: agreement_code, home_university(= university_id), away_university(=univiersity_id), student_id
    -- students: student_id, f_name, l_name, dob, address, city, state, language_1, language_2, phone_no, zip, email, campus_id

SELECT students.student_id, students.f_name, students.l_name, students.email, 
international_agreement.home_university,  
COUNT(international_agreement.agreement_code) AS num_agreements
FROM international_agreement
JOIN students ON international_agreement.student_id = students.student_id
GROUP BY students.student_id, students.f_name, students.l_name, students.email, international_agreement.home_university
ORDER BY num_agreements DESC LIMIT 10;

-- 8. Make a query where, by modifying the international agreement number, you can identify the id and name of the student 
-- who did the exchange, the name of the home university and the name of the city where the exchange took place.
    -- international_agreement: agreement_code, home_university(= university_id), away_university(=univiersity_id), student_id
    -- students: student_id, f_name, l_name, dob, address, city, state, language_1, language_2, phone_no, zip, email, campus_id
    -- campus: campus_id, campus_name, university_id, city, state
	-- university: university_id, uni_name, tuition_per_credit

    
SELECT students.student_id, CONCAT(students.f_name, ' ', students.l_name) AS student_name, 
    university.uni_name AS home_university, 
    campus.city AS city_of_exchange
FROM international_agreement 
JOIN students students ON international_agreement.student_id = students.student_id
JOIN university  ON international_agreement.home_university = university.university_id
JOIN campus ON campus.campus_id = students.campus_id
WHERE international_agreement.agreement_code= '14KK9';

-- 9. Find and display the number of universities offering each subject, along with the average grade for each subject.
	-- university: university_id, uni_name, tuition_per_credit
	-- uni_subj: university_id, subject_id
	-- subjects: `subjects`.`subject_id`, `subjects`.`subj_name`, `subjects`.`credits`
    -- grades: student_id, subject_id, grades

SELECT subjects.subject_id, subjects.subj_name,
    COUNT(university.uni_name) AS num_universities_offering,
    AVG(grades.grades) AS average_grade
FROM subjects
JOIN uni_subj ON subjects.subject_id = uni_subj.subject_id
	JOIN university ON uni_subj.university_id = university.university_id
		JOIN grades ON subjects.subject_id = grades.subject_id
			GROUP BY subjects.subject_id, subjects.subj_name
			ORDER BY subjects.subject_id;
            
-- 10. Find the top 5 cities with the highest percentage of students who have outstanding grades (9 or 10). Provide the city, state, and the percentage of outstanding students for each city.
    -- grades: student_id, subject_id, grades
    -- students: student_id, f_name, l_name, dob, address, city, state, language_1, language_2, phone_no, zip, email, campus_id
    -- campus: campus_id, campus_name, university_id, city, state

SELECT
    os_inner.city,
    os_inner.state,
    ROUND((os_inner.outstanding_count * 100.0) / NULLIF(os_inner.total_count, 0), 2) AS percentage_outstanding
FROM
    (SELECT
        students.city,
        students.state,
        SUM(CASE WHEN grades.grades >= 9 THEN 1 ELSE 0 END) AS outstanding_count,
        COUNT(*) AS total_count
    FROM
        students
    LEFT JOIN
        grades
        ON students.student_id = grades.student_id
    GROUP BY
        students.city, students.state) AS os_inner
ORDER BY
    percentage_outstanding DESC
LIMIT 5;


        


