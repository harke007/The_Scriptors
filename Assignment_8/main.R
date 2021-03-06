## title: "Assigment 8 The Scriptors"
## author: "Jelle ten Harkel & Thijs van Loon"
## date: "19 januari 2017"

#### The needed libraries
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

## Analysis of the scatterplots
par(mfrow=c(2,3))

plot(GewataB1,vcfGewata, col="blue")
plot(GewataB2,vcfGewata, col="green")
plot(GewataB3,vcfGewata, col="red")
plot(GewataB4,vcfGewata, col="purple")
plot(GewataB5,vcfGewata, col="orange")
plot(GewataB7,vcfGewata, col="grey")

#Create the model
LMmodel <- lm(VCF ~ band1 + band2 + band3 + band4 + band5 + band7, data = df)
summary(LMmodel)
## We eliminate band 7, because low significance
LMmodel <- lm(VCF ~ band1 + band2 + band3 + band4 + band5, data = df)

## Predict tree cover
par(mfrow = c(1,2), oma=c(0,0,0,1))
predTC <- predict(covs,model=LMmodel, na.rm=TRUE)
predTC[predTC > 100] <- NA
predTC[predTC < 0] <- NA
plot(predTC, main="The predicted VCF",legend=FALSE)
plot(vcfGewata, main="The original VCF")

##Plot scatter
par(mfrow = c(1,1))
plot(vcfGewata,predTC,col="darkgreen",xlab="Original VCF [%]", ylab="Predicted VCF [%]")

##m Calculate rmse
predTC_df <- as.data.frame(predTC)
vcfGewata_df <- as.data.frame(vcfGewata)
rmse <- rmse2(vcfGewata_df,predTC_df)

## calculate rmse per landtype
trainingPoly@data$Code <- as.numeric(trainingPoly@data$Class)
classes <- rasterize(trainingPoly,covs, field='Code')

rmse_PP <- rmse2(vcfGewata,predTC)
rmse_PC <- zonal(rmse_PP,classes,fun="mean")

## drop unnecessary column
rmse_PC <- rmse_PC[,2]

## make it a matrix again
rmse_PC <- matrix(unlist(rmse_PC), ncol = 1, byrow = TRUE)
rmse_PC <- rbind(rmse_PC,rmse)

## change column names
rownames(rmse_PC) <-c("cropland", "forest", "wetland","overall")
colnames(rmse_PC) <- ("RMSE")