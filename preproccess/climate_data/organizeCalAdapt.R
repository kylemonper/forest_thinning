##################
## PRECIP DATA ###
##################

p1 <- read.csv("precipRCP8.5/pr_day_CanESM2_rcp85.csv")
# units are in kg/m^2/s
# to convert to mm/day multiply by 86400 or by 86.4 for m/day
p1$mperday = p1$X1 * 86.400

# convert date to separate columns for year, month, day
split <- str_split(as.character(p1$time), pattern = "-")
temp <- p1 %>%
  mutate(year = as.numeric(lapply(split, "[[",1))) %>%
  mutate(month = as.numeric(lapply(split, "[[", 2))) %>%
  mutate(day = lapply(split, "[[", 3))
splitday <- str_split(as.character(temp$day), pattern = " ")
p1 <- temp %>%
  mutate(day = as.numeric(lapply(splitday,"[[",1)))
head(temp)
p1$p1 <- p1$X1 * 86.400
p1 %>% group_by(year) %>% summarize_at(vars(mperday), list(sum)) %>%
  ggplot(aes(x=year, y=mperday)) + geom_col()

write.csv(p1$mperday, 'rcp85-Can-rain.csv')


p2 <- read.csv("precipRCP8.5/pr_day_CNRM-CM5_rcp85.csv")
p2$p2 = p2$X1 * 86.400
split <- str_split(as.character(p2$time), pattern = "-")
temp <- p2 %>%
  mutate(year = as.numeric(lapply(split, "[[",1))) %>%
  mutate(month = as.numeric(lapply(split, "[[", 2))) %>%
  mutate(day = lapply(split, "[[", 3))
splitday <- str_split(as.character(temp$day), pattern = " ")
p2 <- temp %>%
  mutate(day = as.numeric(lapply(splitday,"[[",1)))
p2 %>% group_by(year) %>% summarize_at(vars(p2), list(sum)) %>%
  ggplot(aes(x=year, y=p2)) + geom_col()

write.csv(p2$p2, 'rcp85-CNRM-rain.csv')




p3 <- read.csv("precipRCP8.5/pr_day_HadGEM2-ES_rcp85.csv")
split <- str_split(as.character(p3$time), pattern = "-")
temp <- p3 %>%
  mutate(year = as.numeric(lapply(split, "[[",1))) %>%
  mutate(month = as.numeric(lapply(split, "[[", 2))) %>%
  mutate(day = lapply(split, "[[", 3))
splitday <- str_split(as.character(temp$day), pattern = " ")
p3 <- temp %>%
  mutate(day = as.numeric(lapply(splitday,"[[",1)))
p3$p3 = p3$X1 * 86.400
p3 %>% group_by(year) %>% summarize_at(vars(p3), list(sum)) %>%
  ggplot(aes(x=year, y=p3)) + geom_col()

write.csv(p3$p3, 'rcp85-Had-rain.csv')



p4 <- read.csv("precipRCP8.5/pr_day_MIROC5_rcp85.csv")
split <- str_split(as.character(p4$time), pattern = "-")
temp <- p4 %>%
  mutate(year = as.numeric(lapply(split, "[[",1))) %>%
  mutate(month = as.numeric(lapply(split, "[[", 2))) %>%
  mutate(day = lapply(split, "[[", 3))
splitday <- str_split(as.character(temp$day), pattern = " ")
p4 <- temp %>%
  mutate(day = as.numeric(lapply(splitday,"[[",1)))
p4$p4 = p4$X1 * 86.400
p4 %>% group_by(year) %>% summarize_at(vars(p4), list(sum)) %>%
  ggplot(aes(x=year, y=p4)) + geom_col()


write.csv(p4$p4, 'rcp85-MIROC-rain.csv')


##~~##
allp <- left_join(p3, p4, by=c("year","month","day"))
allp2 <- left_join(p1, p2, by=c("year","month","day"))
allp3 <- left_join(allp, allp2, by=c("year","month","day"))

allp3$mean <- (allp3$mperday + allp3$p2 + allp3$p3 + allp3$p4)/4

