install.packages('sqldf')

library(sqldf)
library(ggplot2)
library(ggpubr)
#options(sqldf.driver ="SQLite")

#### Example of SQL queries- import datafiles ####
## Import datasets

market_fact <- read.csv("market_fact.csv", stringsAsFactors =F)
cust_dimen <- read.csv("cust_dimen.csv", stringsAsFactors =F)
prod_dimen <- read.csv("prod_dimen.csv", stringsAsFactors =F)
shipping_dimen <- read.csv("shipping_dimen.csv", stringsAsFactors =F)
orders_dimen <- read.csv("orders_dimen.csv", stringsAsFactors =F)

str(market_fact)

## Subset data using query profit is between 0 & 1000
market_fact_1 <- sqldf("select * from market_fact 
                       where profit between 0 and 1000;")

## Plot the data
ggplot(market_fact_1, 
       aes(x = market_fact_1$Prod_id)) +
         geom_bar()+
  theme(axis.text.x = element_text(angle = 90,
                                  hjust = 1, vjust = 0.5),
        legend.position = "none")


## Subset data using query profit is between 0 & 1000 but display product category 
market_fact_prod <- sqldf("select * from market_fact m, prod_dimen p
                          where p.prod_id=m.prod_id and profit between 0 and 1000;")

colnames(market_fact_prod)[13] <- 'Prod.id'

# Plot product counts
ggplot(market_fact_prod, 
       aes(x = market_fact_prod$Product_Category)) +
  geom_bar(fill = "#0073C2FF") +
  xlab("Product Category") +
  theme(axis.text.x = element_text(angle = 90,
                                   hjust = 1, vjust = 0.5),
        legend.position = "none") +
  theme_pubclean() +
  ggtitle("Product Category")

# Plot Sales distribution using boxplot
ggplot(market_fact_prod, 
       aes(x = market_fact_prod$Product_Category,
           y= market_fact_prod$Sales)) +
  geom_boxplot(fill = "#0073C2FF") +
  xlab("Product Category") +
  ylab("Sales") +
  theme(axis.text.x = element_text(angle = 90,
                                   hjust = 1, vjust = 0.5),
        legend.position = "none") +
  theme_pubclean() +
  ggtitle("Sales distribution")

# Plot Profit using boxplot
ggplot(market_fact_prod, 
       aes(x = market_fact_prod$Product_Category,
           y= market_fact_prod$Profit)) +
  geom_boxplot(fill = "orange") +
  xlab("Product Category") +
  ylab("Profit") +
  theme(axis.text.x = element_text(angle = 90,
                                   hjust = 1, vjust = 0.5),
        legend.position = "none") +
  theme_pubclean() +
  ggtitle("Profit")

## Subset data using query profit is between 0 & 5000 but display product category
market_fact_prod1 <- sqldf("select * from market_fact m, prod_dimen p
                          where p.prod_id=m.prod_id and profit between 0 and 5000;")

colnames(market_fact_prod1)[13] <- 'Prod.id'

# Plot Sales distribution using boxplot
ggplot(market_fact_prod1, 
       aes(x = market_fact_prod1$Product_Category,
           y = market_fact_prod1$Sales)) +
  geom_boxplot(fill = "orange") +
  xlab("Sales distribution") +
  ylab("Sales") +
  theme(axis.text.x = element_text(angle = 90,
                                   hjust = 1, vjust = 0.5),
        legend.position = "none") +
  theme_pubclean() +
  ggtitle("Product Category")

# Plot a histogram for Sales distribution
ggplot(market_fact_prod1, 
       aes(x = Sales)) +
  geom_histogram(bins = 40,
                 color = "black",
                   fill = "#0073C2FF") +
  geom_vline(aes(xintercept = mean(Sales)),
             linetype = "dashed", size =0.6) +
  xlab("Sales") +
  ggtitle("Sales distribution")



