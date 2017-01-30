##Import required libraries
library(shiny)
library(leaflet)
library (ggmap)
library(rgdal)
library(sp)
library(SearchTrees)
source("R/source_data.R")
source("R/closest_locations.R")

## initialise icons
HomeIcon <- makeIcon(iconUrl = 'data/flood.png',  iconWidth = 32, iconHeight = 37, iconAnchorX = 16, iconAnchorY = 36, 
                     shadowUrl =  'data/marker-shadow.png', shadowWidth = 51, shadowHeight = 37, shadowAnchorX = 22, shadowAnchorY = 36) 
SafeIcon <- makeIcon(iconUrl = 'data/safe.png',  iconWidth = 32, iconHeight = 37, iconAnchorX = 16, iconAnchorY = 36, 
                     shadowUrl =  'data/marker-shadow.png', shadowWidth = 51, shadowHeight = 37, shadowAnchorX = 22, shadowAnchorY = 36) 
BreachNearIcon <- makeIcon(iconUrl = 'data/damNear.png',  iconWidth = 32, iconHeight = 37, iconAnchorX = 16, iconAnchorY = 36, 
                           shadowUrl =  'data/marker-shadow.png', shadowWidth = 51, shadowHeight = 37, shadowAnchorX = 22, shadowAnchorY = 36) 
BreachFarIcon <- makeIcon(iconUrl = 'data/damFar.png',  iconWidth = 32, iconHeight = 37, iconAnchorX = 16, iconAnchorY = 36, 
                          shadowUrl =  'data/marker-shadow.png', shadowWidth = 51, shadowHeight = 37, shadowAnchorX = 22, shadowAnchorY = 36) 

##Establish processes to create output to the user interface
server <- function(input, output, session) {
  
  LocCoord_WGS <- reactive(({
    geocode(location = input$LocAdress, source = "google", output = "latlon")
  }))
  
  output$mymap <- renderLeaflet({
    leaflet() %>% addProviderTiles("Stamen.TonerLite")
  })
  
  observe({
    leafletProxy("mymap",data=LocCoord_WGS()) %>%
      setView(lat=LocCoord_WGS()$lat, lng=LocCoord_WGS()$lon, zoom=10) %>% 
      addProviderTiles("Stamen.TonerLite") %>%
      addWMSTiles(
        "http://geodata.basisinformatie-overstromingen.nl/geoserver/wms?",
        #service="WMS&REQUEST=GetMap&VERSION=1.1.1",
        layers="LBEO:Maximale waterdiepte NL_Group",
        options = WMSTileOptions (format= "image/png",transparent=TRUE, height=256, width=256, style="waterdiepte_WV21", opacity = 0.50))%>%
      addMarkers(data=LocCoord_WGS(), popup=input$LocAdress, icon = HomeIcon)
  })
}