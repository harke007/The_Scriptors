## The Scriptors, Thijs van Loon, Jelle ten Harkel
## Final project
## Date 02-02-2017

hospital_func <- function(x){
  # select only the lat lon columns
  x<-x[,1:2]
  
  # Get data from LocCoordWGS
  CRS_WGS <- CRS("+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0")
  hospitals <- readOGR("data","hospitals_2013")
  hospitals <- hospitals[hospitals$soort_omsc!="Buitenpolikliniek",]
  hospitals <- spTransform(hospitals,CRS_WGS)
  
  # Make it a SpatialPointsDataFrame
  LocCoord_WGS_sp <- SpatialPoints(x, proj4string=CRS_WGS)
  df <- data.frame(cbind(id = c(1), Name = c("Zoeklocatie")))
  LocCoord_WGS_spdf <- SpatialPointsDataFrame(x, data = df, proj4string = CRS_WGS)
  
  # find closest hospital
  tree <- createTree(coordinates(hospitals))
  inds <- knnLookup(tree, newdat=coordinates(LocCoord_WGS_spdf), k=1)
  
  # subset hospitals to the closest hospital
  hospital <- hospitals[inds[1,],]
  hospitals$nearest <- ifelse(hospitals$ziekenh_nr == hospital$ziekenh_nr,"Near","Far")
  return(hospitals)
}