drop table if exists nashvillehousing;
create table nashvillehousing
(
UniqueID integer,	ParcelID varchar,	LandUse	varchar,
PropertyAddress	varchar , SaleDate varchar	, SalePrice varchar	, LegalReference varchar, 
SoldAsVacant	varchar , OwnerName varchar, 	OwnerAddress varchar, 	Acreage	float,
TaxDistrict varchar,	LandValue	integer, BuildingValue integer,	TotalValue	integer,
YearBuilt integer,	Bedrooms	integer, FullBath	integer, HalfBath integer
);

copy nashvillehousing 
from 'D:\projects\sql\Nashville housing\nashvillehousing.csv' 
delimiter ',' csv header;

select * from nashvillehousing;

-----------------------------------------------------------------------------------------------------------------------------------
/*

Cleaning Data in SQL Queries

*/


Select *
From NashvilleHousing;

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format


Select Cast(SaleDate as date)
From NashvilleHousing;


Update NashvilleHousing
SET SaleDate = Cast(SaleDate as date);

select saledate from NashvilleHousing;

-- If it doesn't Update properly

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = Cast(SaleDate as date);


 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

Select *
From NashvilleHousing
Where PropertyAddress is null
order by ParcelID;



Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, COALESCE(a.PropertyAddress,b.PropertyAddress)
From NashvilleHousing a
JOIN NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
Where a.PropertyAddress is null


Update NashvilleHousing
SET PropertyAddress =  COALESCE(a.PropertyAddress,b.PropertyAddress)
From NashvilleHousing a
JOIN NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
Where a.PropertyAddress is null


select Propertyaddress from nashvillehousing;

--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)


Select PropertyAddress
From NashvilleHousing;
--Where PropertyAddress is null
--order by ParcelID

select Position(',' in  PropertyAddress) from nashvillehousing;

SELECT
SUBSTRING(PropertyAddress, 1, Position(',' in  PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, Position(',' in  PropertyAddress) +1 , Length(PropertyAddress)) as Address

From NashvilleHousing;


ALTER TABLE NashvilleHousing
Add PropertySplitAddress varchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, Position(',' in  PropertyAddress) -1);


ALTER TABLE NashvilleHousing
Add PropertySplitCity varchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, Position(',' in  PropertyAddress) +1 , Length(PropertyAddress));



Select *
From NashvilleHousing;



Select OwnerAddress
From NashvilleHousing;

select owneraddress,
split_part(owneraddress,',',1),
split_part(owneraddress,',',2),
split_part(owneraddress,',',3) 
from nashvillehousing;

Select
split_part(owneraddress,',',1),
split_part(owneraddress,',',2),
split_part(owneraddress,',',3) 
From NashvilleHousing
where owneraddress is not null;



ALTER TABLE NashvilleHousing
Add OwnerSplitAddress varchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = split_part(owneraddress,',',1);


ALTER TABLE NashvilleHousing
Add OwnerSplitCity varchar(255);

Update NashvilleHousing
SET OwnerSplitCity = split_part(owneraddress,',',2);



ALTER TABLE NashvilleHousing
Add OwnerSplitState varchar(255);

Update NashvilleHousing
SET OwnerSplitState =split_part(owneraddress,',',3);



Select *
From NashvilleHousing
order by uniqueid;




--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From NashvilleHousing
Group by SoldAsVacant
order by 2




Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From NashvilleHousing;


Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END






-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER ( PARTITION BY ParcelID,PropertyAddress,SalePrice,SaleDate,LegalReference ORDER BY UniqueID) row_num
From NashvilleHousing
--order by ParcelID
)
delete from RowNumCTE
Where row_num > 1;
-- Order by PropertyAddress



Select *
From NashvilleHousing




---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns



Select *
From NashvilleHousing


ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress,DROP COLUMN  PropertyAddress, DROP COLUMN SaleDate;


































