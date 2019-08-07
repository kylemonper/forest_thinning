
# edit this to point to where RHESSys is on your system

rhessysver = "/Users/kmonper/RHESSys-develop/bin/rhessys7.0"

# use this to set different biomass removal amoubnts
thinscen = seq(from=0, to=100, by=30)
# also include a no-thin baseline scenario
thinscen[1] = 100


# determine which variables you want to save from RHESSys
ecovars = c("evap","trans","gpsn","resp","lai","cpool","plantc","precip","snow","streamflow")
scenvars = c("thin","scen","canopy","day","month","year")


library(tidyverse)
library(lubridate)
library(RHESSysIOinR)

# use this to set dates for starting water year, length of sim time
# and number of years between repeated start dates (e.g 5)
startwy = seq(from=1965, to=2015, by=45)
nyrs=15
endwy = startwy+nyrs 

setwd('/Users/kmonper/Google Drive/JDSF/rhessys/scripts')
# edit this to link to climate data
clim = read_rhessys_met("../clim/JF")

climscen = subset(clim, clim$wy >= startwy[1] & clim$wy < endwy[1]) 
nday=nrow(climscen)
nday = nday+2

nvals = length(thinscen)*3*nday*length(startwy)

# resthin.deep will store results - you should changes this to what every you want to call it
# so global chagne resthin.deep to your name
resthin.deep = as.data.frame(matrix(nrow=nvals, ncol=length(c(ecovars,scenvars))))
colnames(resthin.deep) = c(scenvars, ecovars)

j = 1 

for (scen in 1:length(startwy)) {

for (thin in 1:length(thinscen) ) {

cmd1=sprintf("awk -f ../worldfiles/changec.awk thin=%f < ../worldfiles/redwood_warm.world > ../worldfiles/world.test.Y%dM10D1H1", 
thinscen[thin]/100.0,startwy[scen]-1)
system(cmd1)

#cmd1=sprintf("awk -f ../flowtables/changeareaflow.v7.awk thin=%f <  ../flowtables/flow.newv > ../flowtables/flow.single.area.deep", 
 #            thinscen[thin]/100.0)
#system(cmd1)

tmp = sprintf("%d 10 1 1 redefine_world\n%d 10 1 2 print_daily_on\n%d 10 1 3 print_daily_growth_on",
startwy[scen]-1, startwy[scen]-1, startwy[scen]-1)
write(tmp, file="../tecfiles/tec.thinb.deep")

cmd2 = sprintf("%s -t ../tecfiles/tec.thinb.deep -w ../worldfiles/redwood_warm.world -r ../flowtables/JacksonPatch.flow  -st %d 8 1 1 -ed %d 10 1 1 -pre ../out/JF_thin  -s 15.247 97.112 -sv 15.247 128.231 -gw 1.0 0.900 -svalt 1.0 1.0 -b  -whdr ../worldfiles/JacksonPatch.hdr -b -tchange 0 0  -b -p -c  -b -climrepeat -tchange 0 0 -g", 
               rhessysver,startwy[scen]-10, endwy[scen]-1); 
system(cmd2)
a = readin_rhessys_output("../out/JF_thin", c=1,g=1,p=1)



endj = j+length(a$bd$day)-1
resthin.deep$scen[j:endj] = startwy[scen]
resthin.deep$thin[j:endj] = thinscen[thin]
resthin.deep$year[j:endj] = a$bd$year
resthin.deep$day[j:endj] = a$bd$day
resthin.deep$month[j:endj] = a$bd$month
resthin.deep$canopy[j:endj] = "control" 
resthin.deep$trans[j:endj] = a$cd$trans[a$cd$stratumID==11]
resthin.deep$lai[j:endj] = a$cd$lai[a$cd$stratumID==11]
resthin.deep$gpsn[j:endj] = a$cdg$psn_to_cpool[a$cdg$stratumID==11]
resthin.deep$resp[j:endj] = a$cdg$mresp[a$cdg$stratumID==11]+a$cdg$gresp[a$cdg$stratumID==11]
resthin.deep$evap[j:endj] = a$pd$evap[a$pd$patchID==3]+a$pd$evap_surface[a$pd$patchID==3]+a$pd$soil_evap[a$pd$patchID==3]
resthin.deep$cpool[j:endj] = a$cdg$cpool[a$cdg$stratumID==11]
resthin.deep$plantc[j:endj] = a$cdg$plantc[a$cdg$stratumID==11]
resthin.deep$precip[j:endj] = a$bd$precip
resthin.deep$snow[j:endj] = a$pd$snow[a$pd$patchID==3]
resthin.deep$streamflow[j:endj] = a$pd$streamflow[a$pd$patchID==11]

j = endj+1
endj = j+length(a$bd$day)-1
resthin.deep$scen[j:endj] = startwy[scen]
resthin.deep$thin[j:endj] = thinscen[thin]
resthin.deep$day[j:endj] = a$bd$day
resthin.deep$year[j:endj] = a$bd$year
resthin.deep$month[j:endj] = a$bd$month
resthin.deep$canopy[j:endj] = "thin" 
resthin.deep$trans[j:endj] = a$cd$trans[a$cd$stratumID==2]
resthin.deep$lai[j:endj] = a$cd$lai[a$cd$stratumID==2]
resthin.deep$gpsn[j:endj] = a$cdg$psn_to_cpool[a$cdg$stratumID==2]
resthin.deep$resp[j:endj] = a$cdg$mresp[a$cdg$stratumID==2]+a$cdg$gresp[a$cdg$stratumID==2]
resthin.deep$evap[j:endj] = a$pd$evap[a$pd$patchID==3]+a$pd$evap_surface[a$pd$patchID==3]+a$pd$soil_evap[a$pd$patchID==3]
resthin.deep$cpool[j:endj] = a$cdg$cpool[a$cdg$stratumID==2]
resthin.deep$plantc[j:endj] = a$cdg$plantc[a$cdg$stratumID==2]
resthin.deep$precip[j:endj] = a$bd$precip
resthin.deep$snow[j:endj] = a$pd$snow[a$pd$patchID==1]
resthin.deep$streamflow[j:endj] = a$pd$streamflow[a$pd$patchID==1]

j = endj+1
endj = j+length(a$bd$day)-1

resthin.deep$scen[j:endj] = startwy[scen]
resthin.deep$thin[j:endj] = thinscen[thin]
resthin.deep$canopy[j:endj] = "both" 
resthin.deep$year[j:endj] = a$bd$year
resthin.deep$day[j:endj] = a$bd$day
resthin.deep$month[j:endj] = a$bd$month
resthin.deep$trans[j:endj] = a$bd$trans
resthin.deep$lai[j:endj] = a$bd$lai
resthin.deep$gpsn[j:endj] = a$bdg$gpsn
resthin.deep$resp[j:endj] = a$bdg$plant_resp
resthin.deep$evap[j:endj] = a$bd$evap
resthin.deep$cpool[j:endj] = a$bdg$cpool
resthin.deep$plantc[j:endj] = a$bdg$plantc
resthin.deep$precip[j:endj] = a$bd$precip
resthin.deep$snow[j:endj] = a$bd$snowpack
resthin.deep$streamflow[j:endj] = a$bd$streamflow

j = endj+1
}
}

resthin.deep$soil="deep"
write.table(resthin.deep, file="resthin.test.txt")
