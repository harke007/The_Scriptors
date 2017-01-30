##Download map data
#Dike rings
CRS_WGS <- CRS("+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0")
download.file(url = 'http://profgeodata.basisinformatie-overstromingen.nl/geoserver/LBEO/ows?service=WFS&version=1.0.0&request=GetFeature&typeName=LBEO:dijkringen&outputFormat=SHAPE-ZIP', destfile = 'data/Dijkringen.zip', method = 'internal', mode='wb', quiet = TRUE)
unzip('data/Dijkringen.zip', exdir = "data")
file.remove('data/Dijkringen.zip', 'data/wfsrequest.txt')

#Breach points
download.file(url = 'http://profgeodata.basisinformatie-overstromingen.nl/geoserver/VNK/ows?service=WFS&version=1.0.0&request=GetFeature&typeName=VNK:Doorbraaklocaties&outputFormat=SHAPE-ZIP' , destfile = 'data/Doorbraaklocaties.zip', method = 'internal', mode='wb', quiet = TRUE)
unzip('data/Doorbraaklocaties.zip', exdir = "data")
file.remove('data/Doorbraaklocaties.zip', 'data/wfsrequest.txt')
