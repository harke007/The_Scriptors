library(rgdal)
library(sp)
library(SearchTrees)

LocAdress <- "Nedereindseweg 215"
LocCoord_WGS <- geocode(location = LocAdress, source = "google", output = "latlon")

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

tree <- createTree(coordinates(doorbraak))
inds <- knnLookup(tree, newdat=coordinates(LocCoord_WGS_spdf), k=1)
point <- doorbraak[inds[1,],]
dijkringnr <- point$DIJKRINGNR
dijkringnr <- levels(droplevels(dijkringnr))
doorbraak_dijkring <- doorbraak[doorbraak$DIJKRINGNR==dijkringnr,]
doorbraak_dijkring$nearest <- ifelse(doorbraak_dijkring$ID == point$ID,1,0)




