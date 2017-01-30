closest_breach <- function(LocCoord_WGS){
  CRS_WGS <- CRS("+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0")
  doorbraak <- readOGR("data","Doorbraaklocaties")
  doorbraak <- spTransform(doorbraak,CRS_WGS)

  LocCoord_WGS_sp <- SpatialPoints(LocCoord_WGS, proj4string=CRS_WGS)
  df <- data.frame(cbind(id = c(1), Name = c("Zoeklocatie")))
  LocCoord_WGS_spdf <- SpatialPointsDataFrame(LocCoord_WGS, data = df, proj4string = CRS_WGS)
  
  tree <- createTree(coordinates(doorbraak))
  inds <- knnLookup(tree, newdat=coordinates(LocCoord_WGS_spdf), k=1)
  point <- doorbraak[inds[1,],]
  dijkringnr <- point$DIJKRINGNR
  dijkringnr <- levels(droplevels(dijkringnr))
  doorbraak_dijkring <- doorbraak[doorbraak$DIJKRINGNR==dijkringnr,]
  doorbraak_dijkring$nearest <- ifelse(doorbraak_dijkring$ID == point$ID,1,0)
  return(doorbraak_dijkring)
}