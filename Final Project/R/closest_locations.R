## The Scriptors, Thijs van Loon, Jelle ten Harkel
## Final project
## Date 02-02-2017

## Closest breach
closest_breach_func <- function(x){
  # Establish a crs
  CRS_WGS <- CRS("+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0")
  # open the shapefile containing all the breach locations and reproject
  breach <- readOGR("data","Doorbraaklocaties")
  breach <- spTransform(breach,CRS_WGS)
  
  # open the shapefile with dikerings
  dikes <- readOGR("data","dijkringen")
  dikes <- spTransform(dikes,CRS_WGS)
  
  # Make it a SpatialPointsDataFrame
  LocCoord_WGS_sp <- SpatialPoints(x, proj4string=CRS_WGS)
  df <- data.frame(cbind(id = c(1), Name = c("Zoeklocatie")))
  LocCoord_WGS_spdf <- SpatialPointsDataFrame(x, data = df, proj4string = CRS_WGS)
  
  # Intersect, to get only closest breach location for inside dikering
  dikes_select <- intersect(dikes, LocCoord_WGS_spdf)
  dikenr <- dikes_select$DIJKRINGNR
  dikenr <- levels(droplevels(dikenr))
  breach_sel<- breach[breach$DIJKRINGNR==dikenr,]
  
  nk<-nrow(breach_sel)
  
  # check if you are inside a dikering before calculating neareset breach
  if(nk==0){
    message<-"You are outside a dikering"
    return(message)
  } else {
    # find closest breach
    tree <- createTree(coordinates(breach_sel))
    inds <- knnLookup(tree, newdat=coordinates(LocCoord_WGS_spdf), k=1)
    
    # subset breach to the closest breach(point)
    point <- breach_sel[inds[1,],]
  
    # subset breach to the dikenumber and include a new column which shows the nearest breach location
    breach_dikenr <- breach_sel[breach_sel$DIJKRINGNR==dikenr,]
    breach_dikenr$nearest <- ifelse(breach_dikenr$ID == point$ID,"Near","Far")
    return(breach_dikenr)}
}