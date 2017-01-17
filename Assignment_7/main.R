## The Scriptors, Thijs van Loon & Jelle ten Harkel
## 17-01-2017

##Required Libraries
library(raster)
library(tmap)
library(RColorBrewer)

## notes change level to 1 for provinces and 2 for municipalities

## Downloading data
download.file(url="https://raw.githubusercontent.com/GeoScripting-WUR/VectorRaster/gh-pages/data/MODIS.zip", destfile = 'data/modis.zip', method = 'auto', mode = 'wb')
unzip('data/modis.zip', exdir='data')
nlMunicipality <- getData('GADM',country='NLD', level=2, path = 'data/') ##change here 1 for province 2 for municipality

##Selecting the right file and creating a RasterBrick
modis <- list.files(path= 'data', pattern = '*.grd' , full.names = TRUE)
modis_data <- brick(modis)

## reproject
nlMunicipalityReprojected <- spTransform(nlMunicipality, CRS(proj4string(modis_data)))

## Selecting required months (0.001 is the modis scalingfactor to get NDVI in the range 0..1)
januaryNDVI_NL = extract(modis_data[[1]]*0.0001, nlMunicipalityReprojected,fun=mean,na.rm=TRUE,sp=TRUE)
augustNDVI_NL = extract(modis_data[[8]]*0.0001,nlMunicipalityReprojected,fun=mean,na.rm=TRUE,sp=TRUE)
averageNDVI_NL = extract(mean(modis_data, na.rm=TRUE)*0.0001,nlMunicipalityReprojected,fun=mean,na.rm=TRUE,sp=TRUE)

## Select the max and change here 1 for province 2 for municipality
MaxJanuary <- januaryNDVI_NL$NAME_2[[which.max(januaryNDVI_NL$January)]]
MaxAugust <- augustNDVI_NL$NAME_2[[which.max(augustNDVI_NL$August)]]
MaxAverage <- averageNDVI_NL$NAME_2[[which.max(averageNDVI_NL$layer)]]

#Plot a map and save it to the data folder
colorgrade <- brewer.pal(n=9, "YlGn")
par(mfrow=c(1,3))
tm_shape(januaryNDVI_NL)+
  tm_fill(col="January", palette = colorgrade, style = "cont",title = "NDVI of January ")+
  tm_borders()+
  tm_legend(position = c("left", "bottom"), frame=TRUE, scale=0.9)+
  tm_credits(paste("The greenest area is", MaxJanuary),position = c("left", "top"), size = 1.1)+
  tmap_mode(mode= "plot")
save_tmap(filename = "data/JanuaryNDVI.jpeg")

tm_shape(augustNDVI_NL)+
  tm_fill(col="August", palette = colorgrade, style = "cont",title = "NDVI of August ")+
  tm_borders()+
  tm_legend(position = c("left", "bottom"), frame=TRUE)+
  tm_credits(paste("The greenest area is", MaxAugust),position = c("left", "top"), size = 1)+
  tmap_mode(mode= "plot")
save_tmap(filename = "data/AugustNDVI.jpeg")

tm_shape(averageNDVI_NL)+
  tm_fill(col="layer", palette = colorgrade, style = "cont",title = "The average NDVI ")+
  tm_borders()+
  tm_legend(position = c("left", "bottom"), frame=TRUE)+
  tm_credits(paste("The greenest area is", MaxAverage),position = c("left", "top"), size = 1)+
  tmap_mode(mode= "plot")
save_tmap(filename = "data/AverageNDVI.jpeg")
