## The Scriptors, Thijs van Loon, Jelle ten Harkel
## Final project
## Date 02-02-2017

## Import required libraries and open function sources
library(shiny)
library(leaflet)
library(raster)
library(ggmap)
library(rgdal)
library(sp)
library(SearchTrees)
library(maptools)
library(rgeos)
source("R/source_data.R")
source("R/closest_locations.R")
source("R/retrieve_dry_locations.R")
source("R/dikes.R")
source("R/hospitals.R")

## initialise icons for the leafletmap
HomeIcon <- makeIcon(iconUrl = 'data/flood.png',  iconWidth = 32, iconHeight = 37, iconAnchorX = 16, iconAnchorY = 36, 
                     shadowUrl =  'data/marker-shadow.png', shadowWidth = 51, shadowHeight = 37, shadowAnchorX = 22, shadowAnchorY = 36,
                     popupAnchorX = 1, popupAnchorY = -32) 
SafeIcon <- makeIcon(iconUrl = 'data/safe.png',  iconWidth = 32, iconHeight = 37, iconAnchorX = 16, iconAnchorY = 36, 
                     shadowUrl =  'data/marker-shadow.png', shadowWidth = 51, shadowHeight = 37, shadowAnchorX = 22, shadowAnchorY = 36,
                     popupAnchorX = 1, popupAnchorY = -32) 
BreachNearIcon <- makeIcon(iconUrl = 'data/damNear.png',  iconWidth = 32, iconHeight = 37, iconAnchorX = 16, iconAnchorY = 36, 
                           shadowUrl =  'data/marker-shadow.png', shadowWidth = 51, shadowHeight = 37, shadowAnchorX = 22, shadowAnchorY = 36,
                           popupAnchorX = 1, popupAnchorY = -32)
BreachIconList <- iconList(
  Near = makeIcon(iconUrl = 'data/damNear.png',  iconWidth = 32, iconHeight = 37, iconAnchorX = 16, iconAnchorY = 36, 
                  shadowUrl =  'data/marker-shadow.png', shadowWidth = 51, shadowHeight = 37, shadowAnchorX = 22, shadowAnchorY = 36,
                  popupAnchorX = 1, popupAnchorY = -32),
  Far = makeIcon(iconUrl = 'data/damFar.png',  iconWidth = 32, iconHeight = 37, iconAnchorX = 16, iconAnchorY = 36, 
                 shadowUrl =  'data/marker-shadow.png', shadowWidth = 51, shadowHeight = 37, shadowAnchorX = 22, shadowAnchorY = 36,
                 popupAnchorX = 1, popupAnchorY = -32))
HospitalIconList <- iconList(
  Near = makeIcon(iconUrl = 'data/hospitalNear.png',  iconWidth = 32, iconHeight = 37, iconAnchorX = 16, iconAnchorY = 36, 
                  shadowUrl =  'data/marker-shadow.png', shadowWidth = 51, shadowHeight = 37, shadowAnchorX = 22, shadowAnchorY = 36,
                  popupAnchorX = 1, popupAnchorY = -32),
  Far = makeIcon(iconUrl = 'data/hospitalFar.png',  iconWidth = 32, iconHeight = 37, iconAnchorX = 16, iconAnchorY = 36, 
                 shadowUrl =  'data/marker-shadow.png', shadowWidth = 51, shadowHeight = 37, shadowAnchorX = 22, shadowAnchorY = 36,
                 popupAnchorX = 1, popupAnchorY = -32))

## create legend for the leafletmap
html_legend <- "<table>
<tr><th colspan='2'><b> Icons </b></th><th><b> Max depth [m] </b></th></tr>
<tr><td><img width='75%' height=auto src='https://raw.githubusercontent.com/harke007/The_Scriptors/master/Final%20Project/data/flood.png'></td><td width='157px'> Your adress </td>
<td rowspan='6'><div class='width: auto; height: 242px'; style='overflow:hidden'><img style='margin-top:-70px'; src='http://profgeodata.basisinformatie-overstromingen.nl/geoserver/wms?service=WMS&amp;version=1.1.0&amp;request=GetLegendGraphic&amp;transparent=true&amp;height=20&amp;Format=image%2Fpng&amp;Style=waterdiepte_WV21&amp;layer=LBEO:Maximale waterdiepte NL_Group&amp;LEGEND_OPTIONS=forceLabels:on;fontSize:14;fontColor:0x111111;fontName:Arial'></div></td></tr>
<tr><td><img width='75%' height=auto src='https://raw.githubusercontent.com/harke007/The_Scriptors/master/Final%20Project/data/hospitalFar.png'></td><td> Hospitals </td></tr>
<tr><td><img width='75%' height=auto src='https://raw.githubusercontent.com/harke007/The_Scriptors/master/Final%20Project/data/hospitalNear.png'></td><td> Closest Hospital </td></tr>
<tr><td><img width='75%' height=auto src='https://raw.githubusercontent.com/harke007/The_Scriptors/master/Final%20Project/data/safe.png'></td><td> Closest 5 safe places </td></tr>
<tr><td><img width='75%' height=auto src='https://raw.githubusercontent.com/harke007/The_Scriptors/master/Final%20Project/data/damFar.png'></td><td> Possible dike breaches </td></tr>
<tr><td><img width='75%' height=auto src='https://raw.githubusercontent.com/harke007/The_Scriptors/master/Final%20Project/data/damNear.png'></td><td> Closest possible breach</td></tr>
</table>"

## Establish processes to create output to the user interface
server <- function(input, output, session) {
 # Get coordinates from adress input
  LocCoord_WGS <- eventReactive(input$GetLoc, {
    if(input$LocAdress == ""){geocode(location = "Onze Lieve Vrouwetoren, Amersfoort", source = "google", output = "latlona")}
    else {geocode(location = paste0(input$LocAdress, ", Nederland"), source = "google", output = "latlona")}
  })
  
 # From the coordinates from LocCoord_WGS(), get the nearest hospital
  hospitals <-eventReactive(input$GetLoc, {
    hospital_func(LocCoord_WGS())
    })
  
 # From the coordinates from LocCoord_WGS(), get the closest breach location and breach locations on the same dike  
  closest_breach <- eventReactive(input$GetLoc, {
    closest_breach_func(LocCoord_WGS())
    })  

 # From the breaches out closest_breach(), get the corresponding dike
 dikes <- eventReactive(input$GetLoc,{
  dikes_func(closest_breach())
  })
 
 # From the coordinates from LocCoord_WGS(), get the nearest 5 safe location.
 safe_spot <-eventReactive(input$info, {
   dry_places_func(LocCoord_WGS())
   })
  
 # initial ouput of the leaflet map
  output$mymap <- renderLeaflet({
    leaflet() %>% addProviderTiles("Stamen.TonerLite")%>%
      setView(lat=52.16, lng=5.39,zoom=7)%>%
      addControl(html=html_legend, position = "bottomright") })
  
 # reset the message box  
  observeEvent(input$GetLoc,{
    output$message<-renderText(" ")
  })
  
 # When actionbutton, submit adress is pushed, create leaflet map  
  observeEvent(input$GetLoc, {
    leafletProxy("mymap") %>%
      clearMarkers()%>%
      clearShapes()%>%
      setView(lat=LocCoord_WGS()$lat, lng=LocCoord_WGS()$lon, zoom=10) %>% 
      addProviderTiles("Stamen.TonerLite") %>%
      addWMSTiles(
        "http://geodata.basisinformatie-overstromingen.nl/geoserver/wms?",
        layers="LBEO:Maximale waterdiepte NL_Group",
        options = WMSTileOptions (format= "image/png",transparent=TRUE, height=256, width=256, style="waterdiepte_WV21", opacity = 0.50),
        attribution = "Landelijk Informatiesysteem Water en Overstromingen (LIWO) 2011")%>%
      addMarkers(data=LocCoord_WGS(), popup=LocCoord_WGS()$address, icon = HomeIcon, options = markerOptions(zIndexOffset=1000))
  })
  # code to add the hospitals to the map
  observeEvent(input$GetLoc, {
    leafletProxy("mymap")%>%
      addMarkers(data=hospitals(), popup= paste(hospitals()$naam_kaart,",<br>",hospitals()$plaats,",<br>",paste0("<a href=",hospitals()$web_text),"target='_blank'>Website of the hospital"), icon = HospitalIconList[hospitals()$nearest])
  })

  # This code will check the output from dikes() for string data and then decides what to plot. 
  observeEvent(input$GetLoc, {
    if(class(dikes()) == "character") {
      output$message<- renderText(dikes())
    } else {
      leafletProxy("mymap") %>%
        addPolygons(data=dikes(), color = "black", fill=FALSE)}
  })
  
  # The code will check the output from closest_breach() for string data and then decides what to plot. 
  observeEvent(input$dangerous, {
    if(class(closest_breach()) == "character") {
      output$message<-renderText(closest_breach())
    } else {
      leafletProxy("mymap") %>%
        setView(lat=LocCoord_WGS()$lat, lng=LocCoord_WGS()$lon, zoom=10) %>%
        addMarkers(data=closest_breach(), popup= closest_breach()$NAAM, icon = BreachIconList[closest_breach()$nearest])}
  })
  
 # The code will check the output from safe_spot() for string data and then decides what to plot. 
  observeEvent(input$info, {
      if(class(safe_spot()) == "character") {
        output$message<-renderText(safe_spot())
    } else {
      output$message<-renderText(" ")
      leafletProxy("mymap") %>%
        setView(lat=LocCoord_WGS()$lat, lng=LocCoord_WGS()$lon, zoom=17) %>%
        addMarkers(data=safe_spot(), popup=safe_spot()$address, icon = SafeIcon)}
  })
}