
-- Cleaning data in SQL Queries-----------------------------------------------------------------------

Use PortfolioProject

Select*
From PortfolioProject.dbo.NashvilleHousing

--Standardize Date Format-----------------------------------------------------------------------------

Select SaleDate, CONVERT(Date,SaleDate)
From PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

-- Populate Property Address Data-----------------------------------------------------------------------------------

Select*
From PortfolioProject.dbo.NashvilleHousing
Where PropertyAddress is null


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
ON a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

UPDATE a
SET a.PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
ON a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null



-- Breaking Out Address into individual columns (Address, city, state)-------------------------------------


Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing


Select 
SUBSTRING(PropertyAddress,1,CharIndex(',', PropertyAddress)-1) as Address
,SUBSTRING(PropertyAddress,CharIndex(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address
From PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add PropertySplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CharIndex(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress,CharIndex(',', PropertyAddress)+1, LEN(PropertyAddress))


Select*
From PortfolioProject.dbo.NashvilleHousing


Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing

Select
PARSENAME(REPLACE(OwnerAddress,',','.'),3)
,PARSENAME(REPLACE(OwnerAddress,',','.'),2)
,PARSENAME(REPLACE(OwnerAddress,',','.'),1)
From PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)


Select*
From PortfolioProject.dbo.NashvilleHousing

-- change Y and N to Yes and No in 'Sold as vacant' field---------------

Select DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant,
Case When SoldAsVacant = 'Y' then 'Yes'
     When SoldAsVacant = 'N' then 'No'
	 Else SoldAsVacant
	 END
From PortfolioProject.dbo.NashvilleHousing


Update PortfolioProject.dbo.NashvilleHousing
Set SoldAsVacant = Case When SoldAsVacant = 'Y' then 'Yes'
                        When SoldAsVacant = 'N' then 'No'
	                    Else SoldAsVacant
	               END

--- Remove Duplicates------------------------------------------------
WITH RowNumCTE as(
 Select *, ROW_NUMBER() OVER(
 PARTITION BY ParcelID,
              PropertyAddress,
              SalePrice,
			  SaleDate,
			  LegalReference 
 ORDER BY     UniqueID ) row_num
 From PortfolioProject.dbo.NashvilleHousing
-- Order by ParcelID 
 )
 --Put DELETE instead of Select* below to delete tht rows with same data
 Select*
 From RowNumCTE
 Where row_num>1
 order by PropertyAddress


 --- Delete unused columns -------------------------------------------------------

Select*
From PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict, SaleDate