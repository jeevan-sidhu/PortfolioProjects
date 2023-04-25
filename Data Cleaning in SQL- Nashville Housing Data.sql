/* 
Cleaning Data in SQL Queries
*/


SELECT *
FROM NashvilleHousing;


------------------------------------------------------------------------

-- Standardize Date Format

SELECT sale_date_time, CAST (sale_date_time AS Date)
FROM NashvilleHousing;

ALTER TABLE NashvilleHousing
ADD sale_date Date

UPDATE NashvilleHousing
SET sale_date = CAST (sale_date_time AS Date);

SELECT sale_date, sale_date_time
FROM NashvilleHousing;

ALTER TABLE NashvilleHousing
DROP sale_date_time;


------------------------------------------------------------------------

-- Filling the NULL Values in Property Address Column 

SELECT *
FROM NashvilleHousing
--WHERE property_address IS NULL
ORDER BY parcel_id;

SELECT A.PARCEL_ID,
	A.PROPERTY_ADDRESS,
	B.PARCEL_ID,
	B.PROPERTY_ADDRESS,
	COALESCE(A.PROPERTY_ADDRESS, B.PROPERTY_ADDRESS)
FROM NASHVILLEHOUSING A
JOIN NASHVILLEHOUSING B ON A.PARCEL_ID = B.PARCEL_ID
AND A.UNIQUE_ID <> B.UNIQUE_ID
WHERE A.PROPERTY_ADDRESS IS NULL;

UPDATE NASHVILLEHOUSING
SET PROPERTY_ADDRESS = COALESCE(A.PROPERTY_ADDRESS, B.PROPERTY_ADDRESS)
FROM NASHVILLEHOUSING A
JOIN NASHVILLEHOUSING B ON A.PARCEL_ID = B.PARCEL_ID
AND A.UNIQUE_ID <> B.UNIQUE_ID
WHERE A.PROPERTY_ADDRESS IS NULL;


------------------------------------------------------------------------

-- Breaking Address into individual Columns (Address, City, State)

SELECT PROPERTY_ADDRESS,
	SUBSTRING(PROPERTY_ADDRESS, 1, POSITION(',' IN PROPERTY_ADDRESS)-1) AS ADDRESS,
	SUBSTRING(PROPERTY_ADDRESS, POSITION(',' IN PROPERTY_ADDRESS)+1) AS CITY
FROM NASHVILLEHOUSING;

ALTER TABLE NASHVILLEHOUSING
ADD property_addr VARCHAR(255),
ADD property_city VARCHAR(255);

UPDATE NASHVILLEHOUSING
SET property_addr = SUBSTRING(PROPERTY_ADDRESS, 1, POSITION(',' IN PROPERTY_ADDRESS)-1),
property_city = SUBSTRING(PROPERTY_ADDRESS, POSITION(',' IN PROPERTY_ADDRESS)+1);

ALTER TABLE NASHVILLEHOUSING
DROP PROPERTY_ADDRESS;

SELECT OWNER_ADDRESS,
	SPLIT_PART(OWNER_ADDRESS,',',1) AS ADDRESS,
	SPLIT_PART(OWNER_ADDRESS,',',2) AS CITY,
	SPLIT_PART(OWNER_ADDRESS,',',3) AS STATE,
FROM NASHVILLEHOUSING;

ALTER TABLE NASHVILLEHOUSING
ADD owner_addr VARCHAR(255),
ADD owner_city VARCHAR(255),
ADD owner_state VARCHAR(255);

UPDATE NASHVILLEHOUSING
SET owner_addr = SPLIT_PART(OWNER_ADDRESS,',',1),
owner_city = SPLIT_PART(OWNER_ADDRESS,',',2),
owner_state = SPLIT_PART(OWNER_ADDRESS,',',3);

ALTER TABLE NASHVILLEHOUSING
DROP OWNER_ADDRESS;


------------------------------------------------------------------------

-- Change 'Y' and 'N' To 'Yes' and 'No' in "SOLD_AS_VACANT" Column

SELECT DISTINCT SOLD_AS_VACANT
FROM NASHVILLEHOUSING;

SELECT SOLD_AS_VACANT, COUNT(SOLD_AS_VACANT)
FROM NASHVILLEHOUSING
GROUP BY SOLD_AS_VACANT;

SELECT SOLD_AS_VACANT,
	CASE
			WHEN SOLD_AS_VACANT = 'Y' THEN 'Yes'
			WHEN SOLD_AS_VACANT = 'N' THEN 'No'
			ELSE SOLD_AS_VACANT
	END
FROM NASHVILLEHOUSING;

UPDATE NASHVILLEHOUSING
SET SOLD_AS_VACANT = CASE
			WHEN SOLD_AS_VACANT = 'Y' THEN 'Yes'
			WHEN SOLD_AS_VACANT = 'N' THEN 'No'
			ELSE SOLD_AS_VACANT
	END


------------------------------------------------------------------------

-- Remove Duplicaes

WITH row_num_cte AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY parcel_id,
				property_addr,
				sale_price,
				sale_date,
				legal_reference
	ORDER BY unique_id
	) AS duplicate_rows_count
FROM NASHVILLEHOUSING
)
SELECT * 
FROM row_num_cte
WHERE duplicate_rows_count > 1;


------------------------------------------------------------------------

-- Delete Unused Columns

SELECT




