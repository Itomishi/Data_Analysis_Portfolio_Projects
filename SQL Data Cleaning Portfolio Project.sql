/*

Cleaning Data in SQL Queries

*/

Select *
From PortfolioProject.dbo.NashvilleHousing


--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

Select SaleDateConverted, CONVERT(Date, SaleDate)
From PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
Set SaleDate = CONVERT(Date, SaleDate)

-- It didn't Update properly, so I tried;

ALTER TABLE NashvilleHousing
Add SaleDateConverted date;

Update NashvilleHousing
Set SaleDateConverted = CONVERT(Date, SaleDate);



 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is null
Order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
Join PortfolioProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
Join PortfolioProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null



--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City)

Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is null
--Order by ParcelID

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -  1) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +  1, LEN(PropertyAddress)) AS City

From PortfolioProject.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
ADD PropertySpiltAddress nvarchar(255);

Update NashvilleHousing
Set PropertySpiltAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -  1);


ALTER TABLE NashvilleHousing
ADD PropertySpiltCity nvarchar(255);

Update NashvilleHousing
Set PropertySpiltCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +  1, LEN(PropertyAddress));


SELECT *
From PortfolioProject.dbo.NashvilleHousing




-- Breaking out Address into Individual Columns (Address, City, State)

SELECT OwnerAddress
From PortfolioProject.dbo.NashvilleHousing


Select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM PortfolioProject.dbo.NashvilleHousing



ALTER TABLE NashvilleHousing
ADD OwnerSpiltAddress nvarchar(255);

Update NashvilleHousing
Set OwnerSpiltAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3);


ALTER TABLE NashvilleHousing
ADD OwnerSpiltCity nvarchar(255);

Update NashvilleHousing
Set OwnerSpiltCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2);


ALTER TABLE NashvilleHousing
ADD OwnerSpiltState nvarchar(255);

Update NashvilleHousing
Set OwnerSpiltState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);



SELECT *
From PortfolioProject.dbo.NashvilleHousing




--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
Order by 2


Select  SoldAsVacant
, CASE	When SoldAsVacant = 'Y' Then 'Yes'
		When SoldAsVacant = 'N' Then 'No'
		Else SoldAsVacant
		End
From PortfolioProject.dbo.NashvilleHousing


UPDATE NashvilleHousing
Set SoldAsVacant = CASE	When SoldAsVacant = 'Y' Then 'Yes'
						When SoldAsVacant = 'N' Then 'No'
						Else SoldAsVacant
						End



-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE as (
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID
				,PropertyAddress
				,SaleDate
				,SalePrice
				,LegalReference
				ORDER BY 
					UniqueID
					) row_num

From PortfolioProject.dbo.NashvilleHousing
--Order by ParcelID
)

Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

-- To Remove Duplicates

--Delete
--From RowNumCTE
--Where row_num > 1



---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns


SELECT *
From PortfolioProject.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict, SaleDate








