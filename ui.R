library(dygraphs)

shinyUI(fluidPage(
  
  titlePanel("Analysis Of Enviro Car Tracks Using R"),
  
  sidebarLayout(
    sidebarPanel(
      selectInput("param1", 
                  label = "Parameter 1",
                  choices = list("Speed", "Consumption",
                                 "Intake.Temperature", "Intake.Pressure","CO2","Calculated.MAF"),
                  selected = "Speed"),
      selectInput("param2", 
                  label = "Parameter 2",
                  choices = list("Speed", "Consumption",
                                 "Intake.Temperature", "Intake.Pressure","CO2","Calculated.MAF"),
                  selected = "CO2")
      
    
    ),
    mainPanel(
      dygraphOutput("dygraph")
    )
  )
))