allp3 %>% group_by(year) %>% summarize_at(vars(mperday,p2,p3,p4,mean), list(sum)) %>%
  ggplot() +
  geom_line(aes(x=year, y=mperday, col='p1')) +
  geom_line(aes(x=year,y=p2, col='p2')) +
  geom_line(aes(x=year, y=p3, col='p3')) +
  geom_line(aes(x=year, y=p4, col='p4')) +
  geom_line(aes(x=year, y=mean, col='avg'), col='black')


write.csv(allp3$mean, 'rcp85.csv')

## MAX TEMP ###
###############

xt1 <- read.csv("maxtempRCP8.5/tasmax_day_CanESM2_rcp85.csv")
split <- str_split(as.character(xt1$time), pattern = "-")
temp <- xt1 %>%
  mutate(year = as.numeric(lapply(split, "[[",1))) %>%
  mutate(month = as.numeric(lapply(split, "[[", 2))) %>%
  mutate(day = lapply(split, "[[", 3))
splitday <- str_split(as.character(temp$day), pattern = " ")
xt1 <- temp %>%
  mutate(day = as.numeric(lapply(splitday,"[[",1))) %>%
  mutate(maxt1 = xt1$X1 - 273.15)

write.csv(xt1$maxt1, 'rcp85-CAN-max.csv')

xt2 <- read.csv("maxtempRCP8.5/tasmax_day_CNRM-CM5_rcp85.csv")
split <- str_split(as.character(xt2$time), pattern = "-")
temp <- xt2 %>%
  mutate(year = as.numeric(lapply(split, "[[",1))) %>%
  mutate(month = as.numeric(lapply(split, "[[", 2))) %>%
  mutate(day = lapply(split, "[[", 3))
splitday <- str_split(as.character(temp$day), pattern = " ")
xt2 <- temp %>%
  mutate(day = as.numeric(lapply(splitday,"[[",1))) %>%
  mutate(maxt2 = xt2$X1 - 273.15)

write.csv(xt2$maxt2, 'rcp85-CNRM-max.csv')

xt3 <- read.csv("maxtempRCP8.5/tasmax_day_HadGEM2-ES_rcp85.csv")
split <- str_split(as.character(xt3$time), pattern = "-")
temp <- xt3 %>%
  mutate(year = as.numeric(lapply(split, "[[",1))) %>%
  mutate(month = as.numeric(lapply(split, "[[", 2))) %>%
  mutate(day = lapply(split, "[[", 3))
splitday <- str_split(as.character(temp$day), pattern = " ")
xt3 <- temp %>%
  mutate(day = as.numeric(lapply(splitday,"[[",1))) %>%
  mutate(maxt3 = xt3$X1 - 273.15)

write.csv(xt3$maxt3, 'rcp85-Had-max.csv')

xt4 <- read.csv("maxtempRCP8.5/tasmax_day_MIROC5_rcp85.csv")
split <- str_split(as.character(xt4$time), pattern = "-")
temp <- xt4 %>%
  mutate(year = as.numeric(lapply(split, "[[",1))) %>%
  mutate(month = as.numeric(lapply(split, "[[", 2))) %>%
  mutate(day = lapply(split, "[[", 3))
splitday <- str_split(as.character(temp$day), pattern = " ")
xt4 <- temp %>%
  mutate(day = as.numeric(lapply(splitday,"[[",1))) %>%
  mutate(maxt4 = xt4$X1 - 273.15)

write.csv(xt4$maxt4, 'rcp85-MIROC-max.csv')

allmaxt <- left_join(xt1, xt2, by=c("year","month","day"))
allmaxt2 <- left_join(xt3, xt4, by=c("year","month","day"))
allmaxt3 <- left_join(allmaxt, allmaxt2, by=c("year","month","day"))
allmaxt3$mean <- (allmaxt3$maxt1+allmaxt3$maxt2+allmaxt3$maxt3+allmaxt3$maxt4)/4
allmaxt3 %>% group_by(year) %>% summarize_at(vars(maxt1,maxt2,maxt3,maxt4, mean), list(sum)) %>%
  ggplot() +
  geom_line(aes(x=year, y=maxt1, col='p1')) +
  geom_line(aes(x=year,y=maxt2, col='p2')) +
  geom_line(aes(x=year, y=maxt3, col='p3')) +
  geom_line(aes(x=year, y=maxt4, col='p4')) +
  geom_line(aes(x=year, y=mean, col='avg'), col='black')


