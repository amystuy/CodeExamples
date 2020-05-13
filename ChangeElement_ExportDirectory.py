#This script takes all MXDs in a specific filepath, opens them,
#changes a set element, and saves them as a PDF in the same folder.
#Created by: Amy Stuyvesant, Jan 17, 2017

import arcpy, os
##Define folder with MXDs and where to save PDFs
folderPath = r"G:\ANG\a_MXD\Peoria_291330006.016"

##Loop through, open, and export each MXD
for filename in os.listdir(folderPath): 
	fullpath = os.path.join(folderPath, filename) 
	if os.path.isfile(fullpath): 
    	basename, extension = os.path.splitext(fullpath) 
    	if extension.lower() == ".mxd": 
        	mxd = arcpy.mapping.MapDocument(fullpath)
        	for elm in arcpy.mapping.ListLayoutElements(mxd, "TEXT_ELEMENT"):
            	if elm.name == "GraphicText8":
                	elm.text = elm.text.replace("December 2015", "February 2016")
                	mxd.save()
                	arcpy.mapping.ExportToPDF(mxd, basename + '_170414.pdf')