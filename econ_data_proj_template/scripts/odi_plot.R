## Plotting the data 
ggplot(data = df, aes(x = as.numeric(year), y = odi, color = country))+
  geom_line(aes(alpha = uk))+
  scale_color_manual(values = rep(1, 19))+
  scale_alpha_manual(values = c(0.1, 1))+
  theme(plot.title = element_text(size=12),
        plot.subtitle = element_text(size=9),
        legend.title = element_blank(),
        legend.position="none",
        plot.caption = element_text(size=6, hjust = 0),
        axis.title = element_text(size = 11),
        strip.background = element_blank(),
        strip.placement = "outside",
        panel.grid.minor = element_line('grey', size = 0.1, linetype = 'dashed'),
        panel.grid.major = element_line('grey', size = 0.1, linetype = 'dashed'),
        legend.key = element_rect(fill = NA),
        text=element_text(family="Palatino"),
        panel.background = element_rect(fill = "transparent", colour = NA),
        plot.background = element_rect(fill = "transparent", colour = NA))+
  xlab("Year") +
  ylab("Our development index (ODI)") +
  labs(title = "Our development index by country, 1990-2020",
       subtitle = "index created from life expectancy at birth and real GDP per capita (PPP)",
       caption = "Source: World Bank. Note: ODI is a weighted average of GDP per capita PPP in 2017 constant prices and life expectancy at birth.")

