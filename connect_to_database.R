# Load libraries
install.packages("RMySQL")
install.packages("DBI")
library(sqldf)
options(sqldf.driver ="SQLite") 
library(RMySQL)
library(DBI)

#### Use the MySQL database to query in R ####
# Create a connection between MySQL and R
mydb <- dbConnect(drv = RMySQL :: MySQL(), user = "root", password = "XXXXXX",
                  dbname = 'company', host ="localhost", port = 3306)

## Import employee table
e <- "select * from employee"
data_sql <- dbSendQuery(mydb, e)
emp_df <- fetch(data_sql, n = -1)

## Import department table
d <- "select * from department"
data_sql <- dbSendQuery(mydb, d)
department_df <- fetch(data_sql, n = -1)

on.exit(dbDisconnect(mydb)) #disconnect from database

# Join the two tables
emp_Depart <- sqldf("select * from emp_df e, department_df d
                    where e.dno=d.dnumber;")

emp_Depart

# Count employees in each department
emp_count_Dep <- sqldf("select dname, count(*) from emp_Depart group by dname;") 
# or
# emp_count_Dep <-sqldf("select count(*) as cnt, dname from emp_Depart group by dname;")


##### Create a table and add it to the MySQL database ####
create_emp <- "create table check_info (el_city text, el_street text, el_age float)"
data_sql <- dbSendQuery(mydb, create_emp)

insert_emp <- "insert into check_info(el_city, el_street, el_age)
                    values ('London', 'Charles street', 24),
                          ('Mumbai', 'Santa Cruz', 25)";
                          
data_sql <- dbSendQuery(mydb, insert_emp)    


