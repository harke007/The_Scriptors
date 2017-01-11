# Name: The Scripters, Thijs van Loon & Jelle ten Harkel
# Date: 9 January 2017

# Import packages
library(raster)

# Define the function
map <- function(lvl, cty) {
  datdir <- 'data'
  dir.create(datdir, showWarnings = FALSE)
  adm <- raster::getData("GADM", country = cty,
                         level = lvl, path = datdir)
  plot(adm, bg = "#afaf83", axes=T)
  plot(adm, lwd = 5, border = "#ff0000", add=T)
  plot(adm, col = "#009933", add = T)
  grid()
  box()
  
# Create a title for the plot based on the country entered in the function
  title <- paste("Map of", adm$NAME_0)
# Create a variable to be used for the labels, based on the level the used entered
  lvl2 = toString(lvl)
  lbl=paste0("adm$NAME_",lvl2)
  lbl=parse(text=lbl)
  invisible(text(getSpPPolygonsLabptSlots(adm),
                 labels = eval(lbl), cex = 1.1, col = "#ffffff", font = 2))
  
# Create axis names, and add the general information about the map
  mtext(side = 3, line = 1, title, cex = 2)
  mtext(side = 1, "Longitude", line = 2.5, cex=1.1)
  mtext(side = 2, "Latitude", line = 2.5, cex=1.1)
  mtext(side = 1,  "Projection: Geographic\n
Coordinate System: WGS 1984\n
Data Source: GADM.org",line =-3, adj=0.05,  cex = 0.9, col = "#ff0000")
  }

# An example based on that function
map(1,"Poland")