## MIN TEMP ###
###############

nt1 <- read.csv("mintempRCP8.5/tasmin_day_CanESM2_rcp85.csv")
split <- str_split(as.character(nt1$time), pattern = "-")
temp <- nt1 %>%
  mutate(year = as.numeric(lapply(split, "[[",1))) %>%
  mutate(month = as.numeric(lapply(split, "[[", 2))) %>%
  mutate(day = lapply(split, "[[", 3))
splitday <- str_split(as.character(temp$day), pattern = " ")
nt1 <- temp %>%
  mutate(day = as.numeric(lapply(splitday,"[[",1))) %>%
  mutate(nt1 = nt1$X1 - 273.15)

write.csv(nt1$nt1, "rcp85-CAN-min.csv")

nt2 <- read.csv("mintempRCP8.5/tasmin_day_CNRM-CM5_rcp85.csv")
split <- str_split(as.character(nt2$time), pattern = "-")
temp <- nt2 %>%
  mutate(year = as.numeric(lapply(split, "[[",1))) %>%
  mutate(month = as.numeric(lapply(split, "[[", 2))) %>%
  mutate(day = lapply(split, "[[", 3))
splitday <- str_split(as.character(temp$day), pattern = " ")
nt2 <- temp %>%
  mutate(day = as.numeric(lapply(splitday,"[[",1))) %>%
  mutate(nt2 = nt2$X1 - 273.15)

write.csv(nt2$nt2, "rcp85-CNRM-min.csv")



nt3 <- read.csv("mintempRCP8.5/tasmin_day_HadGEM2-ES_rcp85.csv")
split <- str_split(as.character(nt3$time), pattern = "-")
temp <- nt3 %>%
  mutate(year = as.numeric(lapply(split, "[[",1))) %>%
  mutate(month = as.numeric(lapply(split, "[[", 2))) %>%
  mutate(day = lapply(split, "[[", 3))
splitday <- str_split(as.character(temp$day), pattern = " ")
nt3 <- temp %>%
  mutate(day = as.numeric(lapply(splitday,"[[",1))) %>%
  mutate(nt3 = nt3$X1 - 273.15)

write.csv(nt3$nt3, "rcp85-Had-min.csv")



nt4 <- read.csv("mintempRCP8.5/tasmin_day_MIROC5_rcp85.csv")
split <- str_split(as.character(nt4$time), pattern = "-")
temp <- nt4 %>%
  mutate(year = as.numeric(lapply(split, "[[",1))) %>%
  mutate(month = as.numeric(lapply(split, "[[", 2))) %>%
  mutate(day = lapply(split, "[[", 3))
splitday <- str_split(as.character(temp$day), pattern = " ")
nt4 <- temp %>%
  mutate(day = as.numeric(lapply(splitday,"[[",1))) %>%
  mutate(nt4 = nt4$X1 - 273.15)

write.csv(nt4$nt4, "rcp85-MIROC-min.csv")



allmin <- left_join(nt1, nt2, by=c("year","month","day"))
allmin2 <- left_join(nt3, nt4, by=c("year","month","day"))
allmin3 <- left_join(allmin, allmin2, by=c("year","month","day"))
allmin3$mean <- (allmin3$nt1+allmin3$nt2+allmin3$nt3+allmin3$nt4)/4
allmin3 %>% group_by(year) %>% summarize_at(vars(nt1,nt2,nt3,nt4, mean), list(sum)) %>%
  ggplot() +
  geom_line(aes(x=year, y=nt1, col='p1')) +
  geom_line(aes(x=year,y=nt2, col='p2')) +
  geom_line(aes(x=year, y=nt3, col='p3')) +
  geom_line(aes(x=year, y=nt4, col='p4')) +
  geom_line(aes(x=year, y=mean, col='avg'), col='black')

avgtemps <- cbind(select(allmin3, mean), select(allmaxt3, mean))
colnames(avgtemps) <- c("tmin", "tmax")
