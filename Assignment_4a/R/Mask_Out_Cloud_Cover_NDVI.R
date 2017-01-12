cloud2NA <- function(x, y){
  x[y != 0] <- NA
  return(x)
}