## The Scriptors, Thijs van Loon, Jelle ten Harkel
## Final project
## Date 02-02-2017

## Import required libraries and open function sources
library(shiny)
library(leaflet)
library(raster)
library (ggmap)
library(rgdal)
library(sp)
library(SearchTrees)
library(maptools)
source("R/source_data.R")
source("R/closest_locations.R")
source("R/retrieve_dry_locations.R")
source("R/dikes.R")

## initialise icons for the leafletmap
HomeIcon <- makeIcon(iconUrl = 'data/flood.png',  iconWidth = 32, iconHeight = 37, iconAnchorX = 16, iconAnchorY = 36, 
                     shadowUrl =  'data/marker-shadow.png', shadowWidth = 51, shadowHeight = 37, shadowAnchorX = 22, shadowAnchorY = 36) 
SafeIcon <- makeIcon(iconUrl = 'data/safe.png',  iconWidth = 32, iconHeight = 37, iconAnchorX = 16, iconAnchorY = 36, 
                     shadowUrl =  'data/marker-shadow.png', shadowWidth = 51, shadowHeight = 37, shadowAnchorX = 22, shadowAnchorY = 36) 
BreachNearIcon <- makeIcon(iconUrl = 'data/damNear.png',  iconWidth = 32, iconHeight = 37, iconAnchorX = 16, iconAnchorY = 36, 
                           shadowUrl =  'data/marker-shadow.png', shadowWidth = 51, shadowHeight = 37, shadowAnchorX = 22, shadowAnchorY = 36)
BreachIconList <- iconList(
  Near = makeIcon(iconUrl = 'data/damNear.png',  iconWidth = 32, iconHeight = 37, iconAnchorX = 16, iconAnchorY = 36, 
                  shadowUrl =  'data/marker-shadow.png', shadowWidth = 51, shadowHeight = 37, shadowAnchorX = 22, shadowAnchorY = 36,
                  popupAnchorX = 0, popupAnchorY = -37),
  Far = makeIcon(iconUrl = 'data/damFar.png',  iconWidth = 32, iconHeight = 37, iconAnchorX = 16, iconAnchorY = 36, 
                 shadowUrl =  'data/marker-shadow.png', shadowWidth = 51, shadowHeight = 37, shadowAnchorX = 22, shadowAnchorY = 36,
                 popupAnchorX = 0, popupAnchorY = -37) )
html_legend <- "<img src='http://profgeodata.basisinformatie-overstromingen.nl/geoserver/wms?service=WMS&amp;version=1.1.0&amp;request=GetLegendGraphic&amp;transparent=true&amp;height=20&amp;Format=image%2Fpng&amp;Style=waterdiepte_WV21&amp;layer=LBEO:Maximale waterdiepte NL_Group&amp;LEGEND_OPTIONS=forceLabels:on;fontSize:12;fontColor:0x111111;fontName:Verdana,Helvetica,Arial,sans-serif'>"

## Establish processes to create output to the user interface
server <- function(input, output, session) {
 # Get coordinates from adress input
  LocCoord_WGS <- eventReactive(input$GetLoc, {
    geocode(location = input$LocAdress, source = "google", output = "latlon")
  })
 # From the coordinates from LocCoord_WGS(), get the closest breach location and breach locations on the same dike  
  closest_breach <- eventReactive(input$GetLoc, {
    closest_breach_func(LocCoord_WGS())
  })  

 # From the breaches out closest_breach(), get the corresponding dike
 dikes <- eventReactive(input$GetLoc,{
  dikes_func(closest_breach()$DIJKRINGNR)
  })
 
 # From the coordinates from LocCoord_WGS(), get the nearest 5 safe location.
 safe_spot <-eventReactive(input$info, {
   dry_places_func(LocCoord_WGS())
 })
  
 # initial ouput of the leaflet map
  output$mymap <- renderLeaflet({
    leaflet() %>% addProviderTiles("Stamen.TonerLite")%>%
      addControl(html=html_legend, position = "bottomright")
  })
  
 # When actionbutton, submit adress is pushed, create leaflet map  
  observeEvent(input$GetLoc, {
    leafletProxy("mymap",data=LocCoord_WGS()) %>%
      clearMarkers()%>%
      clearShapes()%>%
      setView(lat=LocCoord_WGS()$lat, lng=LocCoord_WGS()$lon, zoom=10) %>% 
      addProviderTiles("Stamen.TonerLite") %>%
      addWMSTiles(
        "http://geodata.basisinformatie-overstromingen.nl/geoserver/wms?",
        layers="LBEO:Maximale waterdiepte NL_Group",
        options = WMSTileOptions (format= "image/png",transparent=TRUE, height=256, width=256, style="waterdiepte_WV21", opacity = 0.50),
        attribution = "Landelijk Informatiesysteem Water en Overstromingen (LIWO) 2011")%>%
      addMarkers(data=LocCoord_WGS(), popup=input$LocAdress, icon = HomeIcon)

  })
  # This code will check the output from dikes() for string data and then decides what to plot. 
  observeEvent(input$GetLoc, {
    if(class(dikes()) == "character") {
      output$safespot<-renderText(safe_spot())
    } else {
      leafletProxy("mymap") %>%
        addPolygons(data=dikes(), color = "black", fill=FALSE)}
  })
  
  # The code will check the output from closest_breach() for string data and then decides what to plot. 
  observeEvent(input$dangerous, {
    if(class(closest_breach()) == "character") {
      output$safespot<-renderText(closest_breach())
    } else {
      leafletProxy("mymap") %>%
        setView(lat=LocCoord_WGS()$lat, lng=LocCoord_WGS()$lon, zoom=10) %>%
        addMarkers(data=closest_breach(), popup= closest_breach()$NAAM, icon = BreachIconList[closest_breach()$nearest])}
  })
  
 # The code will check the output from safe_spot() for string data and then decides what to plot. 
  observeEvent(input$info, {
      if(class(safe_spot()) == "character") {
        output$safespot<-renderText(safe_spot())
    } else {
    leafletProxy("mymap") %>%
      setView(lat=LocCoord_WGS()$lat, lng=LocCoord_WGS()$lon, zoom=17) %>%
      addMarkers(data=safe_spot(), icon = SafeIcon)}
  })
}