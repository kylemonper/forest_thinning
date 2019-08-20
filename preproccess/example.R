


# edit this to point to where RHESSys is on your system
rhessysver = "/Users/kmonper/RHESSys-develop/bin/rhessys7.0"

# edit this to point to your scripts folder within the google drive
setwd('/Users/kmonper/Google Drive/JDSF/rhessys/scripts')


library(tidyverse)
library(lubridate)
library(RHESSysIOinR)



# this is to set dates for starting water year, 



# base name of climate files
climproj <- c('rcp45-MIROC', 'rcp85-MIROC')



# run awk file
cmd1=sprintf("awk -f ../worldfiles/changec.awk thin=1 < ../worldfiles/redwood.2path.thin.test > ../worldfiles/redwood_warm_400-2patch.world.Y%dM10D1H1", 2030);
system(cmd1)


#create tec file to perform thinning
tmp = sprintf("%d 10 1 1 redefine_world\n%d 10 1 2 print_daily_on\n%d 10 1 3 print_daily_growth_on",
             2030, 2030, 2030)
write(tmp, file="../tecfiles/tec.thinb.deep")


#run rhessys
cmd2 = sprintf("%s -t ../tecfiles/tec.thinb.deep -w ../worldfiles/redwood_warm_400-2patch.world -r ../flowtables/Jackson-2patch.flow  -st %d 8 1 1 -ed %d 10 1 1 -pre ../out/JF_thin-proj -s 1 10 -gw 0 0 -whdr ../worldfiles/JacksonPatch-%s.hdr -b -p -g -c -climrepeat", 
               rhessysver,2020, 2120, 'rcp45-MIROC'); 
system(cmd2)



#read in data
a = readin_rhessys_output("../out/JF_thin-proj", c=1,g=1,p=1)
