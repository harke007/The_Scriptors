## The Scriptors, Thijs van Loon, Jelle ten Harkel
## Final project
## Date 02-02-2017

## Get from the dikes shapefile the dike corresponding to the nearest breach location
dikes_func<-function(x){
  if(class(x) == "character") {
    message<-"you are outside a dikering"
    return(message)
  } else {
    x <- x$DIJKRINGNR
    x <- levels(droplevels(x))
    CRS_WGS <- CRS("+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0")
    dikes <- readOGR("data","dijkringen")
    dikes <- spTransform(dikes,CRS_WGS)
    dikes_selected <- dikes[dikes$DIJKRINGNR==x,]
    return(dikes_selected)}
}