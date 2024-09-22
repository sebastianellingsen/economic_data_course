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







df <- read_csv('data/economic_data_uk.csv') %>%
  filter(Year %in% c(1980, 1985, 1990, 1995, 2000, 2005, 2010, 2015)) %>% 
  mutate(d_l_gdp_pc = log(gdp_pc) - dplyr::lag(log(gdp_pc), n = 1),
         g_gdp_pc = (gdp_pc - dplyr::lag(gdp_pc, n = 1)) / dplyr::lag(gdp_pc, n = 1)) %>%
  pivot_longer(cols = c(d_l_gdp_pc, g_gdp_pc), 
               names_to = "series", 
               values_to = "values") %>% 
  filter(!is.na(values))

# Constructing plots 
p1 <- ggplot(data=df, aes(x = Year, y = values, linetype = series))+
  geom_line(size = 1.1, alpha = 0.7)+
  theme(plot.title = element_text(size=22),
        plot.subtitle = element_text(size=16),
        legend.title = element_blank(),
        legend.text=element_text(size=14),
        legend.position="none",
        plot.caption = element_text(size=12, hjust = 0),
        axis.title = element_text(size = 18),
        strip.background = element_blank(),
        axis.text.x=element_text(angle=45, hjust=1, size = 12),
        axis.text.y=element_text(size = 12),
        strip.placement = "outside",
        panel.grid.minor = element_line('grey', size = 0.1, linetype = 'dashed'),
        panel.grid.major = element_line('grey', size = 0.1, linetype = 'dashed'),
        panel.background = element_rect(fill = "transparent", colour = NA),
        plot.background  = element_rect(fill = "transparent", colour = NA),
        legend.background = element_rect(fill='transparent'),
        legend.key=element_blank())+
  xlab("Year") +
  ylab("GDP Per Capita (log.)") +
  labs(title = "GDP Per Capita UK, 1980-2018",
       caption = "Source: Maddison (2021).")+
  ylim(-0.055, 0.055)

