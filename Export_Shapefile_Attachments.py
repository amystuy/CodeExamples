##This script exports attachments from a feature class
##Written by: Amy Stuyvesant

import arcpy, os
from collections import defaultdict
inFC = arcpy.GetParameterAsText(0) # Feature Class
inTable = arcpy.GetParameterAsText(0) # Attachment table
fileLocation = arcpy.GetParameterAsText(0) # Output location

# Get dictionary of ObjectID and associated field value
myFeatures = dict()
with arcpy.da.SearchCursor(inFC, ['OID@', 'TextField']) as cursor:
	for row in cursor:
    	myFeatures[row[0]] = row[1]

# Create dictionary to count usage of the field value (to increment files)
valueUsage = defaultdict(int)

# Loop through attachments, incrementing field value usage, and using that

# increment value in the filename
with arcpy.da.SearchCursor(inTable, ['DATA', 'ATT_NAME', 'ATTACHMENTID', 'REL_OBJECTID']) as cursor:
	for row in cursor:
    	if row[3] in myFeatures:
        	attachment = row[0]
        	fieldValue = myFeatures[row[3]] # Value of specified field in feature class
        	valueUsage[fieldValue] += 1 # Increment value
        	filename = "{0}_{1}".format(fieldValue, valueUsage[fieldValue]) # filename = FieldValue_1
        	output = os.path.join(fileLocation, filename) # Create output filepath
        	open(output, 'wb').write(attachment.tobytes()) # Output attachment to file