SELECT  retirement_info.emp_no,
		retirement_info.first_name,
		retirement_info.last_name,
		titles.title,
		titles.from_date,
		Salaries.salary
INTO partone
FROM retirement_info
    INNER JOIN salaries
        ON (retirement_info.emp_no = salaries.emp_no)
    INNER JOIN titles
        ON (retirement_info.emp_no = titles.emp_no);

--remove old titles
DELETE FROM partone
WHERE from_date IN (
    SELECT
        from_date
    FROM (
        SELECT
            from_date,
            ROW_NUMBER() OVER w AS rnum
        FROM partone
        WINDOW w AS (
            PARTITION BY first_name, last_name
            ORDER BY from_date
        )
 
    ) t
WHERE t.rnum > 1);
  
--sanity check table for dupes
SELECT
    first_name, last_name, COUNT(*)
FROM
    partone
GROUP BY
    first_name,last_name
HAVING 
    COUNT(*) > 1
	
--partone title aggregation
SELECT COUNT(partone.emp_no), partone.title
INTO partone_title_agg
FROM partone
GROUP BY partone.title;

--Who ready for mentor w/o current
SELECT emp_no, first_name, last_name
INTO mentee_info
FROM employees
WHERE (birth_date BETWEEN '1965-01-01' AND '1965-12-31');

-- Joining metnee ifo and dept_emp tables
SELECT mentee_info.emp_no,
	mentee_info.first_name,
	mentee_info.last_name,
	dept_emp.to_date,
	dept_emp.from_date
INTO current_mentee_no_titles
FROM mentee_info
	INNER JOIN dept_emp
		ON (mentee_info.emp_no = dept_emp.emp_no)
		WHERE (dept_emp.to_date = ('9999-01-01'));

--adding titles
SELECT current_mentee_no_titles.emp_no,
	current_mentee_no_titles.first_name,
	current_mentee_no_titles.last_name,
	current_mentee_no_titles.to_date,
	current_mentee_no_titles.from_date,
	titles.title
INTO current_mentee_titles
FROM current_mentee_no_titles
	INNER JOIN titles
		ON (current_mentee_no_titles.emp_no = titles.emp_no)