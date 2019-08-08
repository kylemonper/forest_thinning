setwd('/Users/kmonper/Google Drive/JDSF/rhessys/scripts')


# edit this to point to where RHESSys is on your system
rhessysver = "/Users/kmonper/RHESSys-develop/bin/rhessys7.0"


library(tidyverse)
library(lubridate)
library(RHESSysIOinR)





# determine which variables you want to save from RHESSys
ecovars = c("evap","trans","gpsn","resp","lai","cpool","plantc","precip","stemc_live",'stemc_dead', 'canopy', 'streamflow')
scenvars = c("thin","scen","climproj","day","month","year")



# use this to set dates for starting water year, length of sim time
# and number of years between repeated start dates (e.g 5)
startwy = seq(from=2030, to=2085, by=5)
nyrs=100
endwy = startwy+nyrs 



# base name of climate files
climproj <- c('historic', 'rcp45-Had', 'rcp45-MIROC', 'rcp45-CNRM', 'rcp45-CAN', 'rcp85-Had', 'rcp85-MIROC', 'rcp85-CNRM', 'rcp85-CAN')

### create emptymatrix to be populated

#~ based on length of met data
clim = read_rhessys_met("../clim/rcp45-MIROC")
climscen = subset(clim, clim$wy >= startwy[1] & clim$wy < endwy[1]) 
nday=nrow(climscen)
nday = nday+2

nvals = 3*nday*length(startwy)*9

# thin_clim will store results - you should changes this to what every you want to call it
thin_2patch = as.data.frame(matrix(nrow=nvals, ncol=length(c(ecovars,scenvars))))
colnames(thin_2patch) = c(scenvars, ecovars)

