Select * 
From [Portfolio Project].dbo.[NashvilleHousing ]
--------------------------------------------------------------------------------------------------------------

--Standardize Date Format 

Select SaleDateConverted , CONVERT (DATE,SaleDate)
From [Portfolio Project].dbo.[NashvilleHousing ]

UPDATE  [Portfolio Project].dbo.[NashvilleHousing ]
SET SaleDate = CONVERT (Date,SaleDate)

-------------------------------------------2nd way
ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE [Portfolio Project].dbo.[NashvilleHousing ]
SET SaleDateConverted=CONVERT(DATE,Saledate)

--DELETE COLUMN 

ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate ;


---POPULATE PROPERTY ADDRESS DATA 

Select * 
From [Portfolio Project].dbo.[NashvilleHousing ]
Where PropertyAddress is null 
order by PropertyAddress

SELECT a.ParcelID,a.PropertyAddress ,b.ParcelID,B.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
 FROM [Portfolio Project].DBO.[NashvilleHousing ] a JOIN
 [Portfolio Project].DBO.[NashvilleHousing ] b
 on a.ParcelID = b.ParcelID and
 a.[UniqueID ]<>b.[UniqueID ]
 Where a.PropertyAddress is not null

UPDATE a 
Set PropertyAddress= ISNULL(a.propertyaddress,b.propertyaddress) 
FROM [Portfolio Project].DBO.[NashvilleHousing ] a JOIN 
[Portfolio Project].DBO.[NashvilleHousing ] b
on a.ParcelID = b.ParcelID and
a.[UniqueID ]<>b.[UniqueID ]
Where a.PropertyAddress is null

----------------------------------------------------------------------------------------------------------------

-- Breaking out PropertyAddress into Individual Columns(Address, City, State )--

Select PropertyAddress from
[Portfolio Project].DBO.[NashvilleHousing ] 

Select
SUBSTRING (PropertyAddress, 1 ,CHARINDEX (',',PropertyAddress )-1) as Address ,
SUBSTRING (PropertyAddress,CHARINDEX (',',PropertyAddress )+1,LEN(PropertyAddress))
from
[Portfolio Project].DBO.[NashvilleHousing ] 


Alter Table [Portfolio Project].DBO.[NashvilleHousing ] 
ADD PropertySplitAddress Nvarchar(255);

Update [Portfolio Project].DBO.[NashvilleHousing ] 
SET PropertySplitAddress= SUBSTRING (PropertyAddress, 1 ,CHARINDEX (',',PropertyAddress )-1)


Alter Table [Portfolio Project].DBO.[NashvilleHousing ] 
ADD PropertySplitCity Nvarchar(255)

Update [Portfolio Project].DBO.[NashvilleHousing ] 
SET PropertySplitCity= SUBSTRING (PropertyAddress,CHARINDEX (',',PropertyAddress )+2,LEN(PropertyAddress))

-- Breaking out OwnerAddress into Individual Columns(Address, City, State )--

Select(PARSENAME(REPLACE(OwnerAddress,',','.'),3)) as OwnerSplitAddress,
(PARSENAME(REPLACE(OwnerAddress,',','.'),2)) as OwnerSplitCity,
(PARSENAME(REPLACE(OwnerAddress,',','.'),1)) as OwnerSplitState
from [Portfolio Project].dbo.[NashvilleHousing ]                       


Alter Table [Portfolio Project].DBO.[NashvilleHousing ] 
ADD OwnerSplitAddress Nvarchar(255);

Update [Portfolio Project].DBO.[NashvilleHousing ] 
SET OwnerSplitAddress= (PARSENAME(REPLACE(OwnerAddress,',','.'),3))

Alter Table [Portfolio Project].DBO.[NashvilleHousing ] 
ADD OwnerSplitCity Nvarchar(255)

Update [Portfolio Project].DBO.[NashvilleHousing ] 
SET OwnerSplitCity= (PARSENAME(REPLACE(OwnerAddress,',','.'),2))

Alter Table [Portfolio Project].DBO.[NashvilleHousing ] 
ADD OwnerSplitState Nvarchar(255)

Update [Portfolio Project].DBO.[NashvilleHousing ] 
SET OwnerSplitState= (PARSENAME(REPLACE(OwnerAddress,',','.'),1))


----------Change Y and N in "Sold as Vacant" Field to Yes and No -------------------


Select Distinct(SoldAsVacant) , Count (SoldAsVacant) as Counted
From [Portfolio Project].dbo.[NashvilleHousing ]
group by  SoldAsVacant  

Select SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y ' then 'Yes'
     WHEN SoldAsVacant = 'N '  then  'No'
     ELSE SoldAsVacant
END
From [Portfolio Project].dbo.[NashvilleHousing ]

UPDATE [Portfolio Project].dbo.[NashvilleHousing ]
SET SoldAsVacant = 
CASE WHEN SoldAsVacant = 'Y ' then 'Yes'
     WHEN SoldAsVacant = 'N '  then  'No'
     ELSE SoldAsVacant
END
From [Portfolio Project].dbo.[NashvilleHousing ]



WITH CTE_RowNum  AS(
Select * ,
  ROW_NUMBER () OVER (
  PARTITION BY ParcelID,
             PropertyAddress,
			 SalePrice,
			 SaleDateConverted,
			 LegalReference
			 ORDER BY 
			    UniqueID
				)row_num

From [Portfolio Project].dbo.[NashvilleHousing ]
)
DELETE 
From  CTE_RowNum
Where row_num > 1 


 

 ---DELETE UNUSED COLUMNS---------------------------------------------------------------------------------
 
 
 Select * 
 From [Portfolio Project].dbo.[NashvilleHousing ]

 ALTER TABLE [Portfolio Project].dbo.[NashvilleHousing ]
 DROP COLUMN OwnerAddress,TaxDistrict , PropertyAddress