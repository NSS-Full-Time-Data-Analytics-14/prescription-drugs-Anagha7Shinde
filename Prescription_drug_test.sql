--MVP--
--Q1--
SELECT * FROM prescriber;
SELECT * FROM prescription;
SELECT * FROM drug;


SELECT nppes_provider_last_org_name,
nppes_provider_first_name, specialty_description, 
SUM(total_claim_count) AS total_claims
FROM prescription
INNER JOIN prescriber
ON prescription.npi=prescriber.npi 
GROUP BY nppes_provider_first_name,nppes_provider_last_org_name, specialty_description
ORDER BY total_claims DESC 
LIMIT 4;

--Q2--
--a.--

SELECT specialty_description, npi, SUM (total_claim_count) AS tc
FROM prescriber
	INNER JOIN prescription USING (npi)
GROUP BY specialty_description, npi
ORDER BY tc DESC
LIMIT 1;
--2b--
SELECT * FROM drug;

SELECT specialty_description, SUM(total_claim_count) AS tc
FROM  prescriber
INNER JOIN prescription
USING(npi)
INNER JOIN drug
USING(drug_name)
WHERE opioid_drug_flag='Y'
GROUP BY specialty_description
ORDER BY tc DESC
LIMIT 1;

--2C--
SELECT * FROM prescriber;
SELECT * FROM prescription;

--3a--
SELECT generic_name, MAX(total_drug_cost) AS tdc
FROM drug
INNER JOIN prescription USING(drug_name)
GROUP BY generic_name
ORDER BY tdc DESC
LIMIT 1
;

--3b--
SELECT generic_name,
ROUND(MAX(prescription.total_drug_cost/total_day_supply),2)
AS drug_cost_day
FROM drug
INNER JOIN prescription 
USING(drug_name)
GROUP BY generic_name
ORDER BY drug_cost_day DESC
LIMIT 1;

--Q4--
/*a. For each drug in the drug table, return the drug name 
and then a column named 'drug_type' 
which says 'opioid' for drugs which have opioid_drug_flag = 'Y',
says 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y', 
and says 'neither' for all other drugs*/
SELECT * FROM drug;

SELECT drug_name,
CASE WHEN opioid_drug_flag='Y' THEN 'opioid'
     WHEN antibiotic_drug_flag='Y' THEN 'antibiotic'
ELSE 'neither'
END AS drug_type
FROM drug;

 /*4b. Building off of the query you wrote for part a, 
 determine whether more was spent (total_drug_cost) on opioids or on antibiotics. 
 Hint: Format the total costs as MONEY for easier comparision.*/

 SELECT drug_name, 
COUNT(CASE WHEN opioid_drug_flag='Y' THEN 'opioid' END) AS Total_opioid,
  COUNT(CASE WHEN antibiotic_drug_flag='Y' THEN 'antibiotic'END) AS Total_antibiotic
FROM drug
GROUP BY drug_name
ORDER BY Total_opioid, Total_antibiotic DESC
;


/*5A
a. How many CBSAs are in Tennessee? **Warning:** 
The cbsa table contains information for all states, not just Tennessee*/

SELECT * FROM cbsa;
SELECT * FROM population;

SELECT COUNT(DISTINCT cbsa) AS number_cbsa
FROM cbsa
WHERE cbsaname ILIKE '%TN%';

/*b. Which cbsa has the largest combined population?
Which has the smallest? Report the CBSA name and total population*/

(SELECT cbsaname, MAX(population)
FROM cbsa 
LEFT JOIN population
USING(fipscounty)
GROUP BY cbsaname, population
ORDER BY population DESC NULLS LAST
LIMIT 1)

(SELECT cbsaname, MIN(population)
FROM cbsa 
LEFT JOIN population
USING(fipscounty)
GROUP BY cbsaname, population
ORDER BY population NULLS LAST
LIMIT 1);

/*5C
 c. What is the largest (in terms of population) county 
 which is not included in a CBSA? Report the county name and population.*/
 SELECT * FROM population;
 SELECT * FROM fips_county;
 SELECT * FROM cbsa;
 
 SELECT county, MAX(population)
 FROM fips_county 
 INNER JOIN population USING(fipscounty)
 LEFT JOIN cbsa ON population.fipscounty=cbsa.fipscounty
 WHERE cbsa.fipscounty IS NULL
GROUP BY county, population
ORDER BY population DESC
LIMIT 1;
   
/*6.
a. Find all rows in the prescription table where total_claims is at least 3000.
Report the drug_name and the total_claim_count*/
SELECT * FROM prescriber;
SELECT drug_name,total_claim_count
FROM prescription
WHERE total_claim_count >=3000;

/*b. For each instance that you found in part a,
add a column that indicates whether the drug is an opioid*/
SELECT * FROM drug;
SELECT drug_name, total_claim_count,
  CASE
     WHEN opioid_drug_flag='Y' THEN 'Yes'
	 ELSE 'No'
	 END AS drug_is_opioid
	 FROM prescription
INNER JOIN drug
USING(drug_name)
WHERE prescription.total_claim_count >=3000;

/* c. Add another column to you answer from the previous part 
which gives the prescriber first and last name associated with each row*/

SELECT * FRom prescriber;
SELECT drug_name, nppes_provider_last_org_name||''||nppes_provider_first_name 
AS prescriber_name,total_claim_count,
  CASE
     WHEN opioid_drug_flag='Y' THEN 'Yes'
	 ELSE 'No'
	 END AS drug_is_opioid
	 FROM prescription
INNER JOIN drug
USING(drug_name)
INNER JOIN prescriber
USING(npi)
WHERE prescription.total_claim_count >=3000;

/*7. The goal of this exercise is to generate a full list of all pain management specialists in Nashville and the number of claims they had for each opioid.
**Hint:** The results from all 3 parts will have 637 rows.
 a. First, create a list of all npi/drug_name combinations for pain management specialists (specialty_description = 'Pain Management) 
  in the city of Nashville (nppes_provider_city = 'NASHVILLE'),
  where the drug is an opioid (opiod_drug_flag = 'Y'). 
  **Warning:** Double-check your query before running it. 
  You will only need to use the prescriber and drug tables since
  you don't need the claims numbers yet*/


SELECT npi, drug_name
FROM prescriber 
CROSS JOIN drug
WHERE opioid_drug_flag='Y'
AND nppes_provider_city='NASHVILLE' 
AND specialty_description='Pain Management';


/*Next, report the number of claims per drug per prescriber.
Be sure to include all combinations, whether or not the prescriber had any claims.
You should report the npi, the drug name, and the number of claims (total_claim_count)*/

SELECT * FROM prescriber;
SELECT * FROM prescription;
SELECT * FROM drug;

SELECT npi,drug_name, SUM(prescription.total_claim_count) AS total_number_of_claims
FROM prescriber
CROSS JOIN drug
LEFT JOIN prescription USING(npi, drug_name)
WHERE prescription.total_claim_count IS NOT NULL AND opioid_drug_flag='Y'
     AND nppes_provider_city='NASHVILLE' 
     AND specialty_description='Pain Management'
	 GROUP BY npi, drug_name;
ORDER BY total_number_of_claims DESC;

/*Finally, if you have not done so already, 
fill in any missing values for total_claim_count with 0. 
Hint - Google the COALESCE function.*/

SELECT DISTINCT npi,drug_name,
COALESCE (total_claim_count, '0') AS number_of_claims
FROM prescriber
CROSS JOIN drug
LEFT JOIN prescription USING(npi, drug_name)
WHERE opioid_drug_flag='Y'
AND nppes_provider_city='NASHVILLE' 
AND specialty_description='Pain Management';







