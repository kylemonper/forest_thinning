library(shinydashboard)
library(shiny)
library(tidyverse)

thin_full <- read_csv('~/RHESSys/forest_thinning/thin_full.csv')
thin_full$stemc_total <- thin_full$stemc_dead+thin_full$stemc_live

climscen <- c('rcp45-Had', 'rcp45-MIROC', 'rcp45-CNRM', 'rcp45-CAN', 'rcp85-Had', 'rcp85-MIROC', 'rcp85-CNRM', 'rcp85-CAN','historic')


####################~~~~~~~~~~~~~~~######################
####################   Server      #######################
####################~~~~~~~~~~~~~~~######################



header <- dashboardHeader(title = 'JDSF')

sidebar <- dashboardSidebar(
  
  
  sidebarMenu(width= 2,
              style = "position: fixed;width:16%;",
              
               checkboxGroupInput("levels", 
                                  label = h3("Select climate level"), 
                     choices = list("historic" = 'historic', 
                                    "RCP 4.5" = 'RCP-45', 
                                    "RCP 8.5" = 'RCP-85'),
                     selected = 'historic'))
)

body <- dashboardBody(
            fluidRow(
               plotOutput("plantc")),
            fluidRow(
              tableOutput('plantcTable')))
             


ui <- dashboardPage(header, sidebar, body)



# Define server logic required to draw a histogram
server <- function(input, output, session) {
   
  
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
        geom_hline(yintercept = stemc_tot$mean[stemc_tot$thin==100 & stemc_tot$wyg == 0], color = 'darkgreen', size = 1) + # do we want to visually compare against starting value of the control, or the mean, or...?
        facet_wrap(~thin) +
        geom_ribbon(aes(ymin=lower, ymax=upper), alpha = .3) +
        labs(
          x = 'years after thin',
          y = 'stem carbon',
          title = 'change in TOTAL stem carbon over time by thinning %'
        )
   })
   

   
   
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
   
}

# Run the application 
shinyApp(ui = ui, server = server)


















