--Bonus--
/*1. How many npi numbers appear in the prescriber table but not in the prescription table?*/


--MYFirst approach--But postgres does not support  MINUS Operator
SELECT COUNT(DISTINCT npi) AS Number_npi_prescription
FROM prescription
MINUS 
SELECT COUNT(DISTINCT npi) AS Number_npi_prescriber
FROM prescriber;

--approach2--4458
SELECT COUNT(DISTINCT prescriber.npi)
FROM prescriber 
LEFT JOIN prescription
USING(npi)
WHERE prescription.npi IS NULL;


/*2.
    a. Find the top five drugs (generic_name) prescribed by prescribers
	with the specialty of Family Practice.*/
	
	SELECT * FROM prescription;
	SELECT DISTINCT generic_name, COUNT(total_claim_count) AS prescribed
	FROM drug
	INNER JOIN prescription
	USING(drug_name)
	INNER JOIN prescriber
	USING(npi)
	WHERE specialty_description = 'Family Practice'
	GROUP BY generic_name
	ORDER BY prescribed DESC
	LIMIT 5;


    /*b. Find the top five drugs (generic_name) prescribed by prescribers 
	with the specialty of Cardiology.*/

	SELECT DISTINCT generic_name, COUNT(total_claim_count) AS prescribed
	FROM drug
	INNER JOIN prescription
	USING(drug_name)
	INNER JOIN prescriber
	USING(npi)
	WHERE specialty_description = 'Cardiology'
	GROUP BY generic_name
	ORDER BY prescribed DESC
	LIMIT 5;

    /*c. Which drugs are in the top five prescribed by Family Practice prescribers
	and Cardiologists? Combine what you did for parts a and b into a single query 
	to answer this question.*/
	SELECT * FROM prescription;
	(SELECT DISTINCT generic_name, COUNT(total_claim_count) AS prescribed
	FROM drug
	INNER JOIN prescription
	USING(drug_name)
	INNER JOIN prescriber
	USING(npi)
	WHERE specialty_description = 'Family Practice'
	GROUP BY generic_name
	ORDER BY prescribed DESC
	LIMIT 5)
	UNION
	SELECT DISTINCT generic_name, COUNT(total_claim_count) AS prescribed
	FROM drug
	INNER JOIN prescription
	USING(drug_name)
	INNER JOIN prescriber
	USING(npi)
	WHERE specialty_description = 'Cardiology'
	GROUP BY generic_name
	ORDER BY prescribed DESC
	LIMIT 5;

/*Q3Your goal in this question is to generate a list of the top prescribers 
in each of the major metropolitan areas of Tennessee.
a. First, write a query that finds the top 5 prescribers in Nashville 
in terms of the total number of claims (total_claim_count) across all drugs. 
Report the npi, the total number of claims, and include a column showing the city.*/

SELECT * FROM prescriber;
SELECT * FROM prescription;

select npi,nppes_provider_city AS City, total_claim_count AS Total_no_claims
FROM prescriber 
INNER JOIN prescription
USING(npi)
WHERE nppes_provider_city='NASHVILLE'
ORDER BY total_no_claims DESC
LIMIT 5;

/* b. Now, report the same for Memphis.*/
select npi,nppes_provider_city AS City, total_claim_count AS Total_no_claims
FROM prescriber 
INNER JOIN prescription
USING(npi)
WHERE nppes_provider_city='MEMPHIS'
ORDER BY total_no_claims DESC
LIMIT 5;
/*c. Combine your results from a and b, along with the results for Knoxville and Chattanooga.*/
(select npi,nppes_provider_city AS City, total_claim_count AS Total_no_claims
FROM prescriber 
INNER JOIN prescription
USING(npi)
WHERE nppes_provider_city='NASHVILLE'
ORDER BY total_no_claims DESC
LIMIT 5)
UNION ALL
(select npi,nppes_provider_city AS City, total_claim_count AS Total_no_claims
FROM prescriber 
INNER JOIN prescription
USING(npi)
WHERE nppes_provider_city='MEMPHIS'
ORDER BY total_no_claims DESC
LIMIT 5)
UNION ALL
(select npi,nppes_provider_city AS City, total_claim_count AS Total_no_claims
FROM prescriber 
INNER JOIN prescription
USING(npi)
WHERE nppes_provider_city='KNOXVILLE'
ORDER BY total_no_claims DESC
LIMIT 5)
UNION ALL
(select npi,nppes_provider_city AS City, total_claim_count AS Total_no_claims
FROM prescriber 
INNER JOIN prescription
USING(npi)
WHERE nppes_provider_city='CHATTANOOGA'
ORDER BY total_no_claims DESC
LIMIT 5);


/*4. Find all counties which had an above-average number of overdose deaths. 
Report the county name and number of overdose deaths.*/
SELECT * FROM overdose_deaths;
SELECT county,SUM(overdose_deaths)
FROM fips_county
INNER JOIN overdose_deaths
ON fips_county.fipscounty::INTEGER = overdose_deaths.fipscounty
WHERE overdose_deaths >(SELECT AVG(overdose_deaths)
                            FROM overdose_deaths)
							GROUP BY county;
						
                         

/*5 a. Write a query that finds the total population of Tennessee.*/
SELECT * FROM population;
SELECT * FROM fips_county;

SELECT SUM(population)
FROM population
INNER JOIN fips_county
USING(fipscounty)
WHERE state='TN';

/*b. Build off of the query that you wrote in part a 
to write a query that returns for each county 
that county's name, its population, 
and the percentage of the total population of Tennessee that is contained in that county.*/
SELECT * FROM population;
SELECT * FROM fips_county;

WITH Total_tennessee_population AS(
SELECT SUM(population.population) AS total_population
FROM fips_county
INNER JOIN population
USING(fipscounty)
WHERE state='TN')

SELECT county, population.population,
100*(population.population/total_population) AS percentage_of_population
FROM fips_county
INNER JOIN population
ON fips_county.fipscounty= population.fipscounty
CROSS JOIN Total_tennessee_population
WHERE state='TN';