/*

Cleaning Data in SQL Queries

*/

Select *
From dbo.NashvilleHousing

-------------------------------------------------------------------------

--Standardize Date Format

Select SaleDateConverted, CONVERT (DATE, SaleDate)
From dbo.NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT (DATE, SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted DATE;

Update NashvilleHousing
SET SaleDateConverted = CONVERT (DATE, SaleDate)









-------------------------------------------------------------------------

--Populate Property Address Data


Select *
From dbo.NashvilleHousing
--WHERE PropertyAddress is null
ORDER BY ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL (a.PropertyAddress,b.PropertyAddress)
From dbo.NashvilleHousing a
JOIN dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL (a.PropertyAddress,b.PropertyAddress)
From dbo.NashvilleHousing a
JOIN dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is null


------------------------------------------------------------------------

--Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From dbo.NashvilleHousing
--WHERE PropertyAddress is null
--ORDER BY ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
From dbo.NashvilleHousing



Select 
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

Select *
From dbo.NashvilleHousing

-------------------------------------------------------------------------

--Change Y and N to Yes and No in "Sold as Vacant" field

Select DISTINCT(SoldAsVacant)
From dbo.NashvilleHousing


Select DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
From dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

Select SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
       WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
       WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

--------------------------------------------------------------------------------

--Remove Duplicates

WITH RowNumCTE AS (
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
	             PropertyAddress,
				 SaleDate,
				 SalePrice,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
From dbo.NashvilleHousing
--ORDER BY ParcelID
)
Select *
From RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress

-----------------

WITH RowNumCTE AS (
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
	             PropertyAddress,
				 SaleDate,
				 SalePrice,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
From dbo.NashvilleHousing
--ORDER BY ParcelID
)
DELETE
From RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress


--------------------------------------------------------------------------

--Delete Unused Columns


Select *
From dbo.NashvilleHousing

ALTER TABLE dbo.NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress

ALTER TABLE dbo.NashvilleHousing
DROP COLUMN SaleDate, TaxDistrict