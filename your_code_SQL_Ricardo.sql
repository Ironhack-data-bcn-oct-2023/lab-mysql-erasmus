use erasmus;

-- 1. What is the average age of students who have outstanding grades? 
-- Provide the table with EXCELLENT if they have a 9 or 10, GOOD if they have 7 or 8, 
-- PASS if they have a 5 or 6, and FAIL if it is less than 5. 

select * from grades;
-- first let's get the age:
select student_id, floor(datediff(now(),dob)/365) as Age from students;

-- now let's cluster the grades:
SELECT grades.student_id, grades.grades,
IF(grades.grades < 5, 'FAIL', IF(grades.grades < 7, 'PASS', IF(grades.grades < 9, 'GOOD', 'EXCELLENT'))) AS grade_category
FROM grades;

-- Putting it all together:
SELECT grade_category, AVG(age_students.Age) AS Average_Age FROM 
	(SELECT grades.student_id, grades.grades,
	IF(grades.grades < 5, 'FAIL', IF(grades.grades < 7, 'PASS', IF(grades.grades < 9, 'GOOD', 'EXCELLENT'))) AS grade_category
	FROM grades) AS clusters_of_grades
	JOIN 
    (select student_id, floor(datediff(now(),dob)/365) as Age from students) AS age_students
	ON clusters_of_grades.student_id = age_students.student_id
GROUP BY grade_category;


-- 2. What is the average age of students by university?
-- students and university tables related by campus_id and then joined to University via university_id
-- first let's get the age:
select student_id, floor(datediff(now(),dob)/365) as Age, campus_id from students;
 
-- the common denominator is gonna be the campus_id. I'm gonna link my age_calc subquery using it
select campus_name as university_name, avg(Age) as average_age from campus
join (select student_id, floor(datediff(now(),dob)/365) as Age, campus_id from students) as age_calc
on 
campus.campus_id = age_calc.campus_id
group by university_name
order by average_age DESC;
    

-- 3. What is the proportion of students who failed each subject? Provide the subject name, 
-- number of students who failed, total number of students, 
-- and the proportion of students who failed (as a percentage) for each subject. 
-- Display the results in descending order of the proportion of students who failed.

-- reusing the code from the 1st question with some extra spice I'm getting the names of the siubjects
SELECT subj_name as Subject_name, SUM(if(grade_category = 'FAIL', 1,0)) AS num_fail, SUM(if(grade_category <> 'FAIL',1,0)) AS num_non_fail
from
(select grades.student_id, grades.grades, grades.subject_id, subj_name,
IF(grades.grades < 5, 'FAIL', IF(grades.grades < 7, 'PASS', IF(grades.grades < 9, 'GOOD', 'EXCELLENT'))) AS grade_category
FROM grades 
join subjects on grades.subject_id = subjects.subject_id) as grade_categories
group by Subject_name;


-- now I want instead of the passed students, the total count and then I want the % of failures:
SELECT subj_name as Subject_name, SUM(if(grade_category = 'FAIL', 1,0)) AS Number_of_failures, count(grade_category) AS Number_of_students
from
(select grades.student_id, grades.grades, grades.subject_id, subj_name,
IF(grades.grades < 5, 'FAIL', IF(grades.grades < 7, 'PASS', IF(grades.grades < 9, 'GOOD', 'EXCELLENT'))) AS grade_category
FROM grades 
join subjects on grades.subject_id = subjects.subject_id) as grade_categories
group by Subject_name;

-- reusing this code, to call it as a subquery and reuse it
SELECT Subject_name, SUM(Number_of_failures) AS Number_of_failures, SUM(Number_of_students) AS Number_of_students, 
    (SUM(Number_of_failures) / SUM(Number_of_students)) * 100 AS Proportion_of_Failures
FROM (SELECT subj_name as Subject_name, SUM(IF(grade_category = 'FAIL', 1, 0)) AS Number_of_failures, COUNT(grade_category) AS Number_of_students
    FROM (SELECT grades.student_id, grades.grades, grades.subject_id, subj_name,
    IF(grades.grades < 5, 'FAIL', IF(grades.grades < 7, 'PASS', IF(grades.grades < 9, 'GOOD', 'EXCELLENT'))) AS grade_category
	FROM grades 
	JOIN subjects ON grades.subject_id = subjects.subject_id) AS grade_categories
    GROUP BY Subject_name) AS summary -- this is the previous code of block
GROUP BY Subject_name;  


-- 4. What is the average grade of students who have done an erasmus compared to those who have not?

select * from international_agreement;

