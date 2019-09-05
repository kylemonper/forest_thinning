library(shinydashboard)
library(shiny)
library(tidyverse)

thin_full <- read_csv('thin_full.csv')
met_date <- read_csv('met.csv')
thin_full$stemc_total <- (thin_full$stemc_dead+thin_full$stemc_live)/1000



####################~~~~~~~~~~~~~~~######################
####################      UI       ######################
####################~~~~~~~~~~~~~~~######################


################### Header ####################
header <- dashboardHeader(title = 'JDSF Report')


#####################  Sidebar ##################### 
sidebar <- dashboardSidebar(
  

  sidebarMenu(
              style = "position: fixed",

  
              menuItem("Info", tabName = 'about', icon = icon("fab fa-info-circle",lib='font-awesome'),
                       menuSubItem('Welcome', 'welcome', selected = T),
                       menuSubItem('intro & Summary', tabName = 'intro', icon = icon('list-alt'), selected = F),
                       menuSubItem('Using this App', tabName = 'guide', icon = icon('cog', lib = 'glyphicon'))),
              
              
              menuItem("Figures/results", tabName = 'dashboard', icon = icon("chart-bar", lib = 'font-awesome'), selected = F),
         
              
              #### github code link ####
              menuItem("View Code on Github", icon = icon("fab fa-github",lib='font-awesome'), 
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
        tabBox(width = 12, height = 12,
               
               
          ##### Carbon Panel #####     
          tabPanel('Carbon Dynamics', 
                   height = 8,
                   
                fluidRow(
                     column(width = 8,
                            box(width = 12, 
                                h3(strong('stem carbon response to thinning over time'), align = 'center'),
                                status = 'primary',
                                plotOutput("plantc"))
                            ),
                     column(width = 4,
                            box(width = 12,
                                status = 'warning',
                                tags$div(title = '(HISTORIC): refers to historical climate based on records from 1950-2015, (RCP 4.5):  stabilization scenario that assumes that climate policies, in this instance the introduction of a set of global greenhouse gas emissions prices, are invoked to achieve the goal of limiting emissions, concentrations and radiative forcing. (RCP 8.5): refers to the business as usual (BAU) scenario in which no policy intervention regarding global GHG emissions occurs.',
                                checkboxGroupInput("levels", 
                                                   label = h3("Select climate scenario"), 
                                                   choices = list("historic" = 'historic', 
                                                                  "RCP 4.5" = 'RCP-45', 
                                                                  "RCP 8.5 (BAU)" = 'RCP-85'),
                                                   selected = 'historic'))),
                            box(width = 12,
                                h4('Years to return to 90% of original stem carbon density for each model and thin scenario'),
                                align = 'center',
                                status = 'primary',
                                tableOutput('plantcTable'))
                            )
                     
                   )
                   ),
          
          ##### NPV Panel #####
          tabPanel('NPV', 
                   height = 8,
                   fluidRow(
                     column(width = 6,
                            box(width = 12,
                                title = h4(strong('net present value of forestland (in $/Sq.Meter)')),
                                soildHeader = T,
                                status = 'primary',
                                tableOutput('npv'))
                     ),
                     column(width = 6,
                            box(width = 12,
                                title = h4(strong('select values'),'(hover over each tool for more detail)'),
                                soilHeader = T,
                                status = 'warning',
                                
                                tags$div(title=paste("Price/Metric ton of carbon: Price given in currency per metric ton of elemental carbon. This is based on value estimates for damage costs associated with the release of an additional ton of carbon - the social cost of carbon"),
                                         numericInput('SCC', label = 'Social Cost of Carbon',
                                                      value = 40)),
                            
                                
                                tags$div(
                                  title="Market discount in Price of Carbon: reflects society’s preference for immediate benefits over future benefits. One default value is 7% per year, which is one of the market discount rates recommended by the U.S. government for cost-benefit evaluation of environmental projects. Philosophical arguments have been made for using a lower discount rate when modeling climate change related dynamics, which users may consider using. If the rate is set equal to 0% then monetary values are not discounted",
                              sliderInput('discount', label = 'Discount Rate',
                                        min = 0, max = 0.15, step = 0.01, value = 0.07)),
                              
                              tags$div(title="adjusts the value of sequestered carbon as the impact of emissions on expected climate change-related damages changes over time. Setting this rate greater than 0% suggests that the societal value of carbon sequestered in the future is less than the value of carbon sequestered now",
                               sliderInput('Cdiscount', label = 'Annual Rate of Cange in Carbon Price',
                                        min = -0.1, max = 0.1, step = 0.01, value = 0.02))
                            )

                     )
                    
                    )
                  ),
          
          ##### met data ####
          
          tabPanel('Weather Data',
                   fluidRow(
                     column(width = 12,
                       box(
                         width = 8,
                         'max and min temperatures for each model',
                         plotOutput('met')
                       )
                     )
                   ))
              
            )
          ),
    
    ##### Welcome Page ####
    tabItem(tabName = 'welcome',
           fluidRow(
             column(
               width = 10, align = 'center',
               box(title = h2('Jackson Demonstration State Forest Final Report', align = 'center'),
                   width = 12, solidHeader = T, status = 'primary',
                   column(width = 12, align = 'center',tags$img(src = 'pano.jpg', width = 800, heigth = 300, align = 'center')),
                   br(),
                   br(),
                   h4("This R Shiny App was created as a final deliverable for Why Forests Matter on behalf of the Tague Lab's 2019 summer intern. To begin, navigate to the 'Info' tab on the left sidepanel."))

             ))),

          
    ##### intro #####
    tabItem(tabName = 'intro',
            fluidRow(
              column(
                width = 8,
                box(title = h1('Report summary', align = 'center'),
                    width = 12, solidHeader = T, status = 'primary', 
                    h3(strong("Introduction")), 
                    ("     Planning for long-term sustainable forest management requires interdisciplinary knowledge of the economic and ecological implications of different forest management strategies. This already complicated subject becomes more difficult due to the uncertainties surrounding the future effects of climate change. The analysis done here sheds light upon how forests dynamics, subjected to different harvesting levels, may change in response to different climate scenarios."),
                    h3(strong('Summary Results')),
                    "For redwoods along California's north coast, warmer temperatures may lead to an increase in both growth rates and carbon content. Our results show that",
                    h3(strong('Methods')),
                    ("     The input data for RHESSys includes climate data and a series of maps that capture topographic, slope, aspect, and other land characteristics. The elevation map was taken from USGS’s ASTER GDEM data and has a spatial resolution of 25m. The other maps are built off the DEM, giving the smallest spatial unit in the model, or a patch, an area of about 625m2. We have started out by running a single patch in order to simplify the input maps and focus on the vegetation growth rather than spatial hydrology. The patch location was selected based on its proximity to the NOAA weather station that was originally used for climate input, but as we gathered more climate data we were able to generalize the patch area to represent a redwood stand in the Jackson State Demonstration Forest (JSDF). We did this by using Cal-Adapt’s downscaled climate projections and historical data sets. We used a shapefile of the JSDF boundaries taken from the US Forest Service to select the area over which to aggregate the precipitation, minimum temperature, and maximum temperature. The historical data ranges from 1950-2013 and the climate projections are from 2006 to 2099 or 2100, depending on the model. We used the 4 priority models (HadGEM2-ES, CNRM-CM5, CanESM2, MIROC5) for future scenarios to capture a range of precipitation variability. For future scenarios of warming we used two different trajectories of emissions - RCP4.5 and RCP8.5 - which gave us 8 different climate change scenarios overall.")
                  )),
              column( width = 4,
                      tags$img(src= 'trees.jpg', 
                               align = 'right',
                               width = 250))
            )
          ),
    
    tabItem(tabName = 'guide',
            'this is how you use the app'
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
          y = 'stem carbon (kg/m^2)'
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
     V <- input$SCC
     #discount rate
     r <- input$discount
     #carbon discount
     c <- input$Cdiscount
     
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
   
   ###### temps #####
   
   output$met <- renderPlot({
     
     temps <- met_date %>% 
       ungroup() %>%
       filter(climproj != 'JF') %>% 
       select(date, tmin, tmax, climproj) %>% 
       gather(unit, value, - date, -climproj)
     
     ggplot(temps, aes(x = date, y = value, color = unit)) +
       geom_line(alpha = .5) +
       facet_wrap(~climproj) + 
       labs(
         x = 'date',
         y = 'temp',
         title = 'yearly min and max temperatures for each model'
       )
     
   })
   
}

# Run the application 
shinyApp(ui = ui, server = server)


















