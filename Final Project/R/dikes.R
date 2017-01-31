dikes_func<-function(x){
  x <- levels(droplevels(x))
  CRS_WGS <- CRS("+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0")
  dikes <- readOGR("data","dijkringen")
  dikes <- spTransform(dikes,CRS_WGS)
  dikes_selected <- dikes[dikes$DIJKRINGNR==x,]
  return(dikes_selected)
}