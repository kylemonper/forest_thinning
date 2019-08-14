library(tidyverse)
library(RHESSysIOinR)


## read in met data
had <- read_rhessys_met('/Users/Kyle/Google Drive/JDSF/rhessys/clim/orig/rcp85-Had') 
early <- read_rhessys_met('/Users/Kyle/Google Drive/JDSF/rhessys/clim/drought/had_early')
late <- read_rhessys_met('/Users/Kyle/Google Drive/JDSF/rhessys/clim/drought/had_late')



# change units from early and late century drought data from Kelvins and Meters to C and mm
early <- mutate(early, rain = rain/1000, 
                tmax = tmax-273.15, 
                tmin = tmin-273.15)
late <- mutate(late, rain = rain/1000,
                tmax = tmax-273.15,
                tmin = tmin-273.15)

## alter the original 8.5 Had climate data to create two new datasets that have 'early' and 'late' droughts

early1 <- filter(had, had$date < min(early$date))
early2 <- filter(had, had$date > max(early$date))

early_drought <- bind_rows(list(early1, early, early2))





late1 <- filter(had, had$date < min(late$date))
late2 <- filter(had, had$date > max(late$date))

late_drought <- bind_rows(list(late1, late, late2))


write.table(late_drought$rain, '/Users/Kyle/Google Drive/JDSF/rhessys/clim/drought/had_late.rain')
write.table(late_drought$tmin, '/Users/Kyle/Google Drive/JDSF/rhessys/clim/drought/had_late.tmin')
write.table(late_drought$tmax, '/Users/Kyle/Google Drive/JDSF/rhessys/clim/drought/had_late.tmax')



write.table(early_drought$rain, '/Users/Kyle/Google Drive/JDSF/rhessys/clim/drought/had_early.rain')
write.table(early_drought$tmin, '/Users/Kyle/Google Drive/JDSF/rhessys/clim/drought/had_early.tmin')
write.table(early_drought$tmax, '/Users/Kyle/Google Drive/JDSF/rhessys/clim/drought/had_early.tmax')
