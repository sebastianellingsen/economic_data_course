
countries <- c("United Kingdom", 
               "United States",
               "Austria", 
               "Australia",
               "Belgium",
               "Switzerland",
               "Denmark",
               "Spain",
               "France",
               "Greece",
               "Italy",
               "Japan",
               "Netherlands",
               "Norway",
               "New Zealand",
               "Poland",
               "Portugal",
               "Slovak Republic",
               "Sweden")


## Life expectancy
life_exp <- read_csv("labs/lab_5/wb/API_SP.DYN.LE00.IN_DS2_en_csv_v2_5871609.csv", skip = 4) %>% 
  select(-"Indicator Name", -"Indicator Code") %>% 
  rename(country = "Country Name",
         ccode   = "Country Code") %>% 
  gather(year, life_exp, 3:66) %>% 
  filter(year>=1990, year<=2020) %>% 
  filter(country %in% countries)%>% 
  mutate(life_exp = as.numeric(life_exp))


## GDP per capita ppp in constant prices
gdppc <- read_csv("labs/lab_5/wb/API_NY.GDP.PCAP.PP.KD_DS2_en_csv_v2_5873868.csv", skip = 4) %>% 
  select(-"Indicator Name", -"Indicator Code") %>% 
  rename(country = "Country Name",
         ccode   = "Country Code") %>% 
  gather(year, gdppc, 3:66) %>% 
  filter(year>=1990, year<=2020) %>% 
  filter(country %in% countries) %>% 
  mutate(gdppc = as.numeric(gdppc))


## Combining the datasets
df <- life_exp %>% 
  full_join(gdppc, by = c('country', 'ccode', 'year')) %>% 
  mutate(lei = (life_exp - 20)/(85-20),
         ii  = (log(gdppc) - log(100))/(log(75000) - log(100)),
         odi = (lei * ii)^0.5) %>% 
  mutate(uk = ifelse(country == 'United Kingdom', 1, 0) %>% as.factor())





