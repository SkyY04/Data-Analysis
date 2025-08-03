select *
from portfolio..NashvilleHousing

-- 1. Standardize Date Format
select SaleDate, CONVERT(date,SaleDate)
from portfolio..NashvilleHousing

update NashvilleHousing
set SaleDate=CONVERT(date,SaleDate)


-- 2. Populate Property Address Data
	-- populate null value of property address from the same parcelID value
select *
from portfolio..NashvilleHousing
where PropertyAddress is null

select a.ParcelID, a.PropertyAddress, b.ParcelID,b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
from portfolio..NashvilleHousing a
join portfolio..NashvilleHousing b
	on a.ParcelID=b.ParcelID
	and a.[UniqueID]<>b.[UniqueID]
where a.PropertyAddress is null

update a
set PropertyAddress= isnull(a.PropertyAddress, b.PropertyAddress)
from portfolio..NashvilleHousing a
join portfolio..NashvilleHousing b
	on a.ParcelID=b.ParcelID
	and a.[UniqueID]<>b.[UniqueID]
where a.PropertyAddress is null


-- 3. Break out Adress into individual columns
	-- PropertyAddress: Address, City
	-- Comma (,) delimiter
select PropertyAddress
from portfolio..NashvilleHousing

select
substring(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
substring(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, len(PropertyAddress)) as City
from portfolio..NashvilleHousing

alter table NashvilleHousing
add PropertyAddressStreet Nvarchar(255);

update NashvilleHousing
set PropertyAddressStreet=substring(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

alter table NashvilleHousing
add PropertyAddressCity Nvarchar(255);

update NashvilleHousing
set PropertyAddressCity=substring(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, len(PropertyAddress))

	--OwnerAddress: Address, City, State
select
PARSENAME(replace(OwnerAddress,',','.'),3),
PARSENAME(replace(OwnerAddress,',','.'),2),
PARSENAME(replace(OwnerAddress,',','.'),1)
from portfolio..NashvilleHousing

alter table NashvilleHousing
add OwnerAddressStreet Nvarchar(255);

update NashvilleHousing
set OwnerAddressStreet=PARSENAME(replace(OwnerAddress,',','.'),3)

alter table NashvilleHousing
add OwnerAddressCity Nvarchar(255);

update NashvilleHousing
set OwnerAddressCity=PARSENAME(replace(OwnerAddress,',','.'),2)

alter table NashvilleHousing
add OwnerAddressState Nvarchar(255);

update NashvilleHousing
set OwnerAddressState=PARSENAME(replace(OwnerAddress,',','.'),1)

select*
from portfolio..NashvilleHousing


-- 4. Change 1 to Yes and 0 to No in "SoldAsVacant" field
select distinct(SoldAsVacant)
from portfolio..NashvilleHousing

select SoldAsVacant,
case when SoldAsVacant=1 then 'Yes'
	when SoldAsVacant=0 then 'No'
	end
from portfolio..NashvilleHousing

ALTER TABLE NashvilleHousing
ALTER COLUMN SoldAsVacant VARCHAR(3);

update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant=1 then 'Yes'
	when SoldAsVacant=0 then 'No'
	else SoldAsVacant
	end


-- 5. Remove Duplicates
with RowNumCTE as (
select *,
	ROW_NUMBER() over(
	partition by parcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				order by UniqueID
				) row_num

from portfolio..NashvilleHousing
)
delete
from RowNumCTE
where row_num>1


-- 6. Delete Unused Columns
alter table NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress
alter table NashvilleHousing
drop column SaleDate

select *
from portfolio..NashvilleHousing