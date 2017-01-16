## The Scriptors, Thijs van Loon & Jelle ten Harkel
## 16-01-2017

## Required libraries
library(rgdal)
library(rgeos)

## Import Data
download.file(url = 'http://www.mapcruzin.com/download-shapefile/netherlands-railways-shape.zip', destfile = 'data/railways.zip', method = 'auto')
download.file(url = 'http://www.mapcruzin.com/download-shapefile/netherlands-places-shape.zip', destfile = 'data/places.zip', method = 'auto')
rws <- unzip('data/railways.zip', exdir = 'data/railways')
pls <- unzip('data/places.zip', exdir = 'data/places')

## read the shapefile inside the the folders
rws_shp <- readOGR("data/railways", "railways")
rws_indust <- rws_shp[rws_shp$type == "industrial",]
pls_shp <- readOGR("data/places", "places")

## transform projection to RD_new, so meters can be used.
prj_string_RD <- CRS("+proj=sterea +lat_0=52.15616055555555 +lon_0=5.38763888888889 +k=0.9999079 +x_0=155000 +y_0=463000 +ellps=bessel +towgs84=565.2369,50.0087,465.658,-0.406857330322398,0.350732676542563,-1.8703473836068,4.0812 +units=m +no_defs")
railways_industrial_transformed <- spTransform(rws_indust, prj_string_RD)
places <- spTransform(pls_shp, prj_string_RD)

## Buffer with 1000m
railways_industrial_buffered <- gBuffer(railways_industrial_transformed[1,], width=1000, quadsegs=8)

## Intersect, byid to get a list of true and false(inside or outside the buffer)
Location_city <- gIntersects(railways_industrial_buffered,places, byid = TRUE)

## Subset to select the city which is inside the buffer and also keep the data
City = subset(places, Location_city[,'buffer'])

## Create the Map
plot(railways_industrial_buffered, bg='#24bd40', axis=TRUE)
plot(railways_industrial_transformed, col='#604924', lwd=8.0, add = TRUE)
plot(City, add=TRUE, col='red', cex=1, pch=16)
box()
text(x=railways_industrial_transformed@bbox[1,2], y=railways_industrial_transformed@bbox[2,2], pos=4, labels = paste("Railway of type: ", railways_industrial_transformed$type), cex=1.2)
text(x= City@coords[,1], y=City@coords[,2], pos=4, labels = City$name, cex=1.2, offset = 1.2)
title(paste("The city of", City$name))
mtext(side=1, paste("The population is:", City$population), adj = 0.05, cex=1.4, line = -1.1)




