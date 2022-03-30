/*

Data cleaning using SQL queries

Update table, use parsename to split the columns, use CTE and ROW_NUM() to remove the duplicates

*/

Select * 
from Nashville

--We notice the date format, & decide to change it 

Alter table Nashville
Add SaleDateConverted Date;

Update Nashville
SET SaleDateConverted =  CONVERT(Date, SaleDate)

--In the SoldAsVacant column, There are 4 distinct variables 'Y', 'N' & 'Yes', 'No'. We first check the count of each of the variables.

Select distinct(SoldAsVacant), COUNT(SoldAsVacant)
from Nashville
group by SoldAsVacant
order by 2

--Converting the 'Y's' to 'Yes' and 'N's' to 'No's'

Select SoldAsVacant,
CASE when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant = 'N' then 'No'
ELSE SoldAsVacant end
from Nashville 

Update Nashville
SET SoldAsVacant = CASE when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant = 'N' then 'No'
ELSE SoldAsVacant end
from Nashville 

--Successfully converted 

--Now we convert the address in the PropertyAddress column into 2 seperate fields(Address, City)

Select
--PARSENAME(REPLACE(PropertyAddress, ',', '.'),3),
PARSENAME(REPLACE(PropertyAddress, ',', '.'),2),
PARSENAME(REPLACE(PropertyAddress, ',', '.'),1)
from Nashville

Alter table Nashville
	Add PropAddress Nvarchar(255),
	City Nvarchar(255);

Update Nashville
Set PropAddress = PARSENAME(REPLACE(PropertyAddress, ',', '.'),2), City = PARSENAME(REPLACE(PropertyAddress, ',', '.'),1)


-- Now breaking the owner address into 3 separate fields (Address, City, State)

Alter table Nashville 
	Add OwnerAdd Nvarchar(255),
		OwnerCity Nvarchar(255),
		OwnerState Nvarchar(255);

Update Nashville
Set OwnerAdd = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
	OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2),
	OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

-- Let's remove the duplicates now using the CTE

WITH RowNumCTE AS(
Select *,
ROW_NUMBER() OVER(
	PARTITION BY ParcelID, SaleDate, SalePrice, LegalReference order by UniqueID) dup_rows

from Nashville 
)

Delete from RowNumCTE where dup_rows > 1 

--Since we split the address columns to make it more usable, we can delete the original columns

Alter table Nashville
Drop column PropertyAddress, OwnerAddress