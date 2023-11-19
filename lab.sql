use erasmus;

-- 1. What is the average age of students who have outstanding grades? Provide the table with EXCELLENT if they have 
-- a 9 or 10, GOOD if they have 7 or 8, PASS if they have a 5 or 6, and FAIL if it is less than 5.
	select 
		case
			when grades >= 9 then 'EXCELLENT'
            when grades >= 7 then 'GOOD'
            when grades >= 5 then 'PASS'
            else 'FAIL'
		end as Grade_Category,
	round(avg(datediff(curdate(), students.dob) / 365)) as Average_Age
	from students
	join grades on students.student_id = grades.student_id
	group by Grade_Category
    having Grade_Category = 'EXCELLENT';

-- 2. What is the average age of students by university?
	select u.uni_name as university_name, round(avg(datediff(curdate(), s.dob) / 365)) as average_age
    from students as s
		join campus as c on s.campus_id = c.campus_id
        join university as u on c.university_id = u.university_id
		group by university_name
        order by average_age desc;

-- 3. What is the proportion of students who failed each subject? Provide the subject name, number of students who failed,
-- total number of students, and the proportion of students who failed (as a percentage) for each subject.
-- Display the results in descending order of the proportion of students who failed.
	select subj_name,
		count(grades.student_id) as number_students,
		count(case when grades < 5 then 1 end) as students_failed,
		round(count(case when grades < 5 then 1 end) * 100.0 / COUNT(*), 2) as failed_proportion
	from grades
	JOIN subjects ON grades.subject_id = subjects.subject_id
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

-- 5. For each university, identify the number of bachelor’s, master’s and PhD degrees awarded.Provide the university ID
-- and name along with the count for each type of degree.
	select university.university_id, university.uni_name,
		count(case when left(bachelor.bachelor_id, 1) = 'B' then 1 end) as Count_Bachelor,
		count(case when left(bachelor.bachelor_id, 1) = 'M' then 1 end) as Count_Master,
		count(case when left(bachelor.bachelor_id, 1) = 'D' then 1 end) as Count_PHD
	from bachelor
		join university on bachelor.university_id = university.university_id
		group by university.university_id;

-- 6. Which are the top 5 universities with the highest average ranking over the years? Provide the University ID, University
-- Name, and Average Ranking.

-- 7. Provide de id, the name, the last name, the name of the home university and the email of the 10 students that have been
-- on an international agreement more times.

-- 8. Provide de id, the name, the last name, the name of the home university and the email of the 10 students that have been
-- on an international agreement more times.

-- 9. Find and display the number of universities offering each subject, along with the average grade for each subject.

-- 10. ind the top 5 cities with the highest percentage of students who have outstanding grades (9 or 10). Provide the city,
-- state, and the percentage of outstanding students for each city.

-- 11. Compare the universities that send the most students with the universities that receive the most students.
-- Do it in 2 queries. Alt text Bonus: Now you can try to join both queries by using “UNION ALL” operator. 

-- 12. Create a CTE that lists all students who have not signed any international agreements. Include the columns student_id,
-- f_name, and l_name. Then, write a query to select all the rows from the CTE.

-- 13. Write a SQL query to rank universities based on their international ranking for the year 2022 in descending order.
-- Include the following columns in the result: uni_name, intl_ranking, and the rank assigned using the window function.

-- 14. Write a query to find the students who have the highest and lowest grades for each subject. Include the columns
-- subject_id, subj_name, student_id, f_name, l_name, and grades. Use window functions to rank the students within each
-- subject based on their grades.

-- 15. Write a query to find the students who have the highest and lowest grades for each subject. Include the columns subject_id,
-- subj_name, student_id, f_name, l_name, and grades. Use window functions to rank the students within each subject based on their
-- grades.