j = 1 
for(proj in 1:length(climproj)) { 
  
  for (scen in 1:length(startwy)) {
      
      cmd1=sprintf("awk -f ../worldfiles/changec.awk thin=1 < ../worldfiles/redwood.2path.thin.test > ../worldfiles/redwood_warm-2patch.world.Y%dM10D1H1", startwy[scen]-1);
      system(cmd1)
      
      #cmd1=sprintf("awk -f ../flowtables/changeareaflow.v7.awk thin=%f <  ../flowtables/flow.newv > ../flowtables/flow.single.area.deep", 
      #            thinscen[thin]/100.0)
      #system(cmd1)
      
      tmp = sprintf("%d 10 1 1 redefine_world\n%d 10 1 2 print_daily_on\n%d 10 1 3 print_daily_growth_on",
                    startwy[scen]-1, startwy[scen]-1, startwy[scen]-1)
      write(tmp, file="../tecfiles/tec.thinb.deep")
      
      cmd2 = sprintf("%s -t ../tecfiles/tec.thinb.deep -w ../worldfiles/redwood_warm-2patch.world -r ../flowtables/Jackson-2patch.flow  -st %d 8 1 1 -ed %d 10 1 1 -pre ../out/JF_thin-proj -s 1 10 -gw 0 0 -whdr ../worldfiles/JacksonPatch-%s.hdr -b -p -g -c -climrepeat", 
                     rhessysver,startwy[scen]-10, endwy[scen]-1, climproj[proj]); 
      system(cmd2)
      
      # note running location
      print(c(proj, startwy[scen]))
      
      #read in data
      a = readin_rhessys_output("../out/JF_thin-proj", c=1,g=1,p=1)
      
      
      endj = j+length(a$bd$day)-1
      thin_2patch$scen[j:endj] = startwy[scen]
      thin_2patch$climproj[j:endj] = climproj[proj]
      thin_2patch$year[j:endj] = a$bd$year
      thin_2patch$day[j:endj] = a$bd$day
      thin_2patch$month[j:endj] = a$bd$month
      thin_2patch$canopy[j:endj] = "control"
      thin_2patch$trans[j:endj] = a$cd$trans[a$cd$stratumID==11 & a$cd$patchID==3]
      thin_2patch$lai[j:endj] = a$cd$lai[a$cd$stratumID==11 & a$cd$patchID==3]
      thin_2patch$gpsn[j:endj] = a$cdg$psn_to_cpool[a$cdg$stratumID==11 & a$cd$patchID==3]
      thin_2patch$resp[j:endj] = a$cdg$mresp[a$cdg$stratumID==11 & a$cdg$patchID==3]+a$cdg$gresp[a$cdg$stratumID==11 & a$cdg$patchID==3]
      thin_2patch$evap[j:endj] = a$pd$evap[a$pd$patchID==3]+a$pd$evap_surface[a$pd$patchID==3]+a$pd$soil_evap[a$pd$patchID==3]
      thin_2patch$cpool[j:endj] = a$cdg$cpool[a$cdg$stratumID==11 & a$cdg$patchID==3]
      thin_2patch$plantc[j:endj] = a$cdg$plantc[a$cdg$stratumID==11 & a$cdg$patchID==3]
      thin_2patch$precip[j:endj] = a$bd$precip[a$cdg$stratumID==11 & a$cdg$patchID==3]
      thin_2patch$stemc_live[j:endj] = a$cdg$live_stemc[a$cdg$stratumID==11 & a$cdg$patchID==3]
      thin_2patch$stemc_dead[j:endj] = a$cdg$dead_stemc[a$cdg$stratumID==11 & a$cdg$patchID==3]
      thin_2patch$streamflow[j:endj] = a$bd$streamflow

      j = endj+1
      endj = j+length(a$bd$day)-1
      thin_2patch$scen[j:endj] = startwy[scen]
      thin_2patch$climproj[j:endj] = climproj[proj]
      thin_2patch$year[j:endj] = a$bd$year
      thin_2patch$day[j:endj] = a$bd$day
      thin_2patch$month[j:endj] = a$bd$month 
      thin_2patch$canopy[j:endj] = "thin"
      thin_2patch$trans[j:endj] = a$cd$trans[a$cd$stratumID==11 & a$cd$patchID==4]
      thin_2patch$lai[j:endj] = a$cd$lai[a$cd$stratumID==11 & a$cd$patchID==4]
      thin_2patch$gpsn[j:endj] = a$cdg$psn_to_cpool[a$cdg$stratumID==11 & a$cd$patchID==4]
      thin_2patch$resp[j:endj] = a$cdg$mresp[a$cdg$stratumID==11 & a$cdg$patchID==4]+a$cdg$gresp[a$cdg$stratumID==11 & a$cdg$patchID==4]
      thin_2patch$evap[j:endj] = a$pd$evap[a$pd$patchID==4]+a$pd$evap_surface[a$pd$patchID==4]+a$pd$soil_evap[a$pd$patchID==4]
      thin_2patch$cpool[j:endj] = a$cdg$cpool[a$cdg$stratumID==11 & a$cdg$patchID==4]
      thin_2patch$plantc[j:endj] = a$cdg$plantc[a$cdg$stratumID==11 & a$cdg$patchID==4]
      thin_2patch$precip[j:endj] = a$bd$precip[a$cdg$stratumID==11 & a$cdg$patchID==4]
      thin_2patch$stemc_live[j:endj] = a$cdg$live_stemc[a$cdg$stratumID==11 & a$cdg$patchID==4]
      thin_2patch$stemc_dead[j:endj] = a$cdg$dead_stemc[a$cdg$stratumID==11 & a$cdg$patchID==4]
      thin_2patch$streamflow[j:endj] = a$bd$streamflow

      
      j = endj+1
      
  }

}


tmp <- filter(thin_2patch, climproj == 'rcp45-Had')
write.table(tmp, '../out/JF_thin-proj-rcp45-Had')


tmp <- filter(thin_2patch, climproj == 'rcp85-Had')
write.table(tmp, '../out/JF_thin-proj-rcp85-Had')


tmp <- filter(thin_2patch, climproj == 'rcp45-CAN')
write.table(tmp, '../out/JF_thin-proj-rcp45-CAN')


tmp <- filter(thin_2patch, climproj == 'rcp85-CAN')
write.table(tmp, '../out/JF_thin-proj-rcp85-CAN')


tmp <- filter(thin_2patch, climproj == 'rcp45-CNRM')
write.table(tmp, '../out/JF_thin-proj-rcp45-CNRM')


tmp <- filter(thin_2patch, climproj == 'rcp85-CNRM')
write.table(tmp, '../out/JF_thin-proj-rcp85-CNRM')


tmp <- filter(thin_2patch, climproj == 'rcp45-MIROC')
write.table(tmp, '../out/JF_thin-proj-rcp45-MIROC')


tmp <- filter(thin_2patch, climproj == 'rcp85-MIROC')
write.table(tmp, '../out/JF_thin-proj-rcp85-MIROC')


tmp <- filter(thin_2patch, climproj == 'historic')
write.table(tmp, '../out/JF_thin-proj-historic')




