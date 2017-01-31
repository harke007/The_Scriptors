library(leaflet)
ui <- fluidPage(
  titlePanel("What is the waterdepth for my adress?"),
  sidebarLayout(
    sidebarPanel(
      textInput("LocAdress",
                "Enter your adress"),
      actionButton("GetLoc","Submit your adress", 
                   style="color: #fff; background-color: #337ab7; border-color: #2e6da4",width='100%'),
      actionButton("info","Show safe places",width='100%'),
      actionButton("dangerous", "Show possible breaches",width='100%'),
      h4(
      tags$style(type='text/css',"#safespot{color: #ff0000;
                                            text-align: center;}"),
      textOutput('safespot')),
      imageOutput("iconsmeaning", width = '100%')


    ),
    mainPanel(
      leafletOutput("mymap", height= 617, width = '100%')
    )
)
)