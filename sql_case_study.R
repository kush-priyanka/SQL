# Install packages
install.packages("RMySQL")
install.packages("DBI")

# Load libraries
library(sqldf)
options(sqldf.driver ="SQLite") 
library(RMySQL)
library(DBI)

#### Use the MySQL database to query in R ####
# Create a connection between MySQL and R
mydb <- dbConnect(drv = RMySQL :: MySQL(), user = "root", password = "XXXXXX",
                  dbname = 'market', host ="localhost", port = 3306)

## Import market facts table
m <- "select * from market_fact_1"
data_sql <- dbSendQuery(mydb, m)
market_fact_df <- fetch(data_sql, n = -1)

## Import customer dimension table
c <- "select * from cust_dimen"
data_sql <- dbSendQuery(mydb, c)
cust_dimen_df <- fetch(data_sql, n = -1)

## Import product dimension table
p <- "select * from prod_dimen"
data_sql <- dbSendQuery(mydb, p)
prod_dimen_df <- fetch(data_sql, n = -1)

on.exit(dbDisconnect(mydb)) #disconnect from database


## Find which customer segment is the most profitable
cust_seg_profit <- sqldf("select customer_segment, round(sum(profit),3) as total_profit
                          from market_fact_df m, cust_dimen_df c
                          where m.cust_id=c.cust_id
                          group by customer_segment
                          order by total_profit desc;")
print(cust_seg_profit)

## Find which region is the most profitable
region_profit <- sqldf("select  sum(m.profit) as profit, c.region
                        from market_fact_df m, cust_dimen_df c
                        where m.cust_id=c.cust_id
                        group by c.region
                        having sum(m.profit) = 
                        (select max(a.profit_1)
                        from(
                        select  sum(m.profit) as profit_1
                        from market_fact_df m, cust_dimen_df c
                        where m.cust_id=c.cust_id
                        group by c.region) a );")

print(region_profit)

## Which region has most sales?
region_sales <- sqldf("select sum(m.sales) as sales, c.region
                        from market_fact_df m, cust_dimen_df c
                        where m.cust_id=c.cust_id
                        group by c.region
                        having sum(m.sales) =
                        (select max(b.sales_1)
                        from(
                        select sum(m.sales) as sales_1
                        from market_fact_df m, cust_dimen_df c
                        where m.cust_id=c.cust_id
                        group by c.region) b );")


print(region_sales)

## find the sales and profit for each product category and among each product category, 
## order by sub-category from highest to lowest
prod_details <- sqldf("select p.product_category, p.product_sub_category, round(sum(m.sales),3) as sales_2, round(sum(m.profit),3) as profit_2
                      from market_fact_df m, prod_dimen_df p
                      where m.prod_id=p.prod_id
                      group by p.product_category, p.product_sub_category
                      order by 1, 3 desc;")

print(prod_details)

## Create a new table and store product category, product sub category, profit, sales, count of customer
## profit, sales, count of customer should group by product category, product sub-category

# Create a data.frame with query result
prod_cat <- sqldf("select p.product_category, p.product_sub_category, round(sum(m.sales),3) as sales_2, round(sum(m.profit),3) as profit_2, count(c.cust_id) as customer_count
                            from market_fact_df m, prod_dimen_df p, cust_dimen_df c
                            where m.prod_id=p.prod_id
                            and c.cust_id= m.cust_id
                            group by p.product_category, p.product_sub_category
                            order by 1, 3 desc;")

# Ensure the databases are connected
dbSendQuery(mydb, "SET GLOBAL local_infile = true;")

#Write the table to database and disconnect
dbWriteTable(mydb, value = prod_cat , row.names = FALSE,
             name = "prod_info", append = TRUE)
dbDisconnect(mydb)

### Determine cost price paid by each customer based on market fact data 
### and store in cust_dimen table

# Calculate the cost for each customer
cust_cost <- sqldf("select cust_id, round(sum(round(ifnull(sales,0)-ifnull(profit,0) + ifnull(discount,0), 4)), 4) as cost_price
                   from market_fact_df
                   group by cust_id;")

# Now add the column to the existing dataset
dbWriteTable(mydb, "cust_dimen", merge(cust_dimen_df, cust_cost, by = "Cust_id", all.x = TRUE),
             row.name = FALSE, overwrite = T)
