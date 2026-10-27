## ---------------------- Libraries in R ------------------------------------ ##


# R comes with a set of built-in functions (base R). This is primarily what we 
# have been working on so far. Libraries (also called packages) extend R with 
# additional functions.

# A package must be installed once, then loaded each session.

# Install a package from CRAN (run once, not every session):
#   install.packages("tidyverse")

# Load a package (run at the top of every script):
#   library(tidyverse)

# The tidyverse is a collection of packages that share a common design.
# It includes dplyr (data manipulation) and ggplot2 (visualisation).

library(tidyverse)

# We will also use the gapminder package, which contains data on GDP per
# capita, population, and life expectancy for 142 countries, 1952-2007.

# install.packages("gapminder")
library(gapminder)


## ---------------------- Exploring the data -------------------------------- ##


# Load the dataset into the environment.
df <- gapminder

# Get a quick overview.
head(df)       # first six rows
tail(df)       # last six rows
dim(df)        # number of rows and columns
names(df)      # column names
str(df)        # structure: types of each column
summary(df)    # summary statistics for each column


## ---------------------- The pipe operator --------------------------------- ##


# The pipe |> passes the result on the left to the function on the right.
# Read it as "then do".

# For example:
#   df |> filter(...) |> arrange(...)
# reads as: "take df, then filter it, then arrange it."

# Advantages of using the pipe:
#
#   1. Readable left to right: matches the order you think about the steps.
#   2. Avoids deeply nested function calls that are hard to parse.
#   3. No need to create intermediate objects for every step.
#   4. Easy to add, remove, or reorder steps in a pipeline.
#   5. Makes multi-step data wrangling look like a recipe.
#   6. It is what Claude Code etc. use as a default.
#   7. We don't need to keep track of the $ signs everywhere.


# Without the pipe:
nrow(filter(df, continent == "Europe"))
# or 
nrow(df[df$continent == 'Europe',])


# With the pipe:
df |> filter(continent == "Europe") |> nrow()

# Both return the same result. The pipe version reads left to right,
# matching the order in which we think about the steps.

# You may also see %>% (from the magrittr package, loaded with tidyverse).
# It behaves identically for almost all uses.

df %>% filter(continent == "Europe") %>% nrow()


# IMPORTANT: the pipe prints the result to the console but does not save it.
# To store the result as a new object, assign it with <-.

europe <- df |> filter(continent == "Europe")

# Now 'europe' is a new data frame containing only European observations.
# The original 'df' is unchanged.

europe_2007 <- df |> filter(continent == "Europe", year == 2007)


# The real usefulness of |> comes when it is combined with functions from the 
# dplyr library (like lag(df$p, n = 12) that we used a few weeks ago).
# Especially: filter, select, and mutate. These functions are much of what is 
# needed when cleaning data. 




## ---------------------- filter() ----------------------------------------- ##


# filter() keeps rows that satisfy a condition.

# Countries in Europe — printed to console, not saved.
df |> filter(continent == "Europe")

# To save the result, assign it.
europe <- df |> filter(continent == "Europe")

# Observations from 2007.
df |> filter(year == 2007)

# Europe in 2007.
df |> filter(continent == "Europe", year == 2007)

# GDP per capita above 30,000 in 2007.
df |> filter(year == 2007, gdpPercap > 30000)

# Multiple countries: use %in% to match a list.
df |> filter(country %in% c("Norway", "Sweden", "Denmark"))

# Save the result for later use.
nordics <- df |> filter(country %in% c("Norway", "Sweden", "Denmark"))





## ---------------------- select() ----------------------------------------- ##


# select() keeps or drops columns by name.

# Keep only country, year, and GDP per capita.
df |> select(country, year, gdpPercap)

# Drop a column with a minus sign.
df |> select(-continent)

# Combine with filter and save.
europe_gdp <- df |>
  filter(year == 2007) |>
  select(country, continent, gdpPercap)


## ---------------------- mutate() ----------------------------------------- ##


# mutate() creates new columns or overwrites existing ones.
# The result must be assigned back (or to a new object) to keep the changes.

# Log of GDP per capita (commonly used in economics).
df <- df |> mutate(log_gdp = log(gdpPercap))

# Total GDP: multiply per capita GDP by population.
df <- df |> mutate(gdp_total = gdpPercap * pop)

# Chain multiple mutations together.
df <- df |>
  mutate(gdp_bn = gdp_total / 1e9)


## ---------------------- arrange() ---------------------------------------- ##


# arrange() sorts rows.

# Richest countries in 2007.
df |>
  filter(year == 2007) |>
  arrange(desc(gdpPercap))

# Poorest countries in 2007.
richest <- df |>
  filter(year == 2007) |>
  arrange(gdpPercap)


## ---------------------- summarise() --------------------------------------- ##


# summarise() collapses rows into a single summary value.

# Average life expectancy across all observations.
df |> summarise(mean_life_exp = mean(lifeExp))

