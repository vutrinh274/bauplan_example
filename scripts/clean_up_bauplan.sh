#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <bauplan branch>"
    exit 1
fi

echo "Deleting namespace's table"

bauplan table delete --branch "$1" adventure.product
bauplan table delete --branch "$1" adventure.product_category
bauplan table delete --branch "$1" adventure.product_subcategory
bauplan table delete --branch "$1" adventure.sale
bauplan table delete --branch "$1" adventure.territories
bauplan table delete --branch "$1" adventure.fact_sale
bauplan table delete --branch "$1" adventure.dim_product
bauplan table delete --branch "$1" adventure.dim_country

echo "Deleting namespace"
bauplan namespace delete adventure