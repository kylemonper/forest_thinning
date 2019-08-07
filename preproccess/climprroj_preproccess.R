setwd('/Users/kmonper/Google Drive/JDSF/rhessys/scripts')


# edit this to point to where RHESSys is on your system
rhessysver = "/Users/kmonper/RHESSys-develop/bin/rhessys7.0"


library(tidyverse)
library(lubridate)
library(RHESSysIOinR)


# use this to set different biomass removal amoubnts
thinscen = seq(from=0, to=100, by=20)


# determine which variables you want to save from RHESSys
ecovars = c("evap","trans","gpsn","resp","lai","cpool","plantc","precip","stemc")
scenvars = c("thin","scen","climproj","day","month","year")



# use this to set dates for starting water year, length of sim time
# and number of years between repeated start dates (e.g 5)
startwy = seq(from=2030, to=2090, by=5)
nyrs=80
endwy = startwy+nyrs 



# base name of climate files
climproj <- c('rcp45-Had', 'rcp45-MIROC', 'rcp45-CNRM', 'rcp45-CAN', 'rcp85-Had', 'rcp85-MIROC', 'rcp85-CNRM', 'rcp85-CAN')

### create emptymatrix to be populated

#~ based on length of met data
clim = read_rhessys_met("../clim/rcp45-MIROC")
climscen = subset(clim, clim$wy >= startwy[1] & clim$wy < endwy[1]) 
nday=nrow(climscen)
nday = nday+2

nvals = length(thinscen)*3*nday*length(startwy)*8

# thin_clim will store results - you should changes this to what every you want to call it
thin_clim = as.data.frame(matrix(nrow=nvals, ncol=length(c(ecovars,scenvars))))
colnames(thin_clim) = c(scenvars, ecovars)

j = 1 
for(proj in 1:length(climproj)) { 

  for (scen in 1:length(startwy)) {
    
    for (thin in 1:length(thinscen) ) {
      
      cmd1=sprintf("awk -f ../worldfiles/changec.awk thin=%f < ../worldfiles/redwood_warm_400.world > ../worldfiles/redwood.test.Y%dM10D1H1", thinscen[thin]/100.0,startwy[scen]-1);
      system(cmd1)
      
      #cmd1=sprintf("awk -f ../flowtables/changeareaflow.v7.awk thin=%f <  ../flowtables/flow.newv > ../flowtables/flow.single.area.deep", 
      #            thinscen[thin]/100.0)
      #system(cmd1)
      
      tmp = sprintf("%d 10 1 1 redefine_world\n%d 10 1 2 print_daily_on\n%d 10 1 3 print_daily_growth_on",
                    startwy[scen]-1, startwy[scen]-1, startwy[scen]-1)
      write(tmp, file="../tecfiles/tec.thinb.deep")
      
      cmd2 = sprintf("%s -t ../tecfiles/tec.thinb.deep -w ../worldfiles/redwood.test -r ../flowtables/JacksonPatch.flow  -st %d 8 1 1 -ed %d 10 1 1 -pre ../out/JF_thin-proj -s 1 10 -gw 0 0 -whdr ../worldfiles/JacksonPatch-%s.hdr -b -p -g -c -climrepeat", 
                     rhessysver,startwy[scen]-10, endwy[scen]-1, climproj[proj]); 
      system(cmd2)
      
      # note running location
      print(c(proj, startwy[scen], thinscen[thin]))
      
      #read in data
      a = readin_rhessys_output("../out/JF_thin-proj", c=1,g=1,p=1)
      
      
      endj = j+length(a$bd$day)-1
  
      
      thin_clim$scen[j:endj] = startwy[scen]
      thin_clim$thin[j:endj] = thinscen[thin]
      thin_clim$climproj[j:endj] = climproj[proj]
      thin_clim$year[j:endj] = a$bd$year
      thin_clim$day[j:endj] = a$bd$day
      thin_clim$month[j:endj] = a$bd$month
      thin_clim$trans[j:endj] = a$bd$trans
      thin_clim$lai[j:endj] = a$bd$lai
      thin_clim$gpsn[j:endj] = a$bdg$gpsn
      thin_clim$resp[j:endj] = a$bdg$plant_resp
      thin_clim$evap[j:endj] = a$bd$evap
      thin_clim$cpool[j:endj] = a$bdg$cpool
      thin_clim$plantc[j:endj] = a$bdg$plantc
      thin_clim$precip[j:endj] = a$bd$precip
      thin_clim$stemc[j:endj] = a$bdg$overstory_stemc
 
      
      j = endj+1
      
    }
  }
}


## write individual .txt files so that they can be read in separately
# (when together, file is too large to be read in using read.table())

for (i in 1:length(climproj)) {
  
tmp <- filter(thin_clim, climproj == paste(climproj[2]))
#write.table(tmp, file = sprintf('../out/JF_thin-proj-400-%s.txt', climproj[i]))

}