# Several summaries at once.
df |>
  summarise(mean_gdp = mean(gdpPercap),
            max_gdp  = max(gdpPercap),
            min_gdp  = min(gdpPercap))


## ---------------------- group_by() + summarise() -------------------------- ##


# group_by() splits the data into groups before summarise() is applied.
# Each group returns one summary row.

# Average GDP per capita by continent in 2007.
df |>
  filter(year == 2007) |>
  group_by(continent) |>
  summarise(mean_gdp = mean(gdpPercap)) |>
  arrange(desc(mean_gdp))

# Save the summary for later use.
continent_summary <- df |>
  group_by(continent, year) |>
  summarise(mean_gdp     = mean(gdpPercap),
            mean_lifeexp = mean(lifeExp))



## ---------------------- A full pipeline ----------------------------------- ##

# These verbs combine naturally. Here we build a summary table of
# European GDP per capita over time and save it as a new data frame.

europe_summary <- df |>
  filter(continent == "Europe") |>
  select(country, continent, year, gdpPercap) |> 
  mutate(log_gdpPercap = log(gdpPercap)) |> 
  group_by(year) |>
  summarise(mean_gdp = mean(log_gdpPercap),
            max_gdp  = max(log_gdpPercap),
            min_gdp  = min(log_gdpPercap))

europe_summary







## ---------------------- Introduction to ggplot2 --------------------------- ##


# ggplot2 builds plots layer by layer.
# Every plot starts with ggplot(), which sets the data and aesthetics (aes).
# Aesthetics map columns to visual properties: x axis, y axis, colour, etc.
# Geometries (geom_*) specify the type of plot.


# -- Scatter plot -----------------------------------------------------------

# GDP per capita vs life expectancy in 2007.
df |>
  filter(year == 2007) |>
  ggplot(aes(x = gdpPercap, y = lifeExp)) +
  geom_point()

# Colour points by continent and rescale x to log.
df |>
  filter(year == 2007) |>
  ggplot(aes(x = gdpPercap, y = lifeExp, colour = continent)) +
  geom_point(size = 2, alpha = 0.8) +
  scale_x_log10() +
  xlab("GDP per capita (log scale)") +
  ylab("Life expectancy") +
  labs(title   = "GDP per capita and life expectancy, 2007",
       caption = "Source: Gapminder.",
       colour  = "Continent")


# -- Line plot --------------------------------------------------------------

# GDP per capita over time for selected countries.
df |>
  filter(country %in% c("Norway", "United Kingdom", "Spain", "China")) |>
  ggplot(aes(x = year, y = gdpPercap, colour = country)) +
  geom_line(linewidth = 1) +
  xlab("") +
  ylab("GDP per capita (USD)") +
  labs(title   = "GDP per capita, 1952-2007",
       caption = "Source: Gapminder.",
       colour  = "")


# -- Bar chart --------------------------------------------------------------

# Average GDP per capita by continent in 2007.
df |>
  filter(year == 2007) |>
  group_by(continent) |>
  summarise(mean_gdp = mean(gdpPercap)) |>
  ggplot(aes(x = reorder(continent, mean_gdp), y = mean_gdp)) +
  geom_col(fill = "#1c5253") +
  coord_flip() +
  xlab("") +
  ylab("Mean GDP per capita (USD)") +
  labs(title   = "Average GDP per capita by continent, 2007",
       caption = "Source: Gapminder.")


# -- Histogram --------------------------------------------------------------

# Distribution of GDP per capita in 2007.
df |>
  filter(year == 2007) |>
  ggplot(aes(x = gdpPercap)) +
  geom_histogram(bins = 30, fill = "#1c5253", colour = "white") +
  xlab("GDP per capita (USD)") +
  ylab("Count") +
  labs(title   = "Distribution of GDP per capita, 2007",
       caption = "Source: Gapminder.")


# -- Facets -----------------------------------------------------------------

# Repeat the same plot for each continent using facet_wrap.
df |>
  filter(year == 2007) |>
  ggplot(aes(x = gdpPercap, y = lifeExp)) +
  geom_point(alpha = 0.7) +
  scale_x_log10() +
  facet_wrap(~continent) +
  xlab("GDP per capita (log scale)") +
  ylab("Life expectancy") +
  labs(title   = "GDP per capita and life expectancy by continent, 2007",
       caption = "Source: Gapminder.")


## ---------------------- Saving a plot ------------------------------------- ##


# Assign the plot to a variable, then save it with ggsave.

p <- df |>
  filter(year == 2007) |>
  ggplot(aes(x = gdpPercap, y = lifeExp, colour = continent)) +
  geom_point(size = 2, alpha = 0.8) +
  scale_x_log10() +
  xlab("GDP per capita (log scale)") +
  ylab("Life expectancy") +
  labs(title   = "GDP per capita and life expectancy, 2007",
       caption = "Source: Gapminder.",
       colour  = "Continent")

ggsave("outputs/gdp_lifeexp_2007.png", plot = p, width = 8, height = 5)
