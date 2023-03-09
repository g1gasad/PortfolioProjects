/*

Cleaning data in SQL querry

*/


select *
from PortfolioProject.dbo.NashvilleHousing


--Standardize date format

select SaleDate, convert(date, SaleDate)
from PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
set SaleDate = convert(date, SaleDate)

--DIFFERENT APPROACH

ALTER table NashvilleHousing
add SaleDateConverted date;

update NashvilleHousing
SET SaleDateConverted = convert(date, SaleDate)


select SaleDateConverted
from PortfolioProject.dbo.NashvilleHousing



--Populate property address data

select *
from PortfolioProject.dbo.NashvilleHousing
--where PropertyAddress is null
order by ParcelID



select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing as a
join PortfolioProject.dbo.NashvilleHousing as b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] != b.[UniqueID ]
where a.PropertyAddress is null


update a
set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing as a
join PortfolioProject.dbo.NashvilleHousing as b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] != b.[UniqueID ]
where a.PropertyAddress is null


--Breaking out address into individual columns (Address, City, State)

SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing
--where PropertyAddress is null


SELECT 
substring(PropertyAddress, 1, charindex(',', PropertyAddress) - 1) as Address,
substring(PropertyAddress, charindex(',', PropertyAddress) + 1, len(PropertyAddress)) as Address
FROM PortfolioProject.dbo.NashvilleHousing



alter table NashvilleHousing
add PropertySplitAddress nvarchar(255);

update NashvilleHousing
set PropertySplitAddress = substring(PropertyAddress, 1, charindex(',', PropertyAddress) - 1)

alter table NashvilleHousing
add PropertyCityAddress nvarchar(255);

update NashvilleHousing
set PropertyCityAddress = substring(PropertyAddress, charindex(',', PropertyAddress) + 1, len(PropertyAddress))


select *
from PortfolioProject.dbo.NashvilleHousing






select OwnerAddress
from PortfolioProject.dbo.NashvilleHousing


--BREAKING THE OWNER ADDRESS APART

select
parsename(replace(OwnerAddress, ',', '.'),3),
parsename(replace(OwnerAddress, ',', '.'),2),
parsename(replace(OwnerAddress, ',', '.'),1)
from PortfolioProject.dbo.NashvilleHousing




alter table NashvilleHousing
add OwnerSplitAddress nvarchar(255);

update NashvilleHousing
set OwnerSplitAddress = parsename(replace(OwnerAddress, ',', '.'),3)


alter table NashvilleHousing
add OwnerCityAddress nvarchar(255);

update NashvilleHousing
set OwnerCityAddress = parsename(replace(OwnerAddress, ',', '.'),2)


alter table NashvilleHousing
add OwnerStateAddress nvarchar(255);

update NashvilleHousing
set OwnerStateAddress = parsename(replace(OwnerAddress, ',', '.'),1)




select *
from PortfolioProject.dbo.NashvilleHousing




------------------------------------------

--Change Y and N as yes and no in "Sold as vacant" field


select distinct SoldAsVacant, count(SoldAsVacant)
from PortfolioProject.dbo.NashvilleHousing
group by SoldAsVacant
order by 2




select SoldAsVacant,
	   CASE
			when SoldAsVacant = 'Y' then 'Yes'
			when SoldAsVacant = 'N' then 'No'
			else SoldAsVacant	
			end
from PortfolioProject.dbo.NashvilleHousing

--updating directly into the data unlike earlier

update NashvilleHousing
set SoldAsVacant = CASE
			when SoldAsVacant = 'Y' then 'Yes'
			when SoldAsVacant = 'N' then 'No'
			else SoldAsVacant	
			end




----------------------------------------------

--Remove Duplicates
with RowNumCTE as
(
select *,
	   ROW_NUMBER() over
					(
					partition by ParcelID,
								 PropertyAddress,
								 SaleDate,
								 LegalReference,
								 SalePrice
					order by UniqueID
					) as row_num
from PortfolioProject.dbo.NashvilleHousing
--order by ParcelID
--the where clause wont work here so we need to turn it into cte
) 
select *
--delete
from RowNumCTE
where row_num > 1
--order by PropertyAddress



select *
from PortfolioProject.dbo.NashvilleHousing




---------------------------------

--Delete unused columns


select *
from PortfolioProject.dbo.NashvilleHousing

alter table PortfolioProject.dbo.NashvilleHousing
drop column PropertyAddress, SaleDate, TaxDistrict, OwnerAddress