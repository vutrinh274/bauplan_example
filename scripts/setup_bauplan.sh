#!/bin/bash

if [ "$#" -lt 2 ]; then
    echo "Usage: $0 <bucket name> <bauplan branch>"
    exit 1
fi


# Create branch + namespace
bauplan branch create "$2"
bauplan branch checkout "$2"
bauplan namespace create adventure

# Upload table
bauplan table create --branch "$2" --name adventure.product --search-uri s3://"$1"/AdventureWorks_Products.csv
bauplan table create --branch "$2" --name adventure.product_category --search-uri s3://"$1"/AdventureWorks_Product_Categories.csv
bauplan table create --branch "$2" --name adventure.product_subcategory --search-uri s3://"$1"/AdventureWorks_Product_Subcategories.csv
bauplan table create --branch "$2" --name adventure.sale --search-uri s3://"$1"/AdventureWorks_Sales_2017.csv
bauplan table create --branch "$2" --name adventure.territories --search-uri s3://"$1"/AdventureWorks_Territories.csv

bauplan table import --branch "$2" --name adventure.product --search-uri s3://"$1"/AdventureWorks_Products.csv
bauplan table import --branch "$2" --name adventure.product_category --search-uri s3://"$1"/AdventureWorks_Product_Categories.csv
bauplan table import --branch "$2" --name adventure.product_subcategory --search-uri s3://"$1"/AdventureWorks_Product_Subcategories.csv
bauplan table import --branch "$2" --name adventure.sale --search-uri s3://"$1"/AdventureWorks_Sales_2017.csv
bauplan table import --branch "$2" --name adventure.territories --search-uri s3://"$1"/AdventureWorks_Territories.csv
