closest_breach_func <- function(x){
  CRS_WGS <- CRS("+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0")
  breach <- readOGR("data","Doorbraaklocaties")
  breach <- spTransform(breach,CRS_WGS)
  LocCoord_WGS_sp <- SpatialPoints(x, proj4string=CRS_WGS)
  df <- data.frame(cbind(id = c(1), Name = c("Zoeklocatie")))
  LocCoord_WGS_spdf <- SpatialPointsDataFrame(x, data = df, proj4string = CRS_WGS)
  
  tree <- createTree(coordinates(breach))
  inds <- knnLookup(tree, newdat=coordinates(LocCoord_WGS_spdf), k=1)
  point <- breach[inds[1,],]
  dikenr <- point$DIJKRINGNR
  dikenr <- levels(droplevels(dikenr))
  breach_dikenr <- breach[breach$DIJKRINGNR==dikenr,]
  breach_dikenr$nearest <- ifelse(breach_dikenr$ID == point$ID,1,0)
  return(breach_dikenr)
}