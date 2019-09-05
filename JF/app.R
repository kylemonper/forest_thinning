library(shinydashboard)
library(shiny)
library(tidyverse)

thin_full <- read_csv('thin_full.csv')
thin_full$stemc_total <- thin_full$stemc_dead+thin_full$stemc_live



####################~~~~~~~~~~~~~~~######################
####################      UI       ######################
####################~~~~~~~~~~~~~~~######################


################### Header ####################
header <- dashboardHeader(title = 'JDSF Report')


#####################  Sidebar ##################### 
sidebar <- dashboardSidebar(
  

  sidebarMenu(
              style = "position: fixed",

  
              menuItem("About", tabName = 'about', icon = icon("fab fa-info-circle",lib='font-awesome')),
              
              
              menuItem("Dashboard", tabName = 'dashboard', icon = icon("dashboard")),
         
              
              #### github code link ####
              menuItem("View Code", icon = icon("fab fa-github",lib='font-awesome'), 
                       href = "https://github.com/kylemonper/forest_thinning"),
              
              #### RHesssys link ####
              menuItem("RHESSys Wiki", icon = icon("fab fa-wikipedia-w",lib='font-awesome'), 
                       href = "https://github.com/RHESSys/RHESSys/wiki")
              

      )
  )



#################  body ##################### 
body <- dashboardBody(
  tabItems(
    ##### Dashboard #####
    tabItem(tabName = "dashboard",
        tabBox(width = 12, height = 8,
          tabPanel('Carbon Dynamics', 'stem carbon response to thinning over time', height = 8,
                   fluidRow(
                     box(width = 8,
                         plotOutput("plantc")),
                     box(width = 4,
                         checkboxGroupInput("levels", 
                                            label = h3("Select climate scenario"), 
                                            choices = list("historic" = 'historic', 
                                                           "RCP 4.5" = 'RCP-45', 
                                                           "RCP 8.5 (BAU)" = 'RCP-85'),
                                            selected = 'historic'))
                   )

                   ),
          tabPanel('response table', 'number of years until stemc returns to 90% of original levels for each model and thinning treatment', height = 8,
              tableOutput('plantcTable')
              ),
          tabPanel('NPV', 'net present value of of each m2 of forestland (in dollars)', height = 8,
                   box(tableOutput('npv'))
                   )
              
            )
          ),
          
    ##### About Page #####
    tabItem(tabName = 'about',
            fluidRow(
              column(
                width = 8,
                box(title = h1('Jackson Demonstration State Forest Report', align = 'center'),
                    width = 12, solidHeader = T, status = 'primary', 
                    h3(strong("Introduction")), 
                    ("     Planning for long-term sustainable forest management requires interdisciplinary knowledge of the economic and ecological implications of different forest management strategies. This already complicated subject becomes more difficult due to the uncertainties surrounding the future effects of climate change. The research being done here will shed light upon how forests dynamics, subjected to different harvesting levels, may change in response to different climate scenarios."),
                    h3(strong('Summary Results')),
                    "Warmer temperatures will likely increase the growth rate of redwoods along California's north coast.",
                    h3(strong('Methods')),
                    ("     The input data for RHESSys includes climate data and a series of maps that capture topographic, slope, aspect, and other land characteristics. The elevation map was taken from USGS’s ASTER GDEM data and has a spatial resolution of 25m. The other maps are built off the DEM, giving the smallest spatial unit in the model, or a patch, an area of about 625m2. We have started out by running a single patch in order to simplify the input maps and focus on the vegetation growth rather than spatial hydrology. The patch location was selected based on its proximity to the NOAA weather station that was originally used for climate input, but as we gathered more climate data we were able to generalize the patch area to represent a redwood stand in the Jackson State Demonstration Forest (JSDF). We did this by using Cal-Adapt’s downscaled climate projections and historical data sets. We used a shapefile of the JSDF boundaries taken from the US Forest Service to select the area over which to aggregate the precipitation, minimum temperature, and maximum temperature. The historical data ranges from 1950-2013 and the climate projections are from 2006 to 2099 or 2100, depending on the model. We used the 4 priority models (HadGEM2-ES, CNRM-CM5, CanESM2, MIROC5) for future scenarios to capture a range of precipitation variability. For future scenarios of warming we used two different trajectories of emissions - RCP4.5 and RCP8.5 - which gave us 8 different climate change scenarios overall.")
                  )),
              column( width = 4,
                      tags$img(src= 'trees.jpg', align = 'right'))
            )
          )
  )
)
    
 
            
             


ui <- dashboardPage(header, sidebar, body)



####################~~~~~~~~~~~~~~~######################
####################    Server     ######################
####################~~~~~~~~~~~~~~~######################

server <- function(input, output, session) {
   
  
#################  Stemc Plot #################  
  stemc_total <- reactive({
    thin_full %>% 
      filter(level %in% input$levels) %>% 
      group_by(wyg, thin, level) %>% 
      summarise(
        mean = mean(stemc_total),
        lower=quantile(stemc_total, probs=0.1), 
        upper=quantile(stemc_total, probs=0.90))
    
  })
  
   output$plantc <- renderPlot({
      # generate bins based on input$bins from ui.R
     
      
      ggplot(stemc_total(), aes(x=wyg, y=mean, group = level, fill = level)) +
        geom_line() +
        geom_hline(yintercept = stemc_total()$mean[stemc_total()$thin==100 & stemc_total()$wyg == 0], color = 'darkgreen', size = 1) + # do we want to visually compare against starting value of the control, or the mean, or...?
        facet_wrap(~thin) +
        geom_ribbon(aes(ymin=lower, ymax=upper), alpha = .3) +
        labs(
          x = 'years after thin',
          y = 'stem carbon',
          title = 'change in TOTAL stem carbon over time by thinning %'
        )
   })
   

   
################# retrun Table #################   
   output$plantcTable <- renderTable({
     
     flux <- thin_full %>% 
       filter(level %in% input$levels) %>% 
       group_by(wyg, thin, climproj) %>% 
       summarise(
         mean = mean(stemc_total),
         sd = sd(stemc_total)
       )
     
     tmp <- flux %>% 
       ungroup() %>% 
       filter(wyg == 0, thin == 100) %>% 
       select(climproj, mean) %>% 
       mutate(target = mean*.9)
     
     
     thin <- unique(flux$thin)
     
     res <- data.frame()
     
     climscen <- unique(flux$climproj)
     
     res[1:length(climscen),1] <- climscen
     
     for (i in 1:length(climscen)) {
       for (j in 1:length(thin)) {
         
         target <- tmp$target[tmp$climproj == climscen[i]]
         res[i,j+1] <- min(flux$wyg[flux$climproj == climscen[i] & flux$thin == thin[j] & flux$mean >= target])  
         
       }
     }
     names(res) <- c('climproj', thin)
     
     for (i in 1:length(res)) {
       res[,i][res[,i] == Inf] <- '>99'
     }
     
     res
   })
   
   
   ############# NPV Table ##############
   output$npv <- renderTable({
     
     #### using invest NPV formula for carbon
     
     
     #define start and end years of interest
     start <- 0
     end <- 99
     
     ## calculate mean plantc for each level at start and end years
     plantc_chg <- thin_full %>% 
       filter(wyg %in% c(start,end)) %>% 
       group_by(wyg, thin, level) %>% 
       summarise(plantc = mean(plantc))
     
     
     #calculate differnece
     delta <- as.data.frame(matrix(nrow = nrow(plantc_chg)/2, ncol = 3))
     names(delta) <- c('level', 'thin','diff')
     
     delta$diff <- round(plantc_chg$plantc[plantc_chg$wyg == end] - plantc_chg$plantc[plantc_chg$wyg == start],2)/1000
     delta$level <- plantc_chg$level[1:18]
     delta$thin <- plantc_chg$thin[1:18]
     
     
     #summary table of differences
     table <- delta %>% 
       spread(thin, diff)
     
     
     ## calculate npv
     
     # value of elemental carbon
     V <- 40
     #discount rate
     r <- .07
     #carbon discount
     c <- .02
     
     time <- end-start
     x <- vector()
     for(i in 1:time){
       
       x[i] <- 1/( ((1+r)^i) * ((1+c)^i))
       
     }
     discount <- sum(x)
     
     
     npv <- delta %>% 
       mutate(npv = V*(diff*10/time)*discount) %>% 
       select(-diff) %>% 
       spread(thin, npv)
     
     npv
     
   })
   
}

# Run the application 
shinyApp(ui = ui, server = server)


















