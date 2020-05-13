# Created on: 2017-01-18
#      	by: Amy Stuyvesant
# The objective of this script is to update a shapefile when you get
# new data. For example, if you have an excel file that houses your PFC well
# locations and analytical results, when new rows or columns are added to the
# excel file used to cerate the shapefile, this script will update the shapefile.
# ---------------------------------------------------------------------------

import arcpy
#allow existing shapefile to be overwritten
arcpy.env.overwriteOutput = True

###Local variables:
#Where the excel table is located
excel = "C:\\Users\\amy.stuyvesant\\Desktop\\Python Test\\moretest\\Geology File_WithElevations.xls\\'Only FALSE$'"

#Name the event layer created from X,Y
event = "event layerzzzz"

#Location where the shapefile will be stored
shapefile = "C:\\Users\\amy.stuyvesant\\Desktop\\Python Test\\shapefile_test.shp"

# Make XY Event Layer and set projection
arcpy.MakeXYEventLayer_management(excel, "x", "y", event, "PROJCS['NAD_1983_StatePlane_Michigan_Central_FIPS_2112_Feet',GEOGCS['GCS_North_American_1983',DATUM['D_North_American_1983',SPHEROID['GRS_1980',6378137.0,298.257222101]],PRIMEM['Greenwich',0.0],UNIT['Degree',0.0174532925199433]],PROJECTION['Lambert_Conformal_Conic'],PARAMETER['False_Easting',19685000.0],PARAMETER['False_Northing',0.0],PARAMETER['Central_Meridian',-84.36666666666666],PARAMETER['Standard_Parallel_1',44.18333333333333],PARAMETER['Standard_Parallel_2',45.7],PARAMETER['Latitude_Of_Origin',43.31666666666667],UNIT['Foot_US',0.3048006096012192]];-99918700 -98010500 3048.00609601219;-100000 10000;-100000 10000;3.28083333333333E-03;0.001;0.001;IsHighPrecision", "Elevation_m")

# Export event as shapefile
arcpy.CopyFeatures_management(event, shapefile, "", "0", "0", "0")
print "Successfully created shapefile!"
mxd = arcpy.mapping.MapDocument("CURRENT")
arcpy.RefreshActiveView()
arcpy.RefreshTOC()
del mxd, df

print "New shapefile has been added"