SELECT
    IF(International_agreement.student_id IS NOT NULL, 'w_erasmus', 'wo_erasmus') AS Erasmus_Status,
    AVG(grades.grades) AS Average_Grades
FROM grades -- I'm basically running through the entries in the grades list and check if those  student_ids are in the Intern.Agr table, if so, it's w_erasmus
LEFT JOIN
    International_agreement ON grades.student_id = International_agreement.student_id
GROUP BY
    Erasmus_Status;
    
    
-- 5. For each university, identify the number of bachelor’s, 
-- master’s and PhD degrees awarded. 
-- Provide the university ID and name along with the count for each type of degree.
select * from bachelor;
SELECT COUNT(*) AS Bachelor_count FROM bachelor WHERE bachelor_id LIKE 'B%';

SELECT university.university_id,
       campus.campus_name AS uni_name,
       SUM(CASE WHEN bachelor_id LIKE 'B%' THEN 1 ELSE 0 END) AS Bachelor_count,
       SUM(CASE WHEN bachelor_id LIKE 'M%' THEN 1 ELSE 0 END) AS Masters_count,
       SUM(CASE WHEN bachelor_id LIKE 'D%' THEN 1 ELSE 0 END) AS Phd_count
FROM bachelor
JOIN university ON bachelor.university_id = university.university_id
JOIN campus ON university.university_id = campus.university_id
GROUP BY university.university_id, campus.campus_id;

-- 6. Which are the top 5 universities with the highest average ranking over the years? Provide the University ID, University Name, and Average Ranking.
select university.university_id, avg(intl_ranking) as Average_ranking, uni_name as University_Name from ranking
join university on ranking.university_id = university.university_id
group by university_id
order by Average_ranking DESC
limit 5;

-- 7. Provide de id, the name, the last name, 
-- the name of the home university and the email of the 10 students that have been on an international agreement more times.
select count(student_id) as Agreement_count, student_id from international_agreement
	group by student_id
    order by Agreement_count DESC
    limit 10; -- these are the top 10 most international homies/dudettes

SELECT students.student_id, students.f_name, students.l_name, top_students.home_university, students.email, top_students.Agreement_count
FROM students
JOIN (SELECT ia.student_id, MAX(ia.home_university) AS home_university, COUNT(ia.student_id) AS Agreement_count
    FROM international_agreement AS ia
    GROUP BY ia.student_id
    ORDER BY Agreement_count DESC
    LIMIT 10) AS top_students
ON students.student_id = top_students.student_id;


-- 8. Make a query where, by modifying the international agreement number, you can identify the id and name of 
-- the student who did the exchange, the name of the home university and the name of the city where the exchange took place.

-- not super sure I understood this one, I'm retrieving the people who went on international programs basically :(
SELECT international_agreement.agreement_code AS agreement_code, students.student_id AS student_id, students.f_name AS Student_first_name,
		students.l_name AS Student_last_name, university_home.uni_name AS Home_university, university_away.uni_name AS Away_university
FROM international_agreement
JOIN students ON international_agreement.student_id = students.student_id
JOIN university AS university_home ON international_agreement.home_university = university_home.university_id
JOIN university AS university_away ON international_agreement.away_university = university_away.university_id;


-- 9. Find and display the number of universities offering each subject, along with the average grade for each subject.
select avg(grades), subj_name, subjects.subject_id from grades
join subjects on grades.subject_id = subjects.subject_id
group by subject_id;

SELECT subjects.subject_id, subjects.subj_name, AVG(grades.grades) AS average_grade, COUNT(DISTINCT uni_subj.university_id) AS Num_universidades
FROM subjects
JOIN grades ON subjects.subject_id = grades.subject_id
JOIN uni_subj ON subjects.subject_id = uni_subj.subject_id
GROUP BY subjects.subject_id, subjects.subj_name;

-- 10. Find the top 5 cities with the highest percentage of students who have outstanding 
-- grades (9 or 10). Provide the city, state, and the percentage of outstanding students for each city. 
select count(if(grades.grades >=9,1,0)), campus.city, campus.state from grades
join students on grades.student_id = students.student_id
join campus on students.campus_id = campus.campus_id
group by campus.city;

WITH CityStats AS (SELECT campus.city, campus.state, SUM(IF(grades.grades >= 9, 1, 0)) AS outstanding_count, COUNT(*) AS total_students
    FROM grades
    JOIN students ON grades.student_id = students.student_id
    JOIN campus ON students.campus_id = campus.campus_id
    GROUP BY campus.city, campus.state)
    SELECT city, state, (outstanding_count / total_students * 100) AS percentage_outstanding FROM CityStats
ORDER BY percentage_outstanding DESC
LIMIT 5;



