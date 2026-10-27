## -------- Police Expenditure and Crime: Scatter Plot (Eurostat) ----------- ##

# install.packages("eurostat")
library(eurostat)
library(tidyverse)
library(ggthemes)
library(ggrepel)


## ---------------------- Download the data --------------------------------- ##


# -- Police expenditure in millions of EUR ----------------------------------
# Dataset : gov_10a_exp  Government expenditure by function (COFOG)
# cofog99  = "GF0301"    Police services
# sector   = "S13"       General government
# unit     = "MIO_EUR"   Millions of euros
# na_item  = "TE"        Total expenditure

exp_raw <- get_eurostat("gov_10a_exp",
                        filters     = list(cofog99 = "GF0301",
                                           sector  = "S13",
                                           unit    = "MIO_EUR",
                                           na_item = "TE"),
                        time_format = "num",
                        cache       = TRUE)


# -- Population -------------------------------------------------------------
# Dataset : demo_pjan  Population by age and sex
# age = "TOTAL", sex = "T"

pop_raw <- get_eurostat("demo_pjan",
                        filters     = list(age = "TOTAL",
                                           sex = "T"),
                        time_format = "num",
                        cache       = TRUE)


# -- Crime rate -------------------------------------------------------------
# Dataset : crim_off_cat  Offences recorded by police
# iccs     = "ICCS0101"   Intentional homicide
# unit     = "P_HTHAB"    Per 100,000 inhabitants
# Filters not supported for this dataset: download in full, filter manually.

crime_raw <- get_eurostat("crim_off_cat",
                          time_format = "num",
                          cache       = TRUE)


## ---------------------- Clean and merge ----------------------------------- ##


year_select <- 2019

exp <- exp_raw %>%
  filter(time == year_select,
         !geo %in% c("EU27_2020", "EA21", "EA20", "EA19"),
         !is.na(values)) %>%
  select(geo, values) %>%
  rename(police_mio_eur = values)

pop <- pop_raw %>%
  filter(time == year_select,
         !is.na(values)) %>%
  select(geo, values) %>%
  rename(population = values)

# Top-level ICCS codes only — excludes sub-categories to avoid double counting.
# e.g. ICCS0301 (sexual violence) already contains ICCS03011 + ICCS03012,
# so we use the parent and drop the children.
top_level_codes <- c(
  "ICCS0101",   # intentional homicide
  "ICCS0102",   # attempted homicide
  "ICCS020111", # assault
  "ICCS020221", # theft from person
  "ICCS0301",   # sexual violence (parent)
  "ICCS0302",   # sexual exploitation (parent)
  "ICCS0401",   # kidnapping
  "ICCS0501",   # theft (parent)
  "ICCS0502",   # robbery (parent)
  "ICCS0601",   # drug offences
  "ICCS0701",   # cybercrime
  "ICCS0703",   # fraud (parent)
  "ICCS07041",  # corruption
  "ICCS0903",   # acts against public order (parent)
  "ICCS1001", "ICCS1002", "ICCS1003", "ICCS1004"
)

crime <- crime_raw %>%
  filter(iccs        %in% top_level_codes,
         unit        == "P_HTHAB",
         TIME_PERIOD == year_select,
         !is.na(values)) %>%
  group_by(geo) %>%
  summarise(crime_per_100k = sum(values, na.rm = TRUE))

# Merge and compute per capita police expenditure (EUR per person).
df <- exp %>%
  inner_join(pop,   by = "geo") %>%
  inner_join(crime, by = "geo") %>%
  mutate(police_eur_pc = (police_mio_eur * 1e6) / population) %>%
  filter(!is.na(crime_per_100k))

# Add full country names.
country_names <- eurostat::eu_countries %>%
  bind_rows(eurostat::efta_countries) %>%
  select(code, name)

df <- df %>%
  left_join(country_names, by = c("geo" = "code"))

cat("Countries in final dataset:", nrow(df), "\n")
print(df %>% select(geo, name, police_eur_pc, crime_per_100k))


## ---------------------- Scatter plot -------------------------------------- ##


p <- ggplot(df, aes(x = police_eur_pc, y = crime_per_100k, label = geo)) +
  geom_point(size = 2.5, alpha = 0.8) +
  geom_text_repel(size = 3.5, max.overlaps = Inf) +
  theme_tufte() +
  theme(plot.title    = element_text(size = 22),
        plot.subtitle = element_text(size = 16),
        plot.caption  = element_text(size = 12, hjust = 0),
        axis.title    = element_text(size = 18),
        axis.text.x   = element_text(size = 12),
        axis.text.y   = element_text(size = 12),
        panel.grid.minor = element_line("grey", linewidth = 0.1, linetype = "dashed"),
        panel.grid.major = element_line("grey", linewidth = 0.1, linetype = "dashed"),
        panel.background = element_rect(fill = "transparent", colour = NA),
        plot.background  = element_rect(fill = "transparent", colour = NA)) +
  xlab("Police expenditure per capita (EUR)") +
  ylab("Recorded offences per 100,000 inhabitants") +
  labs(title   = "Police expenditure and crime across Europe, 2019",
       caption = "Sources: Eurostat (gov_10a_exp, demo_pjan, crim_off_cat).")

p


## ---------------------- Save the plot ------------------------------------- ##


# Resolve output path whether script is run from the repo root or scripts/.
img_dir <- file.path(getwd(), "lectures", "images")
if (!dir.exists(img_dir)) img_dir <- file.path(getwd(), "..", "lectures", "images")

ggsave(file.path(img_dir, "police_crime_scatter.png"),
       plot = p, width = 10, height = 7, bg = "transparent")
