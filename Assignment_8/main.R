## The Scriptors, Thijs van Loon & Jelle ten Harkel
## 18-01-2017

##libraries needed
library(raster)
library(RColorBrewer)
source("R/Functions.R")

load("data/GewataB1.rda")
load("data/GewataB2.rda")
load("data/GewataB3.rda")
load("data/GewataB4.rda")
load("data/GewataB5.rda")
load("data/GewataB7.rda")
load("data/vcfGewata.rda")
load("data/trainingPoly.rda")
gewata <- brick(GewataB1, GewataB2, GewataB3, GewataB4, GewataB5, GewataB7)
gewata <- calc(gewata, fun=function(x) x / 10000)

vcfGewata[vcfGewata > 100] <- NA
vcfGewata[vcfGewata < 0] <- NA

covs <- addLayer(gewata, vcfGewata)
names(covs) <- c("band1","band2","band3","band4","band5","band7","VCF")
df <- as.data.frame(getValues(covs))

## Create the model
LMmodel <- lm(VCF ~ band1 + band2 + band3 + band4 + band5 + band7, data = df)
summary(LMmodel)$r.squared

## We eliminate band 7, because low significance
LMmodel <- lm(VCF ~ band1 + band2 + band3 + band4 + band5, data = df)

## Predict tree cover
par(mfrow = c(1,2))
predTC <- predict(covs,model=LMmodel, na.rm=TRUE)
predTC[predTC > 100] <- NA
predTC[predTC < 0] <- NA
plot(predTC)
plot(vcfGewata)

## calculate rmse
predTC_df <- as.data.frame(predTC)
vcfGewata_df <- as.data.frame(vcfGewata)
rmse <- rmse(vcfGewata_df,predTC_df)

## calculate rmse per landtype
trainingPoly@data$Code <- as.numeric(trainingPoly@data$Class)
classes <- rasterize(trainingPoly,covs, field='Code')
classes_df<-as.data.frame(classes)

covmasked <- mask(predTC, classes)
names(classes) <- "class"
trainingbrick <- addLayer(covmasked, classes)
valuetable <- getValues(trainingbrick)
valuetable <- na.omit(valuetable)
valuetable <- as.data.frame(valuetable)
valuetable$class <- factor(valuetable$class, levels = c(1:3))
val_crop <- subset(valuetable, class == 1)
val_forest <- subset(valuetable, class == 2)
val_wetland <- subset(valuetable, class == 3)

rmse_crop<- rmse2(vcfGewata_df,val_crop$layer)
rmse_forest<- rmse2(vcfGewata_df,val_forest$layer)
rmse_wetland<- rmse2(vcfGewata_df,val_wetland$layer)


