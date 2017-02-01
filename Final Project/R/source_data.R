## The Scriptors, Thijs van Loon, Jelle ten Harkel
## Final project
## Date 02-02-2017

## Download map data
# Dike rings
download.file(url = 'http://profgeodata.basisinformatie-overstromingen.nl/geoserver/LBEO/ows?service=WFS&version=1.0.0&request=GetFeature&typeName=LBEO:dijkringen&outputFormat=SHAPE-ZIP', destfile = 'data/Dijkringen.zip', method = 'internal', mode='wb', quiet = TRUE)
unzip('data/Dijkringen.zip', exdir = "data")
file.remove('data/Dijkringen.zip', 'data/wfsrequest.txt')

# Breach points
download.file(url = 'http://profgeodata.basisinformatie-overstromingen.nl/geoserver/VNK/ows?service=WFS&version=1.0.0&request=GetFeature&typeName=VNK:Doorbraaklocaties&outputFormat=SHAPE-ZIP' , destfile = 'data/Doorbraaklocaties.zip', method = 'internal', mode='wb', quiet = TRUE)
unzip('data/Doorbraaklocaties.zip', exdir = "data")
file.remove('data/Doorbraaklocaties.zip', 'data/wfsrequest.txt')

# Hospitals
download.file(url = 'http://inspire.rivm.nl/geoserver/wfs?request=GetFeature&service=WFS&version=1.1.0&typeName=inspire:hospitals_2013&outputFormat=SHAPE-ZIP' , destfile = 'data/Ziekenhuizen.zip', method = 'internal', mode='wb', quiet = TRUE)
unzip('data/Ziekenhuizen.zip', exdir = "data")
file.remove('data/Ziekenhuizen.zip', 'data/wfsrequest.txt')