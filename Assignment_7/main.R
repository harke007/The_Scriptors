## The Scriptors, Thijs van Loon & Jelle ten Harkel
## 17-01-2017

##Required Libraries
library(raster)
library(tmap)
library(RColorBrewer)
library(grid)

## notes change level to 1 for provinces and 2 for municipalities

## Downloading data
dir.create("data")
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

##Create colorramp

colorgrade <- brewer.pal(n=9, "YlGn")

# Create the highlited area's (TF = TRUEFALSE list if name_2 equals the greenest area)
TFMaxJanuary<-januaryNDVI_NL$NAME_2 == MaxJanuary
subsetMaxJanuary<-januaryNDVI_NL[TFMaxJanuary,]

TFMaxAugust<-augustNDVI_NL$NAME_2 == MaxAugust
subsetMaxAugust<-augustNDVI_NL[TFMaxAugust,]

TFMaxAverage<-averageNDVI_NL$NAME_2 == MaxAverage
subsetMaxAverage<-averageNDVI_NL[TFMaxAverage,]

##create the plots
plot1 <-
tm_shape(januaryNDVI_NL)+
  tm_fill(col="January", palette = colorgrade, style = "cont",title = "NDVI")+
  tm_borders()+
  tm_legend(frame=TRUE)+
  tm_credits(paste("The greenest area is", MaxJanuary),position = c("left", "bottom"),col="red")+
  tmap_mode(mode= "plot")+
    tm_shape(subsetMaxJanuary)+
      tm_borders(col="red")
save_tmap(tm = plot1, filename = "data/JanuaryNDVI.jpeg")

plot2 <-
tm_shape(augustNDVI_NL)+
  tm_fill(col="August", palette = colorgrade, style = "cont",title = "NDVI")+
  tm_borders()+
  tm_legend(frame=TRUE)+
  tm_credits(paste("The greenest area is", MaxAugust),position = c("left", "bottom"),col="red")+
  tmap_mode(mode= "plot")+
    tm_shape(subsetMaxAugust)+
      tm_borders(col="red")
save_tmap(tm = plot2, filename = "data/AugustNDVI.jpeg")

plot3 <- 
tm_shape(averageNDVI_NL)+
  tm_fill(col="layer", palette = colorgrade, style = "cont",title = "NDVI")+
  tm_borders()+
  tm_legend(frame=TRUE)+
  tm_credits(paste("The greenest area is", MaxAverage),position = c("left", "bottom"),col="red")+
  tmap_mode(mode= "plot")+
    tm_shape(subsetMaxAverage)+
      tm_borders(col="red")
save_tmap(tm = plot3, filename = "data/AverageNDVI.jpeg")

#plot maps next to each other
grid.newpage()
pushViewport(viewport(layout=grid.layout(1,3)))
print(plot1, vp=viewport(layout.pos.col = 1))
print(plot2, vp=viewport(layout.pos.col = 2))
print(plot3, vp=viewport(layout.pos.col = 3))
