## ---------------------- Classes and Dates in R ----------------------------- ##


# Every object in R has a class. The class tells R what kind of object it is
# and determines what you can do with it. Functions might only work, or work
# differently on different classes of objects. Class is a "fancy" word for type.


## ---------------------- Basic classes -------------------------------------- ##


# Numeric: ordinary numbers

gdp <- 45000
class(gdp)


# Character: text (always in quotes)

country <- "United Kingdom"
class(country)


# Logical: TRUE or FALSE

is_developed <- TRUE
class(is_developed)



# Vectors inherit the class of their elements.

gdp_vec <- c(45000, 38000, 27000, 52000)
class(gdp_vec)

country_vec <- c("UK", "France", "Spain", "Norway")
class(country_vec)


## ---------------------- class() and is.*() --------------------------------- ##


# Use class() to inspect any object.

x <- 3.14
class(x)

y <- "inflation"
class(y)


# You can also test for a specific class.

is.numeric(x)
is.character(x)

is.numeric(y)
is.character(y)


## ---------------------- Functions behave differently by class -------------- ##


# The same function can give a different result depending on the class of its
# input. This is one of the most important things to understand about R.


# summary() on a numeric vector gives statistics.

gdp_vec <- c(45000, 38000, 27000, 52000, 31000)
summary(gdp_vec)


# summary() on a character vector counts values instead.

regions <- c("North", "South", "North", "East", "South")
summary(regions)


# summary() on a logical vector counts TRUE and FALSE.

above_average <- c(TRUE, FALSE, TRUE, TRUE, FALSE)
summary(above_average)


# plot() also adapts to the class of the data.

years <- c(2018, 2019, 2020, 2021, 2022)
growth <- c(1.5, 1.3, -9.4, 7.5, 4.1)

plot(years, growth,
     type = "o",
     xlab = "Year",
     ylab = "GDP Growth (%)",
     main = "UK GDP Growth")


## ---------------------- What happens when classes mix ---------------------- ##


# R will warn you or give unexpected results if you mix classes carelessly.

x <- c(1, 2, 3)
y <- c("a", "b", "c")

# Combining a numeric and a character vector: R converts everything to character.
z <- c(x, y)
z
class(z)

# You can no longer do arithmetic on z.
# mean(z)    # this would produce an error


# Use as.*() functions to convert between classes.

prices <- c("10.5", "12.0", "9.8")   # stored as text
class(prices)
mean(prices)


prices_num <- as.numeric(prices)
class(prices_num)

mean(prices_num)



## ---------------------- Data frames have multiple classes ------------------ ##


# A data frame is a table where each column can have a different class.

df <- data.frame(country    = c("Norway", "Germany", "Spain", "France", "Greece"),
                 gdp_pc     = c(82000, 51000, 30000, 44000, 20000),
                 in_euro    = c(FALSE, TRUE, TRUE, TRUE, TRUE))

# class() of the data frame itself.
class(df)

# class() of individual columns.
class(df$country)
class(df$gdp_pc)
class(df$in_euro)

# str() (for structure) gives a compact overview of all columns and their classes at once.
str(df)



## ---------------------- Introduction to dates ------------------------------ ##


# R has a dedicated class for dates: "Date".
# Dates are stored as the number of days since 1 January 1970.
# The class handles all the calendar arithmetic for you.


# Create a date from a string with as.Date().

start_date <- as.Date("2020-01-01")
class(start_date)
start_date


# The default format is YYYY-MM-DD (year-month-day).
# If your data uses a different format, tell R explicitly.

crisis_date <- as.Date("01/09/2008", format = "%d/%m/%Y")
crisis_date


# Useful format codes:
#   %Y  four-digit year   (2008)
#   %y  two-digit year    (08)
#   %m  month number      (09)
#   %d  day               (01)
#   %B  full month name   (September)


## ---------------------- Extracting parts of a date ------------------------ ##


# format() pulls out components as character strings.

format(crisis_date, "%Y")    # year
format(crisis_date, "%m")    # month
format(crisis_date, "%d")    # day
format(crisis_date, "%B %Y") # "September 2008"


## ---------------------- Arithmetic with dates ------------------------------ ##


# Because dates are numbers underneath, you can do arithmetic on them.

today      <- as.Date("2024-06-01")
last_year  <- as.Date("2023-06-01")

# How many days between the two dates?
today - last_year

# Add or subtract days.
today + 30
today - 90


# Useful functions for extracting calendar information.

# Which weekday?
weekdays(today)

# Which month?
months(today)


## ---------------------- A data frame with dates ---------------------------- ##


# Economic data often comes with a date column.

macro_data <- data.frame(date = as.Date(c("2020-01-01", "2020-04-01",
                                "2020-07-01", "2020-10-01",
                                "2021-01-01", "2021-04-01")),
                         gdp_growth = c(1.4, -19.8, 16.0, 1.2, -1.6, 5.5))

str(macro_data)

# class() confirms the date column really is a Date.
class(macro_data$date)

# Subsetting by date works just like subsetting by number.
macro_data[macro_data$date >= as.Date("2021-01-01"), ]

# Plotting with a Date column on the x-axis: R labels the axis automatically.
plot(macro_data$date, macro_data$gdp_growth,
     type = "o",
     xlab = "Quarter",
     ylab = "GDP Growth (%)",
     main = "Quarterly GDP Growth")

abline(h = 0, lty = 2, col = "grey50")
