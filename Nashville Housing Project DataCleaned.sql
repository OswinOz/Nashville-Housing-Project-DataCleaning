--Cleaning DATA in SQL
SELECT *
FROM PortfolioProject..NashvillHousing

--STANDARDIZE DATE FORMAT
SELECT SaleDate, CONVERT(Date, SaleDate)
FROM PortfolioProject..NashvillHousing

UPDATE NashvillHousing
SET SaleDate = CONVERT(Date, SaleDate)

--POPULATE PROPERTY ADDRESS DATA
SELECT *
FROM PortfolioProject..NashvillHousing
WHERE PropertyAddress is null

--Since its the same address for the same ID
SELECT a.ParcelID, b.ParcelID, a.PropertyAddress, 
ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvillHousing a
	JOIN PortfolioProject..NashvillHousing b
	ON a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


UPDATE a 
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvillHousing a
	JOIN PortfolioProject..NashvillHousing b
	ON a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--How to get rid of the , on the address

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) As Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) As Address
FROM NashvillHousing

ALTER TABLE NashvillHousing
ADD PropertySplitCity Nvarchar(255)

UPDATE NashvillHousing
SET PropertyAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) 

ALTER TABLE NashvillHousing
ADD PropertySplitCity Nvarchar(255)

UPDATE NashvillHousing
SET PropertyAddress = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

select OwnerAddress
from NashvillHousing


SELECT 
PARSENAME (REPLACE(OwnerAddress,',','.'),3) AS Street,
PARSENAME (REPLACE(OwnerAddress,',','.'),2) AS City,
PARSENAME (REPLACE(OwnerAddress,',','.'),1) AS Code
FROM NashvillHousing


ALTER TABLE NashvillHousing
ADD OwnerSplitAddress Nvarchar(255)

Update NashvillHousing
SET OwnerSplitAddress = PARSENAME (REPLACE(OwnerAddress,',','.'),3) 

ALTER TABLE NashvillHousing
ADD OwnerSplitCity Nvarchar(255)

UPDATE NashvillHousing
SET OwnerSplitCity = PARSENAME (REPLACE(OwnerAddress,',','.'),2) 

ALTER TABLE NashvillHousing
ADD OwnerSplitCode Nvarchar(255)

UPDATE NashvillHousing
SET OwnerSplitCode = PARSENAME (REPLACE(OwnerAddress,',','.'),1) 

select * 
from PortfolioProject..NashvillHousing


--CHANGE Y and N to Yes and NO IN SOLD AS VACANT FIELD
SELECT DISTINCT SoldAsVacant, COUNT(SoldAsVacant)
FROM NashvillHousing
GROUP BY SoldAsVacant

select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 END
FROM NashvillHousing


UPDATE NashvillHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 END



--remove duplicates
with RowNumCTE as (
select *,
ROW_NUMBER()OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 salePrice,
				 saleDate,
				 legalReference
				 order by 
					UniqueID
					) ROW_NUM
from PortfolioProject..NashvillHousing
)

select *
FROM RowNumCTE
WHERE ROW_NUM > 1
--ORDER BY PropertyAddress


--DELETE UNUSED COLUMNS
--DONT TRY THIS UNLESS U REALLY HAVE TO

ALTER TABLE [dbo].[NashvillHousing]
DROP COLUMN taxDistrict, saleprice

select * 
from [dbo].[NashvillHousing]