#Mask Out Clouds
cloud2NA <- function(x, y){
  x[y != 0] <- NA
  return(x)
}

#Calculate NDVI
NDVI <- function(x, y) {
  ndvi <- (y - x) / (x + y)
  return(ndvi)
}

#Calculate differences between two ndvi images
assess_ndvi <- function(x,y){
  #new - old
  diff_ndvi <- (y-x)
  return (diff_ndvi)
}