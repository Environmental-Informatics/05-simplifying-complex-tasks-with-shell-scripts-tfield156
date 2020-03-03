#!/bin/bash

# Tyler Field
# 3/3/2020
# ABE 65100
# Lab 05

# PART 1
# If the subdirectory HigherElevation does not already exist, create it
if [ ! -d ./HigherElevation ]
then
  #Create the HigherElevation directory
  mkdir HigherElevation
fi

# For each file in the StationData folder, copy those with an altitude of at least 200ft to the HigherElevation folder
for file in StationData/*
do #integer part of number from the 4th column of the 5th line of the file (whole number of altitude (ft))
  altitude=$( head -5 $file | tail -1 | cut -d " " -f 4 | cut -d "." -f 1 )
  if [ $altitude -gt 200 ] || [ $altitude -eq 200 ] #at least 200 ft
  then
    cp $file ./HigherElevation #copy the file into the HigherElevation folder
  fi
done

# PART 2
# Copy longitude and latitude data from all stations into a single file
awk '/Longitude/ {print -1 * $NF}' StationData/Station_*.txt > Long.list
awk '/Latitude/ {print $NF}' StationData/Station_*.txt >Lat.list
paste Long.list Lat.list > AllStation.xy

# Copy longitude and latitude data from the high elevation stations into a single file
awk '/Longitude/ {print -1 * $NF}' HigherElevation/Station_*.txt > HELong.list
awk '/Latitude/ {print $NF}' HigherElevation/Station_*.txt > HELat.list
paste HELong.list HELat.list > HEStation.xy

#Load the gmt module to create the graphics
module load gmt

#Plots land and water masses
gmt pscoast -JU16/4i -R-93/-86/36/43 -B2f0.5 -Df+ -Ia/blue -Cl/blue -Na/orange -P -K -V > SoilMoistureStations.ps
#Add the points of all stations in black
gmt psxy AllStation.xy -J -R -Sc0.15 -Gblack -K -O -V >> SoilMoistureStations.ps
#Overlay a small red dot on the station's black dot if it is a high elevation station
gmt psxy HEStation.xy -J -R -Sc0.05 -Gred -O -V >> SoilMoistureStations.ps

#Creates EPSI vector image
ps2epsi SoilMoistureStations.ps

#Creates TIFF image at 150 dpi
convert SoilMoistureStations.epsi -density 150 SoilMoistureStations.tiff
