
/*

Data Cleaning Queries in SQL

*/


--Standardize DATE format

ALTER TABLE TennesseeHousingData
ALTER COLUMN SaleDate DATE

SELECT *
FROM [PortfolioProject].[dbo].[TennesseeHousingData]


--OR
--SELECT
--SaleDate = CONVERT(DATE, SaleDate)
--FROM PortfolioProject..TennesseeHousingData

----------------------------------------------------------------------------------------------------------------------------------------------------


--Populate the Property Address/Replace NULL values with addresses

SELECT 
A.ParcelID,
B.ParcelID,
A.PropertyAddress,
ISNULL(A.PropertyAddress, B.PropertyAddress),
B.PropertyAddress

FROM PortfolioProject..TennesseeHousingData A
JOIN PortfolioProject..TennesseeHousingData B
ON A.ParcelID=B.ParcelID
AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL

UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)

FROM PortfolioProject..TennesseeHousingData A
JOIN PortfolioProject..TennesseeHousingData B
ON A.ParcelID=B.ParcelID
AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL

--------------------------------------------------------------------------------------------------------------------------------------------------
 --Breaking Down PropertyAddress into Individual Columns

 --PropertyAddress
SELECT 
PropertyAddress,
Address= SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1),
City= SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress))
FROM PortfolioProject..TennesseeHousingData

ALTER TABLE TennesseeHousingData
ADD Address Nvarchar(255);

UPDATE TennesseeHousingData
SET Address =SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE TennesseeHousingData
ADD City Nvarchar(255);

UPDATE TennesseeHousingData
SET City =SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress))

--OwnerAddress
SELECT 
OwnerAddress,
PARSENAME(REPLACE(OwnerAddress, ',','.'),3),
PARSENAME(REPLACE(OwnerAddress, ',','.'),2),
PARSENAME(REPLACE(OwnerAddress, ',','.'),1)
FROM PortfolioProject..TennesseeHousingData


ALTER TABLE TennesseeHousingData
ADD OwnerSplitAddress Nvarchar(255);

UPDATE TennesseeHousingData
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'),3)

ALTER TABLE TennesseeHousingData
ADD OwnerSplitCity Nvarchar(255);

UPDATE TennesseeHousingData
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'),2)

ALTER TABLE TennesseeHousingData
ADD OwnerSplitState Nvarchar(255);

UPDATE TennesseeHousingData
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'),1)

--------------------------------------------------------------------------------------------------------------------------------------------------

--Changing 'Y' to 'Yes' and 'N' to 'No' in SoldAsVacant 

SELECT 
DISTINCT SoldAsVacant,
COUNT(SoldAsVacant)

FROM TennesseeHousingData
GROUP BY SoldAsVacant
ORDER BY 2

SELECT 
SoldAsVacant,
CASE 
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END

FROM TennesseeHousingData

UPDATE TennesseeHousingData
SET SoldAsVacant =
CASE 
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END
--------------------------------------------------------------------------------------------------------------------------------------------

--Removing Duplicate Rows from the Data

WITH Row_NumCTE AS
(SELECT *,
row_num = ROW_NUMBER() OVER (PARTITION BY PropertyAddress, SaleDate, SalePrice,LegalReference ORDER BY UniqueID) 

FROM PortfolioProject..TennesseeHousingData)

DELETE
FROM Row_NumCTE
WHERE row_num > 1

---------------------------------------------------------------------------------------------------------------------------------
--Deleting Unused columns

SELECT *
FROM PortfolioProject..TennesseeHousingData

ALTER TABLE PortfolioProject..TennesseeHousingData
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict