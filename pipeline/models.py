import bauplan


@bauplan.python("3.11", pip={"duckdb": "1.0.0"})
@bauplan.model(materialization_strategy="REPLACE")
def dim_product(
    product=bauplan.Model("adventure.product"),
    product_category=bauplan.Model("adventure.product_category"),
    product_subcategory=bauplan.Model("adventure.product_subcategory"),
):
    import duckdb

    con = duckdb.connect()
    query = """
        SELECT
            md5(CAST(product.ProductKey as VARCHAR)) as product_key,
            product.ProductName as product_name,
            product.ProductSKU as product_sku,
            product.ProductColor as product_color,
            product_subcategory.SubcategoryName as product_subcategory_name,
            product_category.CategoryName as product_category_name,
        FROM product
        LEFT JOIN product_subcategory
            ON product.ProductSubcategoryKey = product_subcategory.ProductSubcategoryKey
        LEFT JOIN product_category
            ON product_subcategory.ProductCategoryKey = product_category.ProductCategoryKey;
    """
    data = con.execute(query).arrow()

    return data

@bauplan.python("3.11", pip={"duckdb": "1.0.0"})
@bauplan.model(materialization_strategy="REPLACE")
def dim_country(
    territories=bauplan.Model("adventure.territories")
):
    import duckdb

    con = duckdb.connect()
    query = """
        SELECT
            DISTINCT
            md5(territories.Country) as country_key,
            country,
            continent
        FROM territories
    """
    data = con.execute(query).arrow()

    return data


@bauplan.python("3.11", pip={"duckdb": "1.0.0"})
@bauplan.model(materialization_strategy="REPLACE")
def fact_sale(
    sale=bauplan.Model("adventure.sale"), product=bauplan.Model("adventure.product"), territories=bauplan.Model("adventure.territories")
):
    import duckdb

    con = duckdb.connect()
    query = """
        SELECT
            CAST(STRPTIME(sale.OrderDate, '%m/%d/%Y') AS DATE) AS order_date,
            sale.OrderNumber as order_number,
            md5(CAST(product.ProductKey as VARCHAR)) as product_key,
            md5(territories.Country) as country_key,
            (sale.OrderQuantity * product.ProductPrice) as revenue,
            (sale.OrderQuantity * product.ProductCost) as cost,
            (sale.OrderQuantity * product.ProductPrice) - (sale.OrderQuantity * product.ProductCost) as profit,
        FROM sale
        LEFT JOIN product
            ON sale.ProductKey = product.ProductKey
        LEFT JOIN territories
            ON sale.TerritoryKey = territories.SalesTerritoryKey
    """
    data = con.execute(query).arrow()

    return data
