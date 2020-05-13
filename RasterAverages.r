####################################################################
#Script for computing raster averages given polygons from shapefile
#Census block averages of Ratser for Maricopa County
#Amy Stuyvesant
#6/22/2015
####################################################################

#Steps: 
# 1) read shapefile into a spatial polygons data frame (readOGR from rgdal)
# 2) read raster into a raster object (raster function from package raster)
# 3) use extract(raster, spdf) to get grid cells under each polygon
# 4) run mean on them
# repeat for all images

#add libraries
require(raster)
require(sp)
require(rgdal)

#set working directory, raster. in and out shapefiles
TempDIR <- "C:/Users/astuyves/Desktop/MODIS_data/Clipped" #make sure you use forward slashes for R
setwd(TempDIR) #sets the working directory in a variable

#open shapefile
Census <- readOGR(dsn = TempDIR, layer="Census") 

#load raster data into a list
rasterlist <- list.files(path = TempDIR, pattern = ".tif$") 

TempDF <- data.frame() #empty data frame to fill in loop with Temperature values

for(raster in 1:length(rasterlist)){ #loop that iterates through the length of the rasterlist
  Image <- raster(rasterlist[raster]) #makes raster layer
  ext <- extract(Image, Census) #extracts values based on shapefile and calulcates mean
  TempMean <- lapply(ext, method = bilinear, FUN=mean) #takes extracted values and performs Mean function
  TempDF <- cbind(Census@data$GISJOIN, TempMean)#data frame to hold extact values
  colnames(TempDF) <- c("Type", "MeanTemp")#rename column names of dataframe
  filename <- rasterlist[raster] #set up filename so that the write.csv doesnt overwrite each iteration
  write.csv(TempDF, paste(filename,".csv"), row.names=FALSE) #write csv
}