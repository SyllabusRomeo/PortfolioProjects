select *
From PortfolioProject..NashvilleHousing

-----------------------------------------------------------------------------------------
--Standardize Date Format
select SaleDate
From PortfolioProject..NashvilleHousing

select SaleDate, CONVERT(date,SaleDate)
From PortfolioProject..NashvilleHousing

--Now update the SaleDate Column
update NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

update NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

select SaleDateConverted
From PortfolioProject..NashvilleHousing

---------------------------------------------------------------------------------------
---Populate Property Address data
--1. Checking for NULL values
select PropertyAddress
From PortfolioProject..NashvilleHousing
where PropertyAddress is null

--2. Checking everything now
select *
From PortfolioProject..NashvilleHousing
where PropertyAddress is null

--3. Order by ID 
select *
From PortfolioProject..NashvilleHousing
where PropertyAddress is null
order by ParcelID

--4. JOIN ParcelIDs to PropertyAddress to populate null sections with the same Address
select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
From PortfolioProject..NashvilleHousing a --creating first object for the same table
JOIN PortfolioProject..NashvilleHousing b --creating second object for the same table
	on a.ParcelID = b.ParcelID			  -- Matching Id columns
	And a.[UniqueID ] <> b.[UniqueID ]    -- But not the same Unique ID
where a.PropertyAddress is null

--4b JOIN (Assigning the b.PropertyAddress to NULL of a.PropertyAddress using ISNULL())
select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashvilleHousing a --creating first object for the same table
JOIN PortfolioProject..NashvilleHousing b --creating second object for the same table
	on a.ParcelID = b.ParcelID			  -- Matching Id columns
	And a.[UniqueID ] <> b.[UniqueID ]    -- But not the same Unique ID
where a.PropertyAddress is null

--Updating Joins using the aliase
Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b 
	on a.ParcelID = b.ParcelID			
	And a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

----------------------------------------------------
--Breaking out Address into Individual Columns (Address, City, State)
select PropertyAddress
From PortfolioProject..NashvilleHousing
--where PropertyAddress is null
--order by ParcelID

-- Checking the comma position
Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)) as Address,
 CHARINDEX(',', PropertyAddress)
From PortfolioProject..NashvilleHousing

-- Replacing the comma position
Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) as Address
From PortfolioProject..NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address
From PortfolioProject.dbo.NashvilleHousing

use PortfolioProject
ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

Select *
From PortfolioProject.dbo.NashvilleHousing


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From PortfolioProject.dbo.NashvilleHousing



ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)


Select *
From PortfolioProject.dbo.NashvilleHousing



------------------------------------------------------------------------------------------------
-- Change Y and N to Yes and No in "Sold as Vacant" field


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2



Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From PortfolioProject.dbo.NashvilleHousing


Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END


-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertySplitAddress,
				 SalePrice,
				 SaleDateConverted,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From PortfolioProject.dbo.NashvilleHousing
--order by ParcelID
)
delete
From RowNumCTE
Where row_num > 1
--Order by [UniqueID ]



Select *
From PortfolioProject.dbo.NashvilleHousing



---------------------------------------------------------------------------------------------------------
-- Delete Unused Columns

Select *
From PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate