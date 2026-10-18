## ---------------------- Functions in R ------------------------------------ ##


# A function takes an input, does something with it, and returns an output.
# We have already used functions. For example:

x <- c(1, 3, 5, 7, 9)

mean(x)
sum(x)
length(x)


# Here, mean() is the function and x is the input (called an argument).


# Functions can take more than one argument.

round(3.14159, 2)


# The first argument is the number, the second is how many decimal places.
# To see what arguments a function takes, use the help page:

?round


## ---------------------- Writing your own function ------------------------- ##


# We can write our own functions.
# The syntax is:
#
#   name <- function(argument) {
#     body
#   }


# A simple example: a function that doubles a number.

double <- function(x) {
  x * 2
}

double(5)
double(100)


# A function that squares a number.

square <- function(x) {
  x^2
}

square(3)
square(10)


# A function with two arguments: adds two numbers together.

add <- function(a, b) {
  a + b
}

add(3, 4)
add(100, 200)


## ---------------------- An economics example ------------------------------ ##


# A function that computes the growth rate between two values.

growth_rate <- function(x_now, x_before) {
  100 * (x_now / x_before - 1)
}

growth_rate(110, 100)

growth_rate(95, 100)


# We can use this with GDP values.

gdp_2019 <- 350
gdp_2023 <- 400

growth_rate(gdp_2023, gdp_2019)


# Functions are vectorised: they apply to every element of a vector.

gdp_2019 <- c(100, 200, 150, 300,  80)
gdp_2023 <- c(110, 195, 165, 330,  75)

growth_rate(gdp_2023, gdp_2019)


## ---------------------- Default arguments --------------------------------- ##


# We can give an argument a default value.
# If the user does not supply it, the default is used.

growth_rate_rounded <- function(x_now, x_before, digits = 2) {
  g <- 100 * (x_now / x_before - 1)
  round(g, digits)
}

growth_rate_rounded(110, 100)            # uses default: 2 decimal places
growth_rate_rounded(110, 100, digits = 4)


## ---------------------- Using functions with data frames ------------------ ##


# Functions work naturally with columns in a data frame.

df <- data.frame(
  country  = c("Norway", "Germany", "Spain", "France", "Greece"),
  gdp_2019 = c(100, 200, 150, 300, 80),
  gdp_2023 = c(110, 195, 165, 330, 75)
)

df$growth <- growth_rate(df$gdp_2023, df$gdp_2019)

df

# Which country grew the fastest?
df$country[which.max(df$growth)]

# Which country shrank?
df$country[df$growth < 0]
