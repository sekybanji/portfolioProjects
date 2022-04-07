USE [portifolio Project]
select *
from NashvilleHousing

--Standardize date format 

select SaleDateconverted, CONVERT(DATE, SaleDate)
from [portifolio Project].dbo.NashvilleHousing

Alter table [portifolio Project].dbo.NashvilleHousing
add saledateconverted date;

update NashvilleHousing
set SaleDateconverted = CONVERT(date,saledate)

--polulate property address

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.propertyAddress,b.PropertyAddress)
from [portifolio Project].dbo.NashvilleHousing a
join [portifolio Project].dbo.NashvilleHousing b
on a.ParcelID=b.ParcelID
And a.[UniqueID ] <> b.[UniqueID ]
--where a.PropertyAddress is null

update a
set a.PropertyAddress = ISNULL(a.propertyAddress,b.PropertyAddress)
from [portifolio Project].dbo.NashvilleHousing a
join [portifolio Project].dbo.NashvilleHousing b
on a.ParcelID=b.ParcelID
And a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--Breaking out addresses into individual columns (address, city, state)
-- Finding he delimiter ','

select 
SUBSTRING(propertyAddress, 1, charindex(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,charindex(',',propertyaddress)+1,len(propertyAddress)) as City

from [portifolio Project].dbo.NashvilleHousing

Alter table [portifolio Project].dbo.NashvilleHousing
Add Address nvarchar(255);

update [portifolio Project].dbo.NashvilleHousing
Set Address = SUBSTRING(propertyAddress, 1, charindex(',',PropertyAddress)-1) 


Alter table [portifolio Project].dbo.NashvilleHousing
Add City nvarchar(255);

update [portifolio Project].dbo.NashvilleHousing
set City = SUBSTRING(PropertyAddress,charindex(',',propertyaddress)+1,len(propertyAddress))

select *
from [portifolio Project].dbo.NashvilleHousing

--parsename

SELECT 
parsename(replace(owneraddress, ',','.'),3),
parsename(replace(owneraddress, ',','.'),2),
parsename(replace(owneraddress, ',','.'),1)
from [portifolio Project].dbo.NashvilleHousing



alter table [portifolio Project].dbo.NashvilleHousing
add OwnerSplitAddress nvarchar(255);

Update [portifolio Project].dbo.NashvilleHousing
set OwnerSplitAddress = parsename(replace(owneraddress, ',','.'),3)

alter table [portifolio Project].dbo.NashvilleHousing
add OwnerCity nvarchar(255);

Update [portifolio Project].dbo.NashvilleHousing
set OwnerCity = parsename(replace(owneraddress, ',','.'),2)


alter table [portifolio Project].dbo.NashvilleHousing
add OwnerState nvarchar(255);

Update [portifolio Project].dbo.NashvilleHousing
set OwnerState = parsename(replace(owneraddress, ',','.'),1)

select *
from [portifolio Project].dbo.NashvilleHousing

-- Change Y and N to 'yes' and 'No' in soldAsVacant field

select Distinct(SoldAsVacant), count(SoldAsVacant)
from [portifolio Project].dbo.NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant, 
case when SoldAsVacant = 'Y' then 'Yes'
     when SoldAsVacant = 'N' then 'No'
	 ELSE SoldASVacant
	 END
from [portifolio Project].dbo.NashvilleHousing

update [portifolio Project].dbo.NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
     when SoldAsVacant = 'N' then 'No'
	 ELSE SoldASVacant
	 END

-- Remove Duplicates 
--cte

with ROWNumCTE as(
select *,
row_number() over (
partition by ParcelID,PropertyAddress, SaleDate, SalePrice, LegalReference order by UniqueID) row_num
from [portifolio Project].dbo.NashvilleHousing
--order by ParcelID
)
delete  
from ROWNumCTE
where row_num > 1 
--order by PropertyAddress

--Delete Unused Columns 

ALTER TABLE  [portifolio Project].dbo.NashvilleHousing
drop Column  OwnerAddress, TaxDistrict, PropertyAddress,SaleDate
select * 
from [portifolio Project].dbo.NashvilleHousing