assess_ndvi <- function(x,y){
  #new - old
  diff_ndvi <- (y-x)
  return (diff_ndvi)
}