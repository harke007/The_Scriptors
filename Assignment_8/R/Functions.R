rmse2 <- function(obs,pred) {
  sqrt(mean((obs-pred)^2 , na.rm = TRUE )) }