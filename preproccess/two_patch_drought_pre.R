setwd('/Users/kmonper/Google Drive/JDSF/rhessys/scripts')


# edit this to point to where RHESSys is on your system
rhessysver = "/Users/kmonper/RHESSys-develop/bin/rhessys7.0"


library(tidyverse)
library(lubridate)
library(RHESSysIOinR)





# determine which variables you want to save from RHESSys
ecovars = c("evap","trans","gpsn","resp","lai","cpool","plantc","precip","stemc_live",'stemc_dead', 'canopy', 'streamflow','tmax','tmin', 'heigth')
scenvars = c("thin","scen","climproj","day","month","year")



# use this to set dates for starting water year, length of sim time
# and number of years between repeated start dates (e.g 5)
startwy = 2030
nyrs=100
endwy = startwy+nyrs 



# base name of climate files
climproj <- c('rcp85-had_early', 'rcp85-had_late')

### create emptymatrix to be populated

#~ based on length of met data
clim = read_rhessys_met("../clim/drought/had_late")
climscen = subset(clim, clim$wy >= startwy[1] & clim$wy < endwy[1]) 
nday=nrow(climscen)
nday = nday+2

nvals = 3*nday*length(startwy)*2

# thin_clim will store results - you should changes this to what every you want to call it
thin_2patch = as.data.frame(matrix(nrow=nvals, ncol=length(c(ecovars,scenvars))))
colnames(thin_2patch) = c(scenvars, ecovars)

j = 1 
for (proj in 1:length(climproj)) { 

    
    cmd1=sprintf("awk -f ../worldfiles/changec.awk thin=1 < ../worldfiles/redwood.2path.thin.test > ../worldfiles/redwood_warm_400-2patch.world.Y%dM10D1H1", startwy-1);
    system(cmd1)
    
    #cmd1=sprintf("awk -f ../flowtables/changeareaflow.v7.awk thin=%f <  ../flowtables/flow.newv > ../flowtables/flow.single.area.deep", 
    #            thinscen[thin]/100.0)
    #system(cmd1)
    
    tmp = sprintf("%d 10 1 1 redefine_world\n%d 10 1 2 print_daily_on\n%d 10 1 3 print_daily_growth_on",
                  startwy-1, startwy-1, startwy-1)
    write(tmp, file="../tecfiles/tec.thinb.deep")
    
    cmd2 = sprintf("%s -t ../tecfiles/tec.thinb.deep -w ../worldfiles/redwood_warm_400-2patch.world -r ../flowtables/Jackson-2patch.flow  -st %d 8 1 1 -ed %d 10 1 1 -pre ../out/JF_thin-proj -s 1 10 -gw 0 0 -whdr ../worldfiles/JacksonPatch-%s.hdr -b -p -g -c -climrepeat", 
                   rhessysver,startwy-10, endwy-1, climproj[proj]); 
    system(cmd2)
    
    # note running location
    print(c(proj))
    
    #read in data
    a = readin_rhessys_output("../out/JF_thin-proj", c=1,g=1,p=1)
    
    
    endj = j+length(a$bd$day)-1
    thin_2patch$scen[j:endj] = 2030
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
    thin_2patch$streamflow[j:endj] = a$pd$streamflow[a$pd$patchID == 3]
    thin_2patch$heigth[j:endj] = a$cd$height[a$cd$stratumID == 11 & a$cd$patchID == 3]
    
    
    
    j = endj+1
    endj = j+length(a$bd$day)-1
    thin_2patch$scen[j:endj] = 2030
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
    thin_2patch$streamflow[j:endj] = a$pd$streamflow[a$pd$patchID == 4]
    thin_2patch$heigth[j:endj] = a$cd$height[a$cd$stratumID == 11 & a$cd$patchID == 4]
    
    
    
    j = endj+1
    
  
}

tmp <- filter(thin_2patch, climproj == 'rcp85-had_early')
write.table(tmp, '../out/JF_thin-proj-rcp45-Had_early')

tmp <- filter(thin_2patch, climproj == 'rcp85-had_late')
write.table(tmp, '../out/JF_thin-proj-rcp45-Had_late')



