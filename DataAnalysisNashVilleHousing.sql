SELECT *
FROM [dbo].[NashvilleHousing]

--STANDARDIZE DATE FORMAT

SELECT SaleDate, SaleDateConverted
FROM PortfolioProject..NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate =  CONVERT(DATE, SaleDate)

ALTER TABLE NASHVILLEHOUSING
ADD SaleDateConverted Date

UPDATE NashvilleHousing
SET SaleDateConverted =  CONVERT(DATE, SaleDate)

---POPULATE PROPERTY ADDRESS DATA

SELECT  *
FROM PortfolioProject..NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID


SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL (A.PROPERTYADDRESS, B.PropertyAddress)
FROM PortfolioProject..NashvilleHousing A
JOIN PortfolioProject..NashvilleHousing B
ON A.ParcelID = B.ParcelID
AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL

UPDATE A
SET PROPERTYADDRESS =  ISNULL (A.PROPERTYADDRESS, B.PropertyAddress)
FROM PortfolioProject..NashvilleHousing A
JOIN PortfolioProject..NashvilleHousing B
ON A.ParcelID = B.ParcelID
AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL



--BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMNS(ADDRESS, CITY, STATES)
SELECT  PropertyAddress
FROM PortfolioProject..NashvilleHousing
--WHERE PropertyAddress IS NULL
--ORDER BY ParcelID

SELECT
SUBSTRING(PROPERTYADDRESS, 1,CHARINDEX(',', PROPERTYADDRESS) -1) AS ADDRESS,
SUBSTRING(PROPERTYADDRESS,CHARINDEX(',', PROPERTYADDRESS) +1,LEN(PROPERTYADDRESS)) AS ADDRESS
FROM NashvilleHousing


--CREATE NEW TO COLUMN TO ADD VALUE


ALTER TABLE NASHVILLEHOUSING
ADD PropertySplitAddress nvarchar(255)

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PROPERTYADDRESS, 1,CHARINDEX(',', PROPERTYADDRESS) -1)


ALTER TABLE NASHVILLEHOUSING
ADD PropertySplitCity nvarchar(255)


UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PROPERTYADDRESS,CHARINDEX(',', PROPERTYADDRESS) +1,LEN(PROPERTYADDRESS))


SELECT *
FROM PortfolioProject.DBO.NashvilleHousing


-------------------------------------------------------------------
SELECT OwnerAddress
FROM NashvilleHousing


SELECT
PARSENAME(Replace(OwnerAddress, ',', '.'), 1),
PARSENAME(Replace(OwnerAddress, ',', '.'), 2),
PARSENAME(Replace(OwnerAddress, ',', '.'), 3)
from portfolioproject.dbo.nashvillehousing


-----------------------------------------------------------------------
-----ALTER THE TABLE TO SPLIT ADRESS, CITY AND STATE


ALTER TABLE NASHVILLEHOUSING
ADD OwnerSplitAddress nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',', '.'), 3)


ALTER TABLE NASHVILLEHOUSING
ADD OwnerSplitCity nvarchar(255)


UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',', '.'), 2)

ALTER TABLE NASHVILLEHOUSING
ADD OwnerSplitState nvarchar(255)


UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(Replace(OwnerAddress, ',', '.'), 1)

SELECT *
FROM NashvilleHousing

---------- CHANEG Y AND N TO YES AND NO IN 'SOLD AS VACANT FIELD'

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant,
 CASE
    WHEN SOLDASVACANT  = 'Y' THEN 'YES'
	WHEN SOLDASVACANT  = 'N' THEN 'NO'
	ELSE SOLDASVACANT
	END	
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE
    WHEN SOLDASVACANT  = 'Y' THEN 'YES'
	WHEN SOLDASVACANT  = 'N' THEN 'NO'
	ELSE SOLDASVACANT
	END	

---------------------------------------
-------REMOVING DUPLICATES


WITH RowNumCte AS(

SELECT *,
ROW_NUMBER()  OVER(
PARTITION BY ParceLId,
             propertyAddress,
			 SalePrice,
			 LegalReference
			 ORDER BY UNIQUEID
			 )ROW_NUM

FROM PortfolioProject.DBO.NashvilleHousing
)

SELECT *
FROM RowNumCte

-------------------------------------------------
-----------------DELETE UNUSED COLUMNS
ALTER TABLE PortfolioProject.DBO.NashvilleHousing
DROP COLUMN OWNERADDRESS , TAXDISTRICT, PROPERTYADDRESS, SALEDATE

SELECT *
FROM PortfolioProject..NashvilleHousing

