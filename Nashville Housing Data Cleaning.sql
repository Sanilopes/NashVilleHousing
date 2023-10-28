--Cleaning Data

Select *
From DataCleaning..CleaningSample

--Standardize Date Format

Select SaleDateConverted, Convert(Date,SaleDate)
From DataCleaning..CleaningSample

Update CleaningSample
Set SaleDate = Convert(Date,SaleDate)

Alter Table CleaningSample
Add SaleDateConverted Date;
Update CleaningSample
Set SaleDateConverted = Convert(Date,SaleDate)


--Populate Property Address Data

Select PropertyAddress
From DataCleaning..CleaningSample

Select *
From DataCleaning..CleaningSample
Where PropertyAddress is null

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From DataCleaning..CleaningSample a
Join DataCleaning..CleaningSample b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From DataCleaning..CleaningSample a
Join DataCleaning..CleaningSample b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

-- Breaking out address into Individual Columns (Address, City, State)

--Using Substring

Select PropertyAddress
From DataCleaning..CleaningSample

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, Len(PropertyAddress)) as City
From DataCleaning..CleaningSample

Alter Table CleaningSample
Add PropAddress nvarchar(255);
Update CleaningSample
Set PropAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) 

Alter Table CleaningSample
Add City nvarchar(255);
Update CleaningSample
Set City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, Len(PropertyAddress))

--Using PARSENAME

Select OwnerAddress
From DataCleaning..CleaningSample

Select 
Parsename(Replace(OwnerAddress, ',', '.'), 3),  
Parsename(Replace(OwnerAddress, ',', '.'), 2),  
Parsename(Replace(OwnerAddress, ',', '.'), 1)  
From DataCleaning..CleaningSample

Alter Table CleaningSample
Add SplitAddress nvarchar(255);
Update CleaningSample
Set SplitAddress = Parsename(Replace(OwnerAddress, ',', '.'), 3)

Alter Table CleaningSample
Add SplitCity nvarchar(255);
Update CleaningSample
Set SplitCity = Parsename(Replace(OwnerAddress, ',', '.'), 2)

Alter Table CleaningSample
Add SplitState nvarchar(255);
Update CleaningSample
Set SplitState = Parsename(Replace(OwnerAddress, ',', '.'), 1)

Select *
From DataCleaning..CleaningSample

--Changing Y and N to Yes and NO in the "Sold as Vacant" 

Select Distinct(SoldasVacant)
From DataCleaning..CleaningSample

Select SoldAsVacant,
Case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	Else SoldAsVacant
End
From DataCleaning..CleaningSample

Update CleaningSample
Set SoldAsVacant = Case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	Else SoldAsVacant
	END


-- Removing Duplicates 


With Duplicates as (
Select *,
	ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY UniqueID) as row_num
FROM DataCleaning..CleaningSample )

Select *
From Duplicates
where row_num > 1


--Deleting Unused Columns

Select *
From DataCleaning..CleaningSample

Alter Table DataCleaning..CleaningSample
Drop Column OwnerAddress, TaxDistrict, PropertyAddress

Alter Table DataCleaning..CleaningSample
Drop Column SaleDate
