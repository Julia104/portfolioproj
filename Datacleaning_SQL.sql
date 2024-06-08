/*
Cleaning Data in SSMS

© Harison Nagisvaran
*/
--Standardize data format
SELECT SaleDate, CONVERT(Date,SaleDate)
FROM nashville;



ALTER TABLE nashville
ADD new_date Date;

UPDATE nashville
SET new_date = CONVERT(Date,SaleDate);


ALTER TABLE nashville
DROP COLUMN SaleDate;

SELECT *
FROM nashville;


-- Populate property address data
SELECT *  
FROM nashville
WHERE PropertyAddress is NULL;

SELECT a.ParcelID,a.PropertyAddress, b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress) AS new 
FROM nashville a
JOIN nashville b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is NULL


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from nashville a
JOIN nashville b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is NULL

SELECT * FROM nashville


-- Breaking out Address into Individual columns (Address, City, State)
SELECT PropertyAddress FROM nashville

SELECT 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) AS address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) AS address
FROM nashville

ALTER TABLE nashville
ADD PropertySplitAdd Nvarchar(255);

UPDATE nashville
SET PropertySplitAdd = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE nashville
ADD PropertySplitCity Nvarchar(255);

UPDATE nashville
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

SELECT * FROM nashville


--  Change OwnerName

SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM nashville

ALTER TABLE nashville
ADD OwnerSplitAdd Nvarchar(255);

UPDATE nashville
SET OwnerSplitAdd = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE nashville
ADD OwnerSplitCity Nvarchar(255);

UPDATE nashville
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)


ALTER TABLE nashville
ADD OwnerSplitState Nvarchar(255);

UPDATE nashville
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)




--- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant) as total_count
FROM
nashville
GROUP BY SoldAsVacant

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant ='Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'NO'
END as SoldAsVacant_updated
FROM nashville

UPDATE nashville
SET SoldAsVacant = CASE WHEN SoldAsVacant ='Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'NO'
END 


-- Remove Duplicate rows
WITH cte AS (
SELECT *, ROW_NUMBER() OVER(PARTITION BY ParcelID, PropertyAddress, SalePrice, new_date,LegalReference 
ORDER BY UniqueID) AS row_num
FROM nashville
)
DELETE 
FROM cte
WHERE row_num > 1


-- Delete Unused Columns
ALTER TABLE nashville
DROP COLUMN OwnerAddress,TaxDistrict, PropertyAddress

SELECT *
FROM nashville

ALTER TABLE nashville
DROP COLUMN OwnerAddress,TaxDistrict, PropertyAddress