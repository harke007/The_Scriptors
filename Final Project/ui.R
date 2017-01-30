ui <- fluidPage(
  titlePanel("What is the waterdepth for my adress?"),
  sidebarLayout(
    sidebarPanel(
      textInput("LocAdress",
                "Enter your adress"),
      submitButton("Submit your adress"),
      textOutput("table")
    ),
    mainPanel(
      leafletOutput("mymap")
    )
  )
)