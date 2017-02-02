## The Scriptors, Thijs van Loon, Jelle ten Harkel
## Final project
## Date 02-02-2017

## Get from the dikes shapefile the dike corresponding to the nearest breach location
dikes_func<-function(x){
  # test if closest_breaches() is not a string (which happens if you are outside a dikering)
  if(class(x) == "character") {
    message<-"You are outside a dikering, no dike to show"
    return(message)
    
    # else get the dike ring corresponding to the dikenumber found in closest_breaches()
  } else {
    x <- x$DIJKRINGNR
    x <- levels(droplevels(x))
    CRS_WGS <- CRS("+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0")
    dikes <- readOGR("data","dijkringen")
    dikes <- spTransform(dikes,CRS_WGS)
    dikes_selected <- dikes[dikes$DIJKRINGNR==x,]
    return(dikes_selected)}
}