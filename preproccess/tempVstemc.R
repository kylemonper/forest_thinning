# exploring stability

tmp <- thin_full %>% 
  ungroup() %>% 
  filter(climproj == 'rcp45-Had' & scen == 2030 & thin == 80) %>% 
  select(stemc_total, wyg) %>% 
  mutate(pct_change = round(stemc_total/lag(stemc_total, 5)/100, 5),
         total_change = stemc_total-lag(stemc_total,1))

met_date <- mkdate(met)
met_sum <- met_date %>% 
  group_by(climproj, wy) %>% 
  summarise(
    tmin = min(tmin),
    tmax = max(tmax),
    tavg = (tmin+tmax)/2,
    rain = sum(rain)
  ) %>% 
  ungroup()
clim <- select(met_sum, tmin, tmax, tavg, rain, wy, climproj)  

thin_full_clim <- left_join(select(thin_full, -tmin, -tmax), 
                            clim, 
                            by = c('wy', 'climproj'))



miroc85 <- thin_full_clim %>% 
  filter(climproj == 'rcp85-MIROC' & 
           thin == 100) 

                  
ggplot(miroc85, aes(x = tavg, y = stemc_total, color = wyg)) +
  geom_point() +
  facet_wrap(~scen)









ggplot(test, aes(x = tavg, y = total_change, color = wyg)) +
  geom_point() 


for (i in 1:length(scen)) {
  tmp <- thin_full_clim %>% 
    ungroup() %>% 
    subset(climproj == 'rcp85-MIROC' & scen == scen[3] & thin == 0) %>% 
    select(stemc_total, wyg, tavg, scen) %>% 
    mutate(pct_change = round(stemc_total/lag(stemc_total, 1), 5),
           total_change = stemc_total-lag(stemc_total,1))
  
  if (i == 1) {
    test <- tmp 
  } else {
    test <- bind_rows(test, tmp)
  }
  
}

ggplot(test, aes(x = tavg, y = pct_change, color = wyg)) +
  geom_point() + 
  facet_wrap(~scen)


df <- data.frame(group = c(rep('A',12), rep('B',12), rep('C',12)), 
                 type = c(rep(1:12,3)),
                 scen = c(rep(seq(5,60,5),3)),
                 value = rnorm(36))

test <- thin_full_clim %>% 
  ungroup() %>% 
  filter(climproj == 'rcp85-MIROC' & thin == 100) %>% 
  select(scen, stemc_total, wyg, tavg) %>% 
  group_by(scen) %>% 
  mutate(pct_change = stemc_total/lag(stemc_total,1))

ggplot(test)


