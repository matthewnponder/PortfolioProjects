/*

Cleaning Data in SQL Queries

*/

--Skills Used: Converting Data Types, Update Table, Alter Table, Join, Window Function (Partition By), Row_Number, CTE, Paresename, Substring, Case Statement

--------------------------------------------------------------------------------------------------------------------------------------
--Select All Data

select *
from NashvilleHousing




--------------------------------------------------------------------------------------------------------------------------------------
--Standardize Date Format

select SaleDateConverted, CONVERT(Date, Saledate)
from NashvilleHousing


Alter Table NashvilleHousing
Add SaleDateConverted Date; 

Update NashvilleHousing
set SaleDateConverted = CONVERT(Date, Saledate)




--------------------------------------------------------------------------------------------------------------------------------------
--Populate Property Address


select a.ParcelID, a.ParcelID, a.PropertyAddress, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a
JOIN NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

Update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a
JOIN NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null
	and a.UniqueID <> b.UniqueID



--------------------------------------------------------------------------------------------------------------------------------------
--Breaking out Address into Individual Columns (Address, City, State)


select PropertyAddress
from NashvilleHousing
--where PropertyAddress is null
--order by ParcelID

select propertyaddress, substring (propertyaddress, 1, Charindex(',', PropertyAddress)-1) as Address 
	,  substring (propertyaddress, Charindex(',', PropertyAddress) + 1, len(PropertyAddress))  as City
from nashvillehousing

Alter Table NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Alter Table NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
Set PropertySplitAddress = substring (propertyaddress, 1, Charindex(',', PropertyAddress)-1) 


Update NashvilleHousing
Set PropertySplitCity = substring (propertyaddress, Charindex(',', PropertyAddress) + 1, len(PropertyAddress))  


select *
from NashvilleHousing



select 
parsename(replace(owneraddress,',' , '.') , 3) as Address
,parsename(replace(owneraddress,',' , '.') , 2) as City
,parsename(replace(owneraddress,',' , '.') , 1) as State
from NashvilleHousing

Alter Table NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Alter Table NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Alter Table NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitAddress = parsename(replace(owneraddress,',' , '.') , 3)


Update NashvilleHousing
Set OwnerSplitCity = parsename(replace(owneraddress,',' , '.') , 2) 


Update NashvilleHousing
Set OwnerSplitState = parsename(replace(owneraddress,',' , '.') , 1)



--------------------------------------------------------------------------------------------------------------------------------------
--Change 1 and 0 to Yes and No in "Sold as Vacant"


select Distinct(SoldAsVacant), Count(SoldasVacant)
from NashvilleHousing
group by SoldAsVacant
order by 2

select SoldasVacant,
CASE 
	when SoldAsVacant = '1' then 'Yes'
	when SoldAsVacant = '0' then 'No'
	end
	--when 0 then 'No'
from NashvilleHousing 

Alter Table NashvilleHousing
Alter Column SoldAsVacant nvarchar(255);

Update NashvilleHousing 
Set SoldAsVacant = 
CASE 
	when SoldAsVacant = '1' then 'Yes'
	when SoldAsVacant = '0' then 'No'
END



--------------------------------------------------------------------------------------------------------------------------------------
--Removing Duplicates 



With RowNumCTE As (
select *,
	ROW_NUMBER() over (
	partition by	ParcelID, 
					PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
					Order by 
						UniqueID
						) row_num
from NashvilleHousing
--order by ParcelID
)

Delete
From RowNumCTE
where row_num > '1'

select *
from NashvilleHousing




--------------------------------------------------------------------------------------------------------------------------------------
--Delete Unused Columns



Select *
from NashvilleHousing

Alter Table NashvilleHousing
Drop Column saledate, owneraddress, taxdistrict, propertyaddress