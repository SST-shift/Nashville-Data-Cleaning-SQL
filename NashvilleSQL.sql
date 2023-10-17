--view the data
select * from ['Nashville Housing$'] 

--update the format
Update ['Nashville Housing$']
set SaleDate = CONVERT(DATE, SaleDate)

--property address data cleaning and updating
select * from ['Nashville Housing$'] where PropertyAddress is Null order by [ParcelID] 

--lets check if we can fill the values of blank property address
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) as Newpropertyaddress
FROM ['Nashville Housing$'] a
JOIN ['Nashville Housing$'] b 
     ON a.ParcelID = b.parcelID 
     AND a.[UniqueID ] <> b.[UniqueID ] 
WHERE a.PropertyAddress is null

--once its done, lets update it
Update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM ['Nashville Housing$'] a
JOIN ['Nashville Housing$'] b 
     ON a.ParcelID = b.parcelID 
     AND a.[UniqueID ] <> b.[UniqueID ] 
WHERE a.PropertyAddress is null

--let's seperate by propertyaddress address, city etc

select propertyaddress from ['Nashville Housing$']

select 
SUBSTRING(Propertyaddress, 1, CHARINDEX(',', Propertyaddress)-1) as Address
, SUBSTRING(Propertyaddress, CHARINDEX(',', Propertyaddress) + 1 , LEN(Propertyaddress)) as Address
from ['Nashville Housing$']

--now lets update it

Alter table ['Nashville Housing$']
Add PropertySplitAddress nvarchar(255)

Alter table ['Nashville Housing$']
Add PropertySplitCity nvarchar(255)

Update ['Nashville Housing$']
set PropertySplitAddress = SUBSTRING(Propertyaddress, 1, CHARINDEX(',', Propertyaddress)-1)

Update ['Nashville Housing$']
set PropertySplitCity = SUBSTRING(Propertyaddress, CHARINDEX(',', Propertyaddress) + 1 , LEN(Propertyaddress))

--now lets split owner's address in simpler way

select owneraddress from ['Nashville Housing$']

Select 
Parsename(Replace(OwnerAddress, ',', '.') , 3) 
, Parsename(Replace(OwnerAddress, ',', '.') , 2)
, Parsename(Replace(OwnerAddress, ',', '.') , 1)
from ['Nashville Housing$']

Alter table ['Nashville Housing$']
Add OwnerSplitAddress nvarchar(255)

Alter table ['Nashville Housing$']
Add OwnerSplitCity nvarchar(255)

Alter table ['Nashville Housing$']
Add OwnerSplitState nvarchar(255)

Update ['Nashville Housing$']
set OwnerSplitAddress = Parsename(Replace(OwnerAddress, ',', '.') , 3)

Update ['Nashville Housing$']
set OwnerSplitCity = Parsename(Replace(OwnerAddress, ',', '.') , 2)

Update ['Nashville Housing$']
set OwnerSplitState = Parsename(Replace(OwnerAddress, ',', '.') , 1)

select * from ['Nashville Housing$']

--lets clean soldasvacant column values

 select distinct(soldasvacant), count(soldasvacant)
 from ['Nashville Housing$']
 group by soldasvacant
 order by 2

select soldasvacant
, case when soldasvacant = 'Y' then 'Yes'
       when soldasvacant = 'N' then 'No'
	   else soldasvacant
	   end
from ['Nashville Housing$']

Update ['Nashville Housing$']
set SoldAsVacant = case when soldasvacant = 'Y' then 'Yes'
                   when soldasvacant = 'N' then 'No'
	               else soldasvacant
	               end

---remove duplicates & unused columns//

with RowNumCTE as(
select *, 
   ROW_NUMBER() over (
   partition by ParcelID,
                propertyaddress,
			    saleprice,
			    saledate,
			    legalreference
			    order by
			       uniqueID
				   ) row_num
from ['Nashville Housing$']
--order by parcelID
)
select *
from RowNumCTE
where row_num >1
order by PropertyAddress

--great 992201 rows deleted, now we are left with 56,374 rows!

--now lets delete the columns not required for our further visualization!

select * from ['Nashville Housing$']

alter table ['Nashville Housing$']
drop column PropertyAddress, OwnerAddress, TaxDistrict

---lets filter the data to nashville data

select propertysplitcity from ['Nashville Housing$']
--where propertysplitcity = '%Nashville%'

with CTE as(
select *, 
   ROW_NUMBER() over (
   partition by ParcelID,
			    saleprice,
			    saledate,
			    propertysplitcity
			    order by
			       uniqueID
				   ) row_num
from ['Nashville Housing$']
--order by parcelID
)
select *
from CTE
where propertysplitcity = "Nashville"
order by uniqueID

