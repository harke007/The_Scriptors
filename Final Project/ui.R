## The Scriptors, Thijs van Loon, Jelle ten Harkel
## Final project
## Date 02-02-2017

## Import library(leaflet) to let leafletOutput work
library(leaflet)

## User interface for the shiny application
ui <- fluidPage(
  sidebarLayout(
    sidebarPanel(
      h1("If the water rises"),
      textInput("LocAdress",label = NULL, placeholder = "Enter your home adress here"),
      actionButton("GetLoc","Submit your adress", 
                   style="color: #fff; background-color: #337ab7; border-color: #2e6da4",width='100%'),
      actionButton("info","Show safe places",width='100%'),
      actionButton("dangerous", "Show possible breaches",width='100%'),
      h4(
      tags$style(type='text/css',"#message{color: #ff0000;
                                            text-align: center;}"),
      textOutput('message')),
      p(),
      p("Our dikes protect us against flooding, but it can go wrong..."),
      p("For every person living in the blue region there is a chance of 10% that they experience a flooding once in their lifetime."),
      p("Therefore it is important to know what can happen, only then you can prepare properly. The main question is; Should I stay or should I go?"),
      p("This tool helps you to know wether and where to go to in such a case."),
      p(),
      p("After entering an adress, you can see your 'dike ring' by the black line. This line represents the area arround you which is enclosed by either a dike or higher ground. 
        If there is a breach at any part of this dike, you've got a problem."),
      p("Besides your own adress the closest hospital is shown in green. It may be better to flee to another hospital, therefore all near hospitals are shown"),
      p(),
      p("Your house may be flooded by several meters in a matter of hours. The 'Show safe places' button shows the 5 nearest buildings which are high enough to have a dry floor. 
        For this calculation there has been assumed that every floor is about 2.5m high."),
      p(),
      p("The maximum water depth is calculated by multiple scenarios of breaches in the dikering. The closest breach scenario is often decisive, which is shown in red.")


    ),
# The leaflet plot area
    mainPanel(
      leafletOutput("mymap", height= 738, width = '100%')
    )
)
)