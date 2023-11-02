USE ERASMUSDEF; 

-- 1. 
SELECT 
		case
			when grades.grades >= 9 then 'EXCELLENT'
            when grades >= 7 then 'GOOD'
            when grades >= 5 then 'PASS'
            else 'FAIL'
		end as Grade_Category,
	round(avg(datediff(curdate(), students.dob) / 365)) as Average_Age
	from students
	join grades on students.student_id = grades.student_id
	group by Grade_Category
    HAVING Grade_Category = "EXCELLENT";
		
-- 2. 

SELECT UNIVERSITY.UNI_NAME AS university_name, round(avg(datediff(curdate(), students.dob) / 365)) as Average_Age
FROM STUDENTS
JOIN CAMPUS ON STUDENTS.CAMPUS_ID = CAMPUS.CAMPUS_ID
JOIN UNIVERSITY ON CAMPUS.UNIVERSITY_ID = UNIVERSITY.UNIVERSITY_ID
GROUP BY  university_name; 


-- 3. 

SELECT 
  subjects.subj_name,
  COUNT(CASE WHEN grades < 5 THEN 1 ELSE NULL END) as num_failed,
  COUNT(grades.student_id) as total_students,
  (COUNT(CASE WHEN grades < 5 THEN 1 ELSE NULL END) / COUNT(*)) * 100 as proportion_failed
FROM grades
JOIN subjects on grades.subject_id = subjects.subject_id
GROUP BY 
  subjects.subj_name
ORDER BY 
  proportion_failed DESC;

 
-- 4. 

select
        'Erasmus' AS Erasmus_Status,
        round(avg(grades.grades), 2) AS Avg_Grades
    from grades
    JOIN students ON grades.student_id = students.student_id
    JOIN international_agreement ON students.student_id = international_agreement.student_id
    union all
    select
        'Non-Erasmus' as Erasmus_Status,
        round(avg(grades.grades), 2) as Avg_Grades
    from grades
    left join students on grades.student_id = students.student_id
    left join international_agreement on students.student_id = international_agreement.student_id
    where international_agreement.student_id is null;
        

    
-- 5. 

 SELECT university.university_id, university.uni_name,
    COUNT(CASE WHEN LEFT(bachelor.bachelor_id, 1) = 'B' THEN 1 END) AS Bachelor_Count,
    COUNT(CASE WHEN LEFT(bachelor.bachelor_id, 1) = 'M' THEN 1 END) AS Master_Count,
    COUNT(CASE WHEN LEFT(bachelor.bachelor_id, 1) = 'D' THEN 1 END) AS PHD_Count
FROM bachelor
    JOIN university ON bachelor.university_id = university.university_id
    GROUP BY university.university_id;
        



