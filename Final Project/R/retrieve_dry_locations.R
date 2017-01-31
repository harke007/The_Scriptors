## The Scriptors, Thijs van Loon, Jelle ten Harkel
## Final project
## Date 02-02-2017

# Function to get dry places
dry_places_func<- function(x){
  # Get data from LocCoordWGS
  CRS_WGS <- CRS("+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0")
  LocCoord_WGS_sp <- SpatialPoints(x, proj4string=CRS_WGS)
  df <- data.frame(cbind(id = c(1), Name = c("Zoeklocatie")))
  LocCoord_WGS_spdf <- SpatialPointsDataFrame(x, data = df, proj4string = CRS_WGS)
  LocCoord_RD_spdf <- spTransform(LocCoord_WGS_spdf,CRS=CRS("+init=epsg:28992"))
  
  ## Create Boundary Box
  dry_BboxOffset <- 1000 #as radius, in m (RD)
  dry_bbox_a1 <- round(LocCoord_RD_spdf@coords[1,'lon']-dry_BboxOffset)
  dry_bbox_a2 <- round(LocCoord_RD_spdf@coords[1,'lat']-dry_BboxOffset)
  dry_bbox_b1 <- round(LocCoord_RD_spdf@coords[1,'lon']+dry_BboxOffset)
  dry_bbox_b2 <- round(LocCoord_RD_spdf@coords[1,'lat']+dry_BboxOffset)
  dry_url_head <- 'http://profgeodata.basisinformatie-overstromingen.nl/geoserver/LBEO/ows?service=WFS&version=1.0.0&request=GetFeature&typeName=LBEO:Droge_plekken_NL&bbox='
  dry_url_tail <- '&srs=EPSG:28992&outputFormat=SHAPE-ZIP'
  dry_url <- paste0(dry_url_head,dry_bbox_a1,",",dry_bbox_a2,",",dry_bbox_b1,",",dry_bbox_b2,dry_url_tail)
  
  # download file and check file size to see if it contains any points, no data will give an error when opend in R...
  download.file(url = dry_url, destfile = 'data/DryPointsTemp.zip', method = 'internal', mode='wb', quiet = TRUE)
  if (file.size("data/DryPointsTemp.zip") <  1564){ 
    file.remove('data/DryPointsTemp.zip')
    message<-"You are on a safe position, relax!"
    return(message)
  # else unzip the file and remove the zip map
  } else {
    unzip('data/DryPointsTemp.zip', exdir = "data")
    file.remove('data/DryPointsTemp.zip', 'data/wfsrequest.txt')
    
    # create SPDF
    dry_locations_all_RD_spdf <- readShapePoints("data/Droge_plekken_NL.shp", proj4string = CRS("+init=epsg:28992"))
    dry_locations_RD_spdf <- dry_locations_all_RD_spdf[dry_locations_all_RD_spdf$cat==-1,] # selected only the dry locations (cat=-1)
    dry_locations_WGS_spdf <- spTransform(dry_locations_RD_spdf, CRS=CRS_WGS)
    
    # Get the number of rows out of the SPDF
    nk<-nrow(dry_locations_WGS_spdf)
    
    # For 0 dry points points return a message
    if (nk==0){
      message<-"No dry points in the neighbourhood"
      return(message)
      # else calculated nearest 5 points and return those a SPDF
    } else {
      tree <- createTree(coordinates(dry_locations_WGS_spdf))
      inds <- knnLookup(tree, newdat=coordinates(LocCoord_WGS_spdf), k=min(c(5,nk)))
      points <- dry_locations_WGS_spdf[inds[1,],]
      return(points)
    }
  }
}