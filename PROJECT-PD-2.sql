--PD--
/*--Q1--For the first few exercises, we are going to compare the total number of claims from Interventional Pain Management Specialists compared to those from Pain Managment specialists.

1. Write a query which returns the total number of claims for these two groups. Your output should look like this: 

specialty_description         |total_claims|
------------------------------|------------|
Interventional Pain Management|       55906|
Pain Management               |       70853|*/
SELECT * FROM drug;
SELECT * FROM prescription;
SELECT * FROM prescriber;

 
(SELECT specialty_description, COUNT(total_claim_count)
FROM prescriber
INNER JOIN prescription
USING(npi)
WHERE specialty_description='Interventional Pain Management' 
GROUP BY specialty_description)
UNION
(SELECT specialty_description, COUNT(total_claim_count)
FROM prescriber
INNER JOIN prescription
USING(npi)
WHERE specialty_description='Pain Management' 
GROUP BY specialty_description);

/*WAY2*/

 
SELECT 
    specialty_description,
    SUM(total_claim_count)
FROM 
 prescriber
JOIN 
 prescription USING(npi)
WHERE 
specialty_description IN ('Interventional Pain Management', 'Pain Management')
GROUP BY 
specialty_description
ORDER BY 
specialty_description;

/*. Now, let's say that we want our output to also include the total number of claims between these two groups. Combine two queries with the UNION keyword to accomplish this. Your output should look like this:

specialty_description         |total_claims|
------------------------------|------------|
                              |      126759|
Interventional Pain Management|       55906|
Pain Management               |       70853|
*/
(SELECT NULL AS specialty_description , SUM(total_claim_count)
FROM
prescriber
JOIN 
 prescription USING(npi)
 WHERE 
specialty_description IN ('Interventional Pain Management', 'Pain Management')
)

 UNION 
 
(SELECT 
    specialty_description,
    SUM(total_claim_count)
FROM 
 prescriber
JOIN 
 prescription USING(npi)
WHERE 
specialty_description IN ('Interventional Pain Management', 'Pain Management')
GROUP BY specialty_description)
;

/* 3a Now, instead of using UNION, 
make use of GROUPING SETS (https://www.postgresql.org/docs/10/queries-table-expressions.html#QUERIES-GROUPING-SETS) 
to achieve the same output*/

SELECT 
     NULL AS specialty_description,
    SUM(total_claim_count) AS total_claims
FROM 
 prescriber
JOIN 
 prescription USING(npi)
WHERE 
specialty_description IN ('Interventional Pain Management', 'Pain Management')
GROUP BY 

   GROUPING SETS (specialty_description,())
   ORDER BY  specialty_description IS NULL DESC, specialty_description;

/* Q4 In addition to comparing the total number of prescriptions by specialty, let's also bring in information about the number of opioid vs. non-opioid claims by these two specialties. Modify your query (still making use of GROUPING SETS so that your output also shows the total number of opioid claims vs. non-opioid claims by these two specialites:

specialty_description         |opioid_drug_flag|total_claims|
------------------------------|----------------|------------|
                              |                |      129726|
                              |Y               |       76143|
                              |N               |       53583|
Pain Management               |                |       72487|
Interventional Pain Management|                |       57239|
*/

SELECT 
     specialty_description, opioid_drug_flag,
    SUM(total_claim_count) AS total_claims
FROM 
 prescriber
INNER JOIN 
 prescription USING(npi)
 JOIN drug USING(drug_name)
WHERE 
specialty_description IN ('Interventional Pain Management', 'Pain Management') 
GROUP BY 

   GROUPING SETS (
   (specialty_description, opioid_drug_flag),
   (specialty_description),
   ())
   ORDER BY  specialty_description IS NULL DESC, 
             specialty_description, 
			 opioid_drug_flag IS NULL DESC
   ;

