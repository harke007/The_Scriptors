## The Scriptors Thijs van Loon & Jelle ten Harkel
## 12-01-1995

## Note: Landsat 8 does not use the same band numbers as its predecessors. 
## Red and NIR correspond to band3 and band4 respectively for ETM+ and TM (Landsat 7 and 5 respectively), 
## while for OLI (Landsat 8), Red is band4 and NIR is band5.

##input r scripts
library(raster)
source('R/Functions_lesson_5.R')

## Pre-Processing steps
## Download Data
download.file(url="https://www.dropbox.com/s/akb9oyye3ee92h3/LT51980241990098-SC20150107121947.tar.gz?dl=1", destfile='Data/Landsat5.tar.gz', method='auto', mode= 'wb')
download.file(url="https://www.dropbox.com/s/i1ylsft80ox6a32/LC81970242014109-SC20141230042441.tar.gz?dl=1", destfile ='Data/Landsat8.tar.gz', method='auto', mode = 'wb')

## unpacking data
Landsat5 <- untar("Data/Landsat5.tar.gz", exdir = 'Data/Landsat5')
list_landsat5 <- list.files(pattern = '^.*\\.tif$', path = 'Data/Landsat5', full.names=TRUE)
landsat5_bands <- stack(list_landsat5)

Landsat8 <- untar("Data/Landsat8.tar.gz", exdir = 'Data/Landsat8')
list_landsat8 <- list.files(pattern = '^.*\\.tif$', path='Data/Landsat8', full.names=TRUE)
landsat8_bands <- stack(list_landsat8)

##intersect two ares so one 
landsat5_clipped=intersect(landsat5_bands,landsat8_bands)
landsat8_clipped=intersect(landsat8_bands,landsat5_bands)

## Mask out clouds
fmask5=landsat5_clipped[[1]]
landsat5_cloudfree <- overlay(x = landsat5_clipped, y = fmask5, fun = cloud2NA)
names(landsat5_cloudfree)<- names(landsat5_bands)

fmask8=landsat8_clipped[[1]]
landsat8_cloudfree <- overlay(x = landsat8_clipped, y = fmask8, fun = cloud2NA)
names(landsat8_cloudfree)<- names(landsat8_bands)

## Calculate NDVI
ndvi_landsat5 <- overlay(x=landsat5_cloudfree[["LT51980241990098KIS00_sr_band3"]], y=landsat5_cloudfree[["LT51980241990098KIS00_sr_band4"]], fun=NDVI)
ndvi_landsat8 <- overlay(x=landsat8_cloudfree[["LC81970242014109LGN00_sr_band4"]], y=landsat8_cloudfree[["LC81970242014109LGN00_sr_band5"]], fun=NDVI)


## NDVI inside 0,1 (Tried inside the NDVI function but gave a very weird error)

## Error in (function (x, fun, filename = "", recycle = TRUE, forcefun = FALSE,  : 
## cannot use this formula, probably because it is not vectorized
                    
values(ndvi_landsat5)[values(ndvi_landsat5) <0] <- 0
values(ndvi_landsat5)[values(ndvi_landsat5) >1] <- 1
values(ndvi_landsat8)[values(ndvi_landsat8) <0] <- 0
values(ndvi_landsat8)[values(ndvi_landsat8) >1] <- 1

##Assessing the difference between NDVI
ndvi_difference <- overlay(x=ndvi_landsat5, y=ndvi_landsat8, fun=assess_ndvi)

## plot all the data
plot(landsat5_cloudfree)
plot(landsat8_cloudfree)
plot(ndvi_landsat5)
plot(ndvi_landsat8)
plot(ndvi_difference)