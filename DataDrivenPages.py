# This script prints PDFs for each interval the Kalamazoo River Project.
# Within the MXDs that use this script, a template is layed out under the file:
# P:\GP_Kzoo\Area_3\GIS\a_MXD\BankEvaluation\BRSA_2&3\BRSA2and3_SampleAndInterpolation_PythonTest.mxd
# Layers must be in the order as shown in the template.
# The layer "For Legend" should be on/visible, all other should be off/not visible.
# Questions or comments:
#   David C. Miller: david.c.miller@amecfw.com
#   Chris Williams: chris.williams@amecfw.com
#   Amy Stuyvesant: amy.stuyvesant@amecfw.com
import arcpy
import os
mxd = arcpy.mapping.MapDocument("current")
df = arcpy.mapping.ListDataFrames(mxd,"")[0]
Number_of_BRSAs = 1
j = Number_of_BRSAs - Number_of_BRSAs
while j < Number_of_BRSAs:
	# Items to be updated if need be
	BRSA_Number = ["2&3","4","5","6","7","8","9"] # BRSA number for file name
	BRSA_Title_Num = ["2 AND 3","4","5","6","7","8","9"]  # BRSA number for figure title
	
	Figure_Number_A = "2" # This changes the first figure number in the title block
	# Below changes the second figure number in the title block.
	Figure_Number_B = ["1", "2", "3", "4", "5", "6"]
	Number_of_Intervals = 6
	Interval_listy = ["1", "2", "3", "4", "5", "6"]
	Interval_Start_Depth = ["0","0.5","1","2","3","4"]
	Interval_End_Depth = ["0.5","1","2","3","4","5"]
	# NOTE: Ensure there is a folder that matches the flie path date before running.
	File_Path_Date = "161108"
	
	# Below is the string for the file directory where the PDFs will be saved.
	File_Directory = r"P:\\GP_Kzoo\\Area_3\\GIS\\Plotfiles\\TCRA\\BRSA_"+BRSA_Number[j]+r"\\"+File_Path_Date+r"\\"
    	# Below assigns python variables for the GIS BRSA Outline layers and zoom extents
	BRSA2_3 = arcpy.mapping.ListLayers(mxd, "BRSA 2 & 3 Outline", df)[0]
	BRSA4 = arcpy.mapping.ListLayers(mxd, "BRSA 4 Outline", df)[0]
	BRSA5 = arcpy.mapping.ListLayers(mxd, "BRSA 5 Outline", df)[0]
	BRSA6 = arcpy.mapping.ListLayers(mxd, "BRSA 6 Outline", df)[0]
	BRSA7 = arcpy.mapping.ListLayers(mxd, "BRSA 7 Outline", df)[0]
	BRSA8 = arcpy.mapping.ListLayers(mxd, "BRSA 8 Outline", df)[0]
	BRSA9 = arcpy.mapping.ListLayers(mxd, "BRSA 9 Outline", df)[0]
	BRSA2_3DD = arcpy.mapping.ListLayers(mxd, "BRSA 2 & 3 Data Driven", df)[0]
	BRSA4DD = arcpy.mapping.ListLayers(mxd, "BRSA 4 Data Driven", df)[0]
	BRSA5DD = arcpy.mapping.ListLayers(mxd, "BRSA 5 Data Driven", df)[0]
	BRSA6DD = arcpy.mapping.ListLayers(mxd, "BRSA 6 Data Driven", df)[0]
	BRSA7DD = arcpy.mapping.ListLayers(mxd, "BRSA 7 Data Driven", df)[0]
	BRSA8DD = arcpy.mapping.ListLayers(mxd, "BRSA 8 Data Driven", df)[0]
	BRSA9DD = arcpy.mapping.ListLayers(mxd, "BRSA 9 Data Driven", df)[0]
	
	if BRSA_Number[j] == "2&3":
    	extent = BRSA2_3DD.getExtent()
    	df.extent = extent
    	df.scale = 1000
    	df.rotation = 0
    	Bank_Side = "Left"
    	BRSA2_3.visible = True
    	BRSA4.visible = False
    	BRSA5.visible = False
    	BRSA6.visible = False
    	BRSA7.visible = False
    	BRSA8.visible = False
    	BRSA9.visible = False
	elif BRSA_Number[j] == "4":
    	extent = BRSA4DD.getExtent()
    	df.extent = extent
    	df.scale = 2000
    	df.rotation = 0
    	Bank_Side = "Right"
    	BRSA2_3.visible = False
    	BRSA4.visible = True
    	BRSA5.visible = False
    	BRSA6.visible = False
    	BRSA7.visible = False
    	BRSA8.visible = False
    	BRSA9.visible = False
	elif BRSA_Number[j] == "5":
    	extent = BRSA5DD.getExtent()
    	df.extent = extent
    	df.scale = 1500
    	df.rotation = 0
    	Bank_Side = "Right"
    	BRSA2_3.visible = False
    	BRSA4.visible = False
    	BRSA5.visible = True
    	BRSA6.visible = False
    	BRSA7.visible = False
    	BRSA8.visible = False
    	BRSA9.visible = False
	elif BRSA_Number[j] == "6":
    	extent = BRSA6DD.getExtent()
    	df.extent = extent
    	df.scale = 2500
    	df.rotation = 40
    	Bank_Side = "Right"
    	BRSA2_3.visible = False
    	BRSA4.visible = False
    	BRSA5.visible = False
    	BRSA6.visible = True
    	BRSA7.visible = False
    	BRSA8.visible = False
    	BRSA9.visible = False
	elif BRSA_Number[j] == "7":
    	extent = BRSA7DD.getExtent()
    	df.extent = extent
    	df.scale = 2000
    	df.rotation = 40
    	Bank_Side = "Right"
    	BRSA2_3.visible = False
    	BRSA4.visible = False
    	BRSA5.visible = False
    	BRSA6.visible = False
    	BRSA7.visible = True
    	BRSA8.visible = False
    	BRSA9.visible = False
	elif BRSA_Number[j] == "8":
    	extent = BRSA8DD.getExtent()
    	df.extent = extent
    	df.scale = 2500
    	df.rotation = 40
    	Bank_Side = "Left"
    	BRSA2_3.visible = False
    	BRSA4.visible = False
    	BRSA5.visible = False
    	BRSA6.visible = False
    	BRSA7.visible = False
    	BRSA8.visible = True
    	BRSA9.visible = False
	elif BRSA_Number[j] == "9":
    	extent = BRSA9DD.getExtent()
    	df.extent = extent
    	df.scale = 2000
    	df.rotation = 40
    	Bank_Side = "Left"
    	BRSA2_3.visible = False
    	BRSA4.visible = False
    	BRSA5.visible = False
    	BRSA6.visible = False
    	BRSA7.visible = False
    	BRSA8.visible = False
    	BRSA9.visible = True
	
	# Below assigns the layers in the MXD to a variable here in Python.
	Int1Samp = arcpy.mapping.ListLayers(mxd, "Interval 1 Samples "+Bank_Side, df)[0]
	Int1Interp = arcpy.mapping.ListLayers(mxd, "Interval 1 Interpolation "+Bank_Side, df)[0]
	Int2Samp = arcpy.mapping.ListLayers(mxd, "Interval 2 Samples "+Bank_Side, df)[0]
	Int2Interp = arcpy.mapping.ListLayers(mxd, "Interval 2 Interpolation "+Bank_Side, df)[0]
	Int3Samp = arcpy.mapping.ListLayers(mxd, "Interval 3 Samples "+Bank_Side, df)[0]
	Int3Interp = arcpy.mapping.ListLayers(mxd, "Interval 3 Interpolation "+Bank_Side, df)[0]
	Int4Samp = arcpy.mapping.ListLayers(mxd, "Interval 4 Samples "+Bank_Side, df)[0]
	Int4Interp = arcpy.mapping.ListLayers(mxd, "Interval 4 Interpolation "+Bank_Side, df)[0]
	Int5Samp = arcpy.mapping.ListLayers(mxd, "Interval 5 Samples "+Bank_Side, df)[0]
	Int5Interp = arcpy.mapping.ListLayers(mxd, "Interval 5 Interpolation "+Bank_Side, df)[0]
	Int6Samp = arcpy.mapping.ListLayers(mxd, "Interval 6 Samples "+Bank_Side, df)[0]
	Int6Interp = arcpy.mapping.ListLayers(mxd, "Interval 6 Interpolation "+Bank_Side, df)[0]
	
	# Putting the above layers in a list.
	Interval_Samples = [Int1Samp, Int2Samp, Int3Samp, Int4Samp, Int5Samp, Int6Samp]
	Interval_Interpolation = [Int1Interp, Int2Interp, Int3Interp, Int4Interp, Int5Interp, Int6Interp]
	
	#NOTE: You need to right-click on a text box in the MXD, go to properties, and name that text box something like "Fig_Name" so it can be changed by the script!
	
	fig_obj = arcpy.mapping.ListLayoutElements(mxd, "TEXT_ELEMENT", "Figure_Title")[0]
	fig_obj2 = arcpy.mapping.ListLayoutElements(mxd, "TEXT_ELEMENT", "Figure_Number")[0]
	
    	
	
	i = Number_of_Intervals - Number_of_Intervals
	while i < Number_of_Intervals:
    	Interval_Samples[i].visible = True
    	Interval_Interpolation[i].visible = True
    	fig_obj.text = u'TOTAL PCB CONCENTRATIONS IN BRSA ' + BRSA_Title_Num[j] + u' \r INTERVAL '+Interval_listy[i]+u' ('+Interval_Start_Depth[i]+u' - '+Interval_End_Depth[i]+u' FT)'
    	fig_obj2.text = Figure_Number_A + u'-' + Figure_Number_B[i]
    	arcpy.RefreshTOC()
    	arcpy.RefreshActiveView()
    	arcpy.mapping.ExportToPDF(mxd,File_Directory+r"BRSA"+BRSA_Number[j]+r"_SampleAndInterpolation_Int"+Interval_listy[i]+r"_"+File_Path_Date+r".pdf")
    	Interval_Samples[i].visible = False
    	Interval_Interpolation[i].visible = False
    	arcpy.RefreshTOC()
    	arcpy.RefreshActiveView()
    	i = i + 1
	
	
	if os.path.exists(File_Directory+r"BRSA"+BRSA_Number[j]+r"_SampleAndInterpolation_"+File_Path_Date+r".pdf"):
    	os.remove(File_Directory+r"BRSA"+BRSA_Number[j]+r"_SampleAndInterpolation_"+File_Path_Date+r".pdf")
	
	
	PDFdoc = arcpy.mapping.PDFDocumentCreate(File_Directory+r"BRSA"+BRSA_Number[j]+r"_SampleAndInterpolation_"+File_Path_Date+r".pdf")
	PDFdoc.appendPages(File_Directory+r"BRSA"+BRSA_Number[j]+r"_SampleAndInterpolation_Int"+Interval_listy[0]+r"_"+File_Path_Date+r".pdf")
	PDFdoc.appendPages(File_Directory+r"BRSA"+BRSA_Number[j]+r"_SampleAndInterpolation_Int"+Interval_listy[1]+r"_"+File_Path_Date+r".pdf")
	PDFdoc.appendPages(File_Directory+r"BRSA"+BRSA_Number[j]+r"_SampleAndInterpolation_Int"+Interval_listy[2]+r"_"+File_Path_Date+r".pdf")
	PDFdoc.appendPages(File_Directory+r"BRSA"+BRSA_Number[j]+r"_SampleAndInterpolation_Int"+Interval_listy[3]+r"_"+File_Path_Date+r".pdf")
	PDFdoc.appendPages(File_Directory+r"BRSA"+BRSA_Number[j]+r"_SampleAndInterpolation_Int"+Interval_listy[4]+r"_"+File_Path_Date+r".pdf")
	PDFdoc.appendPages(File_Directory+r"BRSA"+BRSA_Number[j]+r"_SampleAndInterpolation_Int"+Interval_listy[5]+r"_"+File_Path_Date+r".pdf")
	PDFdoc.saveAndClose()
  	
	j = j + 1 
