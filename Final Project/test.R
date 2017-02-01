## The Scriptors, Thijs van Loon, Jelle ten Harkel
## Final project
## Date 02-02-2017

library(rgdal)
library(sp)
library(SearchTrees)
library(maptools)
library(raster)

LocAdress <- "Nedereindseweg 215"
x <- geocode(location = LocAdress, source = "google", output = "latlon")

CRS_WGS <- CRS("+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0")
LocCoord_WGS_sp <- SpatialPoints(LocCoord_WGS, proj4string=CRS_WGS)
df <- data.frame(cbind(id = c(1), Name = c("Zoeklocatie")))
LocCoord_WGS_spdf <- SpatialPointsDataFrame(LocCoord_WGS, data = df, proj4string = CRS_WGS)

##Download map data
#Dike rings
download.file(url = 'http://profgeodata.basisinformatie-overstromingen.nl/geoserver/LBEO/ows?service=WFS&version=1.0.0&request=GetFeature&typeName=LBEO:dijkringen&outputFormat=SHAPE-ZIP', destfile = 'data/Dijkringen.zip', method = 'internal', mode='wb', quiet = TRUE)
unzip('data/Dijkringen.zip', exdir = "data")
file.remove('data/Dijkringen.zip', 'data/wfsrequest.txt')
dijkring <- readOGR("data","dijkringen")
dijkring <- spTransform(dijkring,CRS_WGS)

#Breach points
download.file(url = 'http://profgeodata.basisinformatie-overstromingen.nl/geoserver/VNK/ows?service=WFS&version=1.0.0&request=GetFeature&typeName=VNK:Doorbraaklocaties&outputFormat=SHAPE-ZIP' , destfile = 'data/Doorbraaklocaties.zip', method = 'internal', mode='wb', quiet = TRUE)
unzip('data/Doorbraaklocaties.zip', exdir = "data")
file.remove('data/Doorbraaklocaties.zip', 'data/wfsrequest.txt')
doorbraak <- readOGR("data","Doorbraaklocaties")
doorbraak <- spTransform(doorbraak,CRS_WGS)

## Intersect, byid to get a list of true and false(inside or outside the buffer)
dike2 <- intersect(dijkring, LocCoord_WGS_spdf)

dikenr <- dike2$DIJKRINGNR
dikenr <- levels(droplevels(dikenr))
test<- doorbraak[doorbraak$DIJKRINGNR==dikenr,]

tree <- createTree(coordinates(test))
inds <- knnLookup(tree, newdat=coordinates(LocCoord_WGS_spdf), k=1)
point <- test[inds[1,],]

doorbraak_dijkring <- test[test$DIJKRINGNR==dikenr,]
doorbraak_dijkring$nearest <- ifelse(doorbraak_dijkring$ID == point$ID,1,0)




