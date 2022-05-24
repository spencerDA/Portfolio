-- Nashville Housing DataSet cleaning

Select * 
From Nashville.dbo.NashvilleHousing

Select SaleDate, Convert(Date, SaleDate)
From Nashville.dbo.NashvilleHousing


Alter Table Nashville.dbo.NashvilleHousing
Add Sale_Date Date;

Update NashvilleHousing
Set Sale_Date = Convert(Date, SaleDate);

Select SaleDate, Sale_Date
From Nashville.dbo.NashvilleHousing

----------------------------------------------------
-- Filling null propertyAddress values
Select *
From Nashville.dbo.NashvilleHousing
--Where PropertyAddress is null
order by ParcelID

Select *
From Nashville.dbo.NashvilleHousing
Where PropertyAddress is null

Select a.[UniqueID ], b.[UniqueID ] ,a.ParcelID, b.ParcelID, a.PropertyAddress, b.PropertyAddress, isnull(a.propertyAddress, b.PropertyAddress)
From Nashville.dbo.NashvilleHousing a
Join Nashville.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
Where a.PropertyAddress is null
AND a.[UniqueID ] <> b.[UniqueID ]

Update a
Set PropertyAddress = isnull(a.propertyAddress, b.PropertyAddress)
From Nashville.dbo.NashvilleHousing a
Join Nashville.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
Where a.PropertyAddress is null
AND a.[UniqueID ] <> b.[UniqueID ]


----------------------------------------------------------------
--Break address into individual columns (Address, City, State)

Select PropertyAddress, Substring(PropertyAddress, 1, Charindex(',', PropertyAddress) - 1) as Address, Substring(PropertyAddress, Charindex(',', PropertyAddress) + 2, len(PropertyAddress)) as City
From Nashville.dbo.NashvilleHousing

Alter Table NashvilleHousing
Add Address nvarchar(250)

Update NashvilleHousing
Set Address = Substring(PropertyAddress, 1, Charindex(',', PropertyAddress) - 1)

Alter Table NashvilleHousing
Add City nvarchar(250);

Update NashvilleHousing
Set City = Substring(PropertyAddress, Charindex(',', PropertyAddress) + 2, len(PropertyAddress));

Select *
From Nashville.dbo.NashvilleHousing


----------------------------------------------------------------
--Break Owneraddress into individual columns (Address, City, State)

Select
PARSENAME(Replace(OwnerAddress, ',', '.'), 3) as Owner_Address,
PARSENAME(Replace(OwnerAddress, ',', '.'), 2) as Owner_City,
PARSENAME(Replace(OwnerAddress, ',', '.'), 1) as Owner_State
From Nashville.dbo.NashvilleHousing


Alter Table NashvilleHousing
Add Owner_Address nvarchar(250), Owner_City nvarchar(250), Owner_State nvarchar(250)

Update NashvilleHousing
Set Owner_Address = PARSENAME(Replace(OwnerAddress, ',', '.'), 3), Owner_City = PARSENAME(Replace(OwnerAddress, ',', '.'), 2), Owner_State = PARSENAME(Replace(OwnerAddress, ',', '.'), 1)

Select *
From Nashville.dbo.NashvilleHousing


-------------------------------------------------------------------------------------
-- Fix SoldAsVacant to standardize values


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From Nashville.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant,
	Case When SoldAsVacant = 'Y' Then 'Yes'
		 When SoldAsVacant = 'N' Then 'No'
	Else SoldAsVacant
	End
From Nashville.dbo.NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant = Case When SoldAsVacant = 'Y' Then 'Yes'
		 When SoldAsVacant = 'N' Then 'No'
	Else SoldAsVacant
	End


----------------------------------------------------
-- Remove duplicates (Wouldn't normally do to the raw data

WITH ROWNumCTE as (
Select *, ROW_NUMBER() Over (
	Partition by 
				ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				Order By
					UniqueID
					) row_num

From Nashville.dbo.NashvilleHousing
--order by ParcelID
)
Select *
From ROWNumCTE
Where row_num > 1


-----------------------------------------------------------

-- Delete unused columns

select *
from Nashville.dbo.NashvilleHousing

alter table Nashville.dbo.NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate




















