use erasmus;
SELECT * FROM erasmus.students;
 
 -- 1. What is the average age of students who have outstanding grades? 
	-- Provide the table with EXCELLENT if they have a 9 or 10, 
    -- GOOD if they have 7 or 8, 
    -- PASS if they have a 5 or 6, and 
    -- FAIL if it is less than 5.
    
SELECT 
	CASE 
		WHEN grades > 8 THEN 'EXCELLENT'
		WHEN grades > 6 THEN 'GOOD'
		WHEN grades >= 5 THEN 'PASS'
		ELSE 'FAIL'
	END as grade_category,
round(AVG(DATEDIFF(curdate(), dob)/365)) AS AGE
FROM students
join grades ON students.student_id = grades.student_id
GROUP BY grade_category;

	-- 2. What is the average age of students by university?
    
    select uni_name, (avg(year(curdate()) - year(dob)))as avg_age
from students
join campus
on students.campus_id = campus.campus_id
join university
on campus.university_id = university.university_id
group by university.uni_name
order by avg_age desc;
    
    
	-- 3.	-- What is the proportion of students who failed each subject? 
			-- Provide the subject name, number of students who failed, total number of students, 
			-- and the proportion of students who failed (as a percentage) for each subject. 
			-- Display the results in descending order of the proportion of students who failed.
	
    SELECT 
    subjects.subj_name,
    COUNT(grades.student_id) as number_of_students,
    COUNT(CASE WHEN grades <5 THEN 1 END) AS students_failed,
    ROUND((COUNT(CASE WHEN grades < 5 THEN 1 END)) * 100.0 / COUNT(*), 2) AS failed_proportion
    FROM grades
    JOIN subjects on grades.subject_id = subjects.subject_id
    GROUP BY subj_name
    ORDER BY failed_proportion DESC;
    
    -- 4. What is the average grade of students who have done an erasmus compared to those who have not?
    
   select
        'Erasmus' as Erasmus_Status,
        round(avg(grades.grades), 2) as Avg_Grades
    from grades
    join students on grades.student_id = students.student_id
    join international_agreement on students.student_id = international_agreement.student_id
    union all
    select
        'Non-Erasmus' as Erasmus_Status,
        round(avg(grades.grades), 2) as Avg_Grades
    from grades
    left join students on grades.student_id = students.student_id
    left join international_agreement on students.student_id = international_agreement.student_id
    where international_agreement.student_id is null;
	
    -- 5. For each university, identify the number of bachelor’s, master’s and PhD degrees awarded.
		-- Provide the university ID and name along with the count for each type of degree.
        
	SELECT university.university_id, university.uni_name,
    COUNT(CASE WHEN LEFT(bachelor.bachelor_id, 1) = 'B' THEN 1 END) AS COUNT_Bachelor,
    COUNT(CASE WHEN LEFT(bachelor.bachelor_id, 1) = 'M' THEN 1 END) AS COUNT_Master,
    COUNT(CASE WHEN LEFT(bachelor.bachelor_id, 1) = 'D' THEN 1 END) AS COUNT_PHD
FROM bachelor
    JOIN university ON bachelor.university_id = university.university_id
    GROUP BY university.university_id;
    
    
    
    
    

