
/*

Data Cleaning Queries in SQL

*/


--Standardize DATE format

ALTER TABLE NashvilleHousingData
ALTER COLUMN SaleDate DATE

SELECT *
FROM [PortfolioProject].[dbo].[NashvilleHousingData]


--OR
--SELECT
--SaleDate = CONVERT(DATE, SaleDate)
--FROM PortfolioProject..NashvilleHousingData

----------------------------------------------------------------------------------------------------------------------------------------------------


--Populate the Property Address/Replace NULL values with addresses

SELECT 
A.ParcelID,
B.ParcelID,
A.PropertyAddress,
ISNULL(A.PropertyAddress, B.PropertyAddress),
B.PropertyAddress

FROM PortfolioProject..NashvilleHousingData A
JOIN PortfolioProject..NashvilleHousingData B
ON A.ParcelID=B.ParcelID
AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL

UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)

FROM PortfolioProject..NashvilleHousingData A
JOIN PortfolioProject..NashvilleHousingData B
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
FROM PortfolioProject..NashvilleHousingData

ALTER TABLE NashvilleHousingData
ADD Address Nvarchar(255);

UPDATE NashvilleHousingData
SET Address =SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousingData
ADD City Nvarchar(255);

UPDATE NashvilleHousingData
SET City =SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress))

--OwnerAddress
SELECT 
OwnerAddress,
PARSENAME(REPLACE(OwnerAddress, ',','.'),3),
PARSENAME(REPLACE(OwnerAddress, ',','.'),2),
PARSENAME(REPLACE(OwnerAddress, ',','.'),1)
FROM PortfolioProject..NashvilleHousingData


ALTER TABLE NashvilleHousingData
ADD OwnerSplitAddress Nvarchar(255);

UPDATE NashvilleHousingData
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'),3)

ALTER TABLE NashvilleHousingData
ADD OwnerSplitCity Nvarchar(255);

UPDATE NashvilleHousingData
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'),2)

ALTER TABLE NashvilleHousingData
ADD OwnerSplitState Nvarchar(255);

UPDATE NashvilleHousingData
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'),1)

--------------------------------------------------------------------------------------------------------------------------------------------------

--Changing 'Y' to 'Yes' and 'N' to 'No' in SoldAsVacant 

SELECT 
DISTINCT SoldAsVacant,
COUNT(SoldAsVacant)

FROM NashvilleHousingData
GROUP BY SoldAsVacant
ORDER BY 2

SELECT 
SoldAsVacant,
CASE 
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END

FROM NashvilleHousingData

UPDATE NashvilleHousingData
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

FROM PortfolioProject..NashvilleHousingData)

DELETE
FROM Row_NumCTE
WHERE row_num > 1

---------------------------------------------------------------------------------------------------------------------------------
--Deleting Unused columns

SELECT *
FROM PortfolioProject..NashvilleHousingData

ALTER TABLE PortfolioProject..NashvilleHousingData
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict