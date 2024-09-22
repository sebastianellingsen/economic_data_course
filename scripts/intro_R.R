## ---------------------- Introduction to R --------------------------------- ##


# R as a calculator 
3 + 5

4/2

3*3


# Assign values to variables and data types
x <- 10
y <- 20

a <- "Hello, R!"
b <- TRUE

class(a)
class(b)


# Perform arithmetic
z <- x + y


# Vectors 
c(1, 4, 6, 7, 3)



# Assigning a vector to a variable
v <- c(1, 4, 6, 7, 3)

u <- c(4, 5, 6, 2, 6)


# Accessing an element in a vector 
v[3]


# Basic functions
mean(v)

max(v)

min(v)

which.min(v)

which.max(v)

sum(v)

sd(v)

# Writing your own function 
square <- function(num) {
  return(num^2)
}

square(2)



# Plotting 
plot(v, u)


# Constructing a dataframe
df <- data.frame(u,v)

df$u

df$w <- df$u^2


# This is a comment.



# Loading data 
economic_data_uk <- read.csv("~/Dropbox/economic_data/labs/lab_1/economic_data_uk.csv")

# Applying functions to dataframes
summary(economic_data_uk)

View(economic_data_uk)

# Subsetting rows and columns
economic_data_uk <- economic_data_uk[economic_data_uk$Year>=1990,]

gdp_uk <- economic_data_uk[c('gdp_pc')]

# Plotting variables in a dataframe
plot(economic_data_uk$Year, 
     economic_data_uk$gdp_pc, 
     type = "o", 
     col = "blue",
     xlab = "Year", 
     ylab = "GDP Per Capita",
     main = "GDP Per Capita UK")




