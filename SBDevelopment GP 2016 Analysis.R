#####################################################################
#The following code was created for a Group Project (SBDevelopment) at the Bren School of Environmental Science and Management. 
#
#Project Title: More Housing Fewer Cars: Reducing Commute Related Emissions on the South Coast.
#
#Group Members: Jenny Bankie, Kaitlin Carney, Michelle Graff, Amy Stuyvesant
#
#Code by: Amy Stuyvesant
#         *Point of contact for any code questions. 
#         Email: astuyvesant@bren.ucsb.edu
#
#Project website: http://sbdevelopment.wix.com/sbdevelopment
#
#Table of Contents (by code line number)
#    37 - 94   Organize Raw Responses from Qualtrics
#    97 - 142  Research Question 1 Analysis
#   145 - 381  Prepare Data for Reseach Question 2 Analysis
#   385 - 441  Research Quetsion 2 Analysis
#   444 - 508  Regressions to Test Quality of Research Question 1
#   511 - 528  Research Question 2: Data Check on Commute Distance
#   531 - 553  Research Question 2: Data Check on Housing Type/Mode Choice Association
#   556 - 624  Research Question 2: Data Check on Moving Closer to Work and Mode Choice
#   627 - 654  Research Question 2: Data Check on Zip Code and Mode Choice
#   657 - 812  Research Question 3 Preparation and Analysis
#   815 - 833  Data Check: MDE
#   836 - 845  Data Check: Histograms
#
#August 8, 2016
#####################################################################

#Download these packages for use throughout the code:
#mice, lattice, pgirmess, ggplot, ggplot2, flexmix, reshape2, cjoint, MASS, nnet, alr3, clusterSEs


#####################################################################

#This first chunk of code just organizes the data we downloaded directly from Qualtrics, our survey platform. It will go through deleting unnecessary columns, renaming columns, pulling data from a different data set based on a survey response, and saving the new file as a .csv

#######################################################################

# Organize the data
#When downloading from Qualtrics check: Shown Values as (Choice Text), Decimal Format (period), Question Number(No)
setwd('D:/GPStuff/SurveyAnalysis') #update your filepath, navigate to the folder you keep your files in

Responses <- read.csv('RawData_01302016.csv', header = TRUE, stringsAsFactors = F) #string as factors = F just for data organization, for regression need to change this back to T

#delete and rename columns, should always stay the same
Responses <- Responses[-c(1:12, 24:24, 48:48, 59:59, 74:74, 76:79)] 
colnames(Responses) <- c("Code", "PresWorkZip", "CommuteDays", "PresCommuteDist", "PresCalcApprox", "PresPrimMethod", "PresPrimMethod_Other", "PresMake", "PresModel", "PresYear", "PresCarpoolNum",  "PresBusRoute", "HBD_DK", "HouseBusDist", "WBD_DK", "WorkBusDist", "Predictability", "TransferDK", "Transfers", "RedBusPass", "Cleanliness", "Shower", "Storage", "Abilities", "BikePaths", "LiveNear", "PreferredSpace", "RecProgramBike", "RecProgramCarpool", "RecProgramBus", "RecProgramNo", "RecProgramDK", "Errands", "Guranteed", "PrevResZip", "PrevWorkZip", "PrevCommuteDist", "PrevCalcApprox", "PrevPrimaryMethod", "PrevPrimMethod_Other", "PrevMake", "PrevModel", "PrevYear", "PrevCarpoolNum", "PrevBusRoute", "CarBike1", "CarBike2", "CarBike3", "CarBus1", "CarBus2", "CarBus3", "CarCarpool1", "CarCarpool2", "CarCarpool3", "Gender", "Age", "Income", "Comment", "Email")

#delete rows on non responses, needs to be updated with each new file
Responses <- Responses[-c(1, 37, 77, 78, 79, 80, 81, 85, 86, 88, 92, 97, 98, 102, 103, 104, 108, 123, 130, 135, 136, 140, 141, 144, 145), ]

# --- Pull in data from another .csv file (tax parcel data) --- 
# This next chunk takes a survey response, looks through tax parcel data, and pulls over data into the Responses.csv

#read in csv file used to get sample population (county tax parcel data)
SamplePop <- read.csv('FinalSamplePop.csv') #data with our sample pop and associated codes and housing type

#extract zip codes in SamplePop File
SamplePop$Zip <- c(1:nrow(SamplePop)) #create new column for zip codes
for(i in 1:nrow(SamplePop)){
  SamplePop[i,7] <- gsub("^.*CA ","", SamplePop[i,5])
  SamplePop[i,7] <- gsub(" .*", "", SamplePop[i,7])
}

#extract city in SamplePop File
SamplePop$City <- c(1:nrow(SamplePop))
SamplePop$City.Address <- as.character(SamplePop$City.Address)
for(i in 1:nrow(SamplePop)){
  SamplePop[i,8] <- strsplit(SamplePop[i,5], ", CA")
}

#Pull housing type from Sample Pop file into Responses File
Responses$HousingType <- c(1:nrow(Responses)) #create new column for housing type
Responses$PresResZip <- c(1:nrow(Responses)) #create new column for zip code
toupper(Responses$Code) #make the codes all upper case to eliminate different formats users used to input code
Responses$ParcelID <- c(1:nrow(Responses)) #create new column for Parcel ID
Responses$City <- c(1:nrow(Responses)) #create new column for City

for(i in 1:nrow(Responses)){ #outer loop to go through code rows
  for(j in 1:nrow(SamplePop)){ #inner loop to check codes in other file
    if(toupper(Responses[i,1]) == SamplePop[j,1]){ #check if codes are equal
      Responses[i,60] <- toString(SamplePop[j,6])
      Responses[i,61] <- SamplePop[j,7]
      Responses[i,62] <- toString(SamplePop[j,3])
      Responses[i,63] <- toString(SamplePop[j,8])
    }#bring in housing type, zip, and Parcel ID if codes are equal into columns created above
  }
}

#Everything will have the above columns, exported below. The rest of the code works off of this csv and creates subsets with new columns, but they are independant and not needed in all analyses

write.csv(Responses, file = 'Responses.csv')

#################################################################
#The rest of the code will go through our research questions as well as some checks on data quality
################################################################

###############################################################
#--------------------------------------Research Question 1----------------------------------------------
###############################################################

# How do mileage and GHG emissions vary for 1) South Coast residents in Apts vs Single Family Homes and 2) between residents within AUD and within a one-mile buffer around AUD

#Subset responses by apartment or single family home/mobile home and comapre mileage for these groups; we eliminated responses that did not commute or did not give clear answers

Apartments <- subset(Responses, Responses$HousingType == "APARTMENTS, 5 OR MORE UNITS") 
SingleHome <- subset(Responses, Responses$HousingType == "SINGLE FAMILY RESIDENCE" | Responses$HousingType == "MOBILE HOMES")
Apartments <- subset(Apartments)
SingleHome <- subset(SingleHome, SingleHome$PresPrimMethod_Other != "Transporter" & SingleHome$PresPrimMethod_Other != "N/A" & SingleHome$PresPrimMethod_Other != "telecommute" & SingleHome$PresPrimMethod_Other != "Don\'t work") 

Apartments$PresCommuteDist <- as.numeric(Apartments$PresCommuteDist) #just changing data type 
Apartments$PrevCommuteDist <- as.numeric(Apartments$PrevCommuteDist)
SingleHome$PresCommuteDist <- as.numeric(SingleHome$PresCommuteDist)
SingleHome$PrevCommuteDist <- as.numeric(SingleHome$PrevCommuteDist)

Apartments <- Apartments[-c(1:4, 6:37, 39:92)] #deleting unnecessary columns for cleaner data analysis and file storage
SingleHome <- SingleHome[-c(1:4, 6:37, 39:92)]

write.csv(Apartments, 'Apartments.csv') #saving these files 
write.csv(SingleHome, 'SingleHome.csv')

HousingTest <- wilcox.test(Apartments$PresCommuteDist, SingleHome$PresCommuteDist, na.rm = TRUE, alternative = "less")
#W = 1501, p-value = 0.2497

#subset for in AUD not in AUD
InAUD <- read.csv("WinterQuarter/BufferAnalysis/InAUD.csv", header = TRUE)
InAUD <- InAUD[-c(1)]
InBuffer <- read.csv("WinterQuarter/BufferAnalysis/InBuffer.csv", header = TRUE)
InBuffer <- InBuffer[-c(1)]
InBuffer <- subset(InBuffer, InBuffer$PresPrimMethod.1 != "Transporter")

AUDtable <- table(AUD$PresPrimMethod) #make table for counts
NonAUDtable <- table(NonAUD$PresPrimMethod)
write.table(AUDtable, "AUDTable.xls")
write.table(NonAUDtable, "NonAUDTable.xls")

AUDTest <- wilcox.test(InAUD$PresCommuteDist, InBuffer$PresCommuteDist, alternative = "less")
#W = 538, p-value = 0.596

###GHG emissions were done elsewhere, but the exact same process and respondents. We gathered emissions data from the EPA to get our emissions for each respondent. See our methods section in full report for equations used.

###############################################################
#----------------------Prepare Data for all regressions in Research Quetsion 2-------------------
#This chunk is just preparation (columns, data types, clumping some responses, etc). No analysis in this section.
##############################################################

#read in Responses CSV to add new columns for a new subset
Responses <- read.csv('Responses.csv') 
Responses <- Responses[-c(1)] #delete first column, reads in a numbering, just deleting that

###Fill in Gender and Age with Imputation - fills in values that were left blank

dem <- Responses[-c(1:54, 58, 59, 62)] #removing the columns I don't need for faster imputation
write.csv(dem, "dem.csv")
dem <- read.csv("dem.csv", na.strings=c(""," ","NA")) # makes sure blanks come up as NA so imputation will work

dem.imp <- mice(dem, seed = 6735) #seed is a random number, if getting errors keep changing seed, this often solves some of the errors
dem.complete <- complete(dem.imp)
write.csv(dem.complete, "dem.complete.csv") #save the imputed dataset for the regressions

###Calculate various probabilities of being sampled for use in weighting the regressions (for more info on our weighting see the methodology of our full report on the project website)

#probability of being sampled and response rate, will be used for all regressions
TotalHomes <- 37114
HomesChosen <- 1000
HomesResponse <- nrow(subset(Responses, Responses$HousingType == 'SINGLE FAMILY RESIDENCE' | Responses$HousingType == 'MOBILE HOMES'))

TotalAptSB <- 4816
AptSBChosen <- 1000
AptSBResponse <- nrow(subset(Responses, Responses$City == 'SANTA BARBARA' & Responses$HousingType == 'APARTMENTS, 5 OR MORE UNITS'))

TotalAptG <- 1530
AptGChosen <- 500
AptGResponse <- nrow(subset(Responses, Responses$City == 'GOLETA' & Responses$HousingType == 'APARTMENTS, 5 OR MORE UNITS'))

###Create Response Rate column

Responses$ResponseRate <- c(1:nrow(Responses))
for(i in 1:nrow(Responses)){
  if(Responses[i,60] == 'SINGLE FAMILY RESIDENCE' | Responses[i,60] == 'MOBILE HOMES')
    Responses[i,64] <- HomesResponse/HomesChosen
  if(Responses[i,60] == 'APARTMENTS, 5 OR MORE UNITS' && Responses[i,63] == 'SANTA BARBARA')
    Responses[i,64] <- AptSBResponse/AptSBChosen
  if(Responses[i,60] == 'APARTMENTS, 5 OR MORE UNITS' && Responses[i,63] == 'GOLETA' | Responses[i,63] == 'CARPINTERIA')
    Responses[i,64] <- AptGResponse/AptGChosen
}
Responses$NonRR <- 1-Responses$ResponseRate #non-response rate

###Create non-response weight column
#--hard-coded values are based on Census 2010 data for gender by age, see excel sheets DemographicCheck and Census for more info

#We used this weighting (NRWeight) for the regressions, but tested other weightings to see how sensitive our results were to small changes
Responses$NRWeight <- c(1:nrow(Responses))
for(i in 1:nrow(Responses)){
  if(Responses[i,55] == 'Man' && Responses[i,56] == '18-25')
    Responses[i,66] <- 5.099
  if(Responses[i,55] == 'Man' && Responses[i,56] == '26-35')
    Responses[i,66] <- 1.301
  if(Responses[i,55] == 'Man' && Responses[i,56] == '36-45')
    Responses[i,66] <- 2.765
  if(Responses[i,55] == 'Man' && Responses[i,56] == '46-55')
    Responses[i,66] <- 1.685
  if(Responses[i,55] == 'Man' && Responses[i,56] == '55+')
    Responses[i,66] <- 2.445
  if(Responses[i,55] == 'Woman' && Responses[i,56] == '18-25')
    Responses[i,66] <- 1.813
  if(Responses[i,55] == 'Woman' && Responses[i,56] == '26-35')
    Responses[i,66] <- 0.829
  if(Responses[i,55] == 'Woman' && Responses[i,56] == '36-45')
    Responses[i,66] <- 2.204
  if(Responses[i,55] == 'Woman' && Responses[i,56] == '46-55')
    Responses[i,66] <- 16.847
  if(Responses[i,55] == 'Woman' && Responses[i,56] == '55+')
    Responses[i,66] <- 2.21
}

###Create probability of being chosen and weights columns

#create column of probabilities based on housing type and city - only used to test sensitivity of other weighting
Responses$Probability <- c(1:nrow(Responses))
for(i in 1:nrow(Responses)){
  if(Responses[i,60] == 'SINGLE FAMILY RESIDENCE' | Responses[i,60] == 'MOBILE HOMES')
    Responses[i,67] <- HomesChosen/TotalHomes
  if(Responses[i,60] == 'APARTMENTS, 5 OR MORE UNITS' && Responses[i,63] == 'SANTA BARBARA')
    Responses[i,67] <- AptSBChosen/TotalAptSB
  if(Responses[i,60] == 'APARTMENTS, 5 OR MORE UNITS' && Responses[i,63] == 'GOLETA' | Responses[i,63] == 'CARPINTERIA')
    Responses[i,67] <- AptGChosen/TotalAptG
}

Responses$Weight <- 1-Responses$Probability
write.csv(Responses, "Responses.csv")

Responses <- read.csv("Responses.csv")
RegData <- read.csv("RegData.csv")
RegData <- RegData[-c(1)]
#Create subset with only positive weights (deletes rows where initial code entered was incorrect)
RegData <- Responses[-c(5:5,7:12, 13:13, 15:15, 18:18, 35:54,58:59,62:62)]

###Clean up column types and whatnot (make all numbers numeric and letters into characters, put some answers in categories to decrease degrees of freedom for a stronger model)

#Change columns that need to be numeric, subset out written answers to numeric questions, recode NA as DK
RegData[53,9] <- "1" #respondant wrote 'one'
RegData$Transfers <- as.character(RegData$Transfers) #transfers
RegData$Transfers <- as.numeric(RegData$Transfers) #transfers
RegData$Transfers[is.na(RegData$Transfers)] <- 'DK'

#for transfers, make categories (too many DK to impute)
for(i in 1:nrow(RegData)){
  if(RegData[i,9] == "1" | RegData[i,9] == "2")
    RegData[i,9] <- "1-2"
}

#clean up HouseBusDist (ended up not using this column because of quality of data received)
RegData$HouseBusDist <- as.character(RegData$HouseBusDist)
for(i in 1:nrow(RegData)){ #bus distance from house
  RegData[i,6] <- gsub(" .*", "", RegData[i,6])
  RegData[i,6] <- gsub("-.*", "", RegData[i,6])
} #get rid of 'minutes' or 'min' after user response number
RegData$HouseBusDist <- as.numeric(RegData$HouseBusDist)
RegData$HouseBusDist[is.na(RegData$HouseBusDist)] <- 'DK'

#for HouseBusDist, make categories (too many DK to impute)
RegData$HouseBusDist <- as.character(RegData$HouseBusDist)
for(i in 1:nrow(RegData)){
  if(RegData[i,6] == "0" | RegData[i,6] == "1" | RegData[i,6] == "2" | RegData[i,6] == "3" | RegData[i,6] == "4" | RegData[i,6] == "5")
    RegData[i,6] <- "0-5"
  else if(RegData[i,6] == "6" | RegData[i,6] == "7" | RegData[i,6] == "8" | RegData[i,6] == "9" | RegData[i,6] == "10")
    RegData[i,6] <- "6-10"
  else if(RegData[i,6] == "DK")
    RegData[i,6] <- "DK"
  else 
    RegData[i,6] <- "11+"
}

#clean up work bus dist
RegData$WorkBusDist <- as.character(RegData$WorkBusDist)
for(i in 1:nrow(RegData)){ #bus distance from work
  RegData[i,7] <- gsub(" .*", "", RegData[i,7])
  RegData[i,7] <- gsub("-.*", "", RegData[i,7])
} #get rid of 'minutes' or 'min' after user response number
RegData$WorkBusDist <- as.numeric(RegData$WorkBusDist)
RegData$WorkBusDist[is.na(RegData$WorkBusDist)] <- 'DK'

#for WorkBusDist, make categories (too many DK to impute)
RegData$WorkBusDist <- as.character(RegData$WorkBusDist)
for(i in 1:nrow(RegData)){
  if(RegData[i,7] == "0" | RegData[i,7] == "1" | RegData[i,7] == "2" | RegData[i,7] == "3" | RegData[i,7] == "4" | RegData[i,7] == "5")
    RegData[i,7] <- "0-5"
  else if(RegData[i,7] == "6" | RegData[i,7] == "7" | RegData[i,7] == "8" | RegData[i,7] == "9" | RegData[i,7] == "10")
    RegData[i,7] <- "6-10"
  else if(RegData[i,7] == "DK")
    RegData[i,7] <- "DK"
  else 
    RegData[i,7] <- "11+"
}

#make errands numeric
RegData$Errands <- as.numeric(RegData$Errands) #errands

#Put recognition program responses into one column for a stronger model -> it will now be yes/no/DK in one column
RegData$RecProgramBike <- as.character(RegData$RecProgramBike)
RegData$RecProgramBus <- as.character(RegData$RecProgramBus)
RegData$RecProgramCarpool <- as.character(RegData$RecProgramCarpool)
RegData$RecProgramNo <- as.character(RegData$RecProgramNo)
RegData$RecProgramDK <- as.character(RegData$RecProgramDK)
for(i in 1:nrow(RegData)){
  if(RegData[i,22] == "I don\'t know")
    RegData[i,21] <- "DK"
  if(RegData[i,18] == "Yes, for bikers")
    RegData[i,21] <- "Yes"
  if(RegData[i,19] == "Yes, for carpoolers")
    RegData[i,21] <- "Yes"
  if(RegData[i,20] == "Yes, for bus riders")
    RegData[i,21] <- "Yes"
}

#remove the other rec program columns
RegData <- RegData[-c(18:20, 22)]

#clean up income, make fewer categories for a stronger model
RegData$Income <- as.character(RegData$Income)
RegData$Income <- ifelse(RegData$Income == '$150,000-$199,999'| RegData$Income == '$200,000-$249,999' | RegData$Income == '$250,000+', '$150,000+', RegData$Income)

#Create a yes/no column for primary mode = car - individual
RegData$IndividualMode <- ifelse(RegData$PresPrimMethod == "Car - Individual", "Yes","No")
RegData$IndividualMode <- as.factor(RegData$IndividualMode)
RegData$IndividualMode <- relevel(RegData$IndividualMode, ref = 'Yes')

#fix type of some data
RegData$PresResZip <- as.numeric(RegData$PresResZip)
RegData$NRWeight <- as.numeric(RegData$NRWeight)
RegData$BikePaths <- as.factor(RegData$BikePaths)

#Merge IDK with No
RegData$RedBusPass <- ifelse(RegData$RedBusPass == "I don\'t know" | RegData$RedBusPass == "No", "No-DK", "Yes")
RegData$Shower <- ifelse(RegData$Shower == "I don\'t know" | RegData$Shower == "No", "No-DK", "Yes")
RegData$Storage <- ifelse(RegData$Storage == "I don\'t know" | RegData$Storage == "No", "No-DK", "Yes")
#RegData$BikePaths <- ifelse(RegData$BikePaths == "I don\'t know" | RegData$BikePaths == "No", "No-DK", "Yes")
RegData$LiveNear <- ifelse(RegData$LiveNear == "I don\'t know" | RegData$LiveNear == "No", "No-DK", "Yes")
RegData$PreferredSpace <- ifelse(RegData$PreferredSpace == "I don\'t know" | RegData$PreferredSpace == "No", "No-DK", "Yes")
RegData$RecProgramNo <- ifelse(RegData$RecProgramNo == "DK" | RegData$RecProgramNo == "No", "No-DK", "Yes")
RegData$Guranteed <- ifelse(RegData$Guranteed == "I don\'t know" | RegData$Guranteed == "No", "No-DK", "Yes")


#lump incomes even more
RegData$Income <- ifelse(RegData$Income == "Under $30,000" | RegData$Income == "$30,000-$59,999", "Under $60,000",ifelse(RegData$Income == "$100,000-$149,999" | RegData$Income == "$150,000+","$100,000+","$60,000-$99,000"))

#lump incentives into offer something or offer nothing
RegData$Incentive <- 1:nrow(RegData)
for(i in 1:nrow(RegData)){
  if(RegData[i,10] == "Yes" | RegData[i,12] == "Yes" | RegData[i,13] == "Yes" | RegData[i,17] == "Yes" | RegData[i,18] == "Yes" | RegData[i,20] == "Yes")
    RegData[i,33] <- "Yes"
  if(RegData[i,10] != "Yes" && RegData[i,12] != "Yes" && RegData[i,13] != "Yes" && RegData[i,17] != "Yes" && RegData[i,18] != "Yes" && RegData[i,20] != "Yes")
    RegData[i,33] <- "No"
}
RegData$Incentive <- as.factor(RegData$Incentive)

#Housing Type - SFH and MH into one
RegData$HousingType <- ifelse(RegData$HousingType == "SINGLE FAMILY RESIDENCE" | RegData$HousingType == "MOBILE HOMES", "SINGLE FAMILY","APARTMENT")
RegData$HousingType <- relevel(as.factor(RegData$HousingType), "SINGLE FAMILY")

write.csv(RegData, "RegData.csv")

RegData <- read.csv("RegData.csv")
RegData <- RegData[-c(1)]

#below just for coded parts
RegData$RedBusPass <- as.numeric(RegData$RedBusPass)
RegData$Shower <- as.numeric(RegData$Shower)
RegData$Storage <- as.numeric(RegData$Storage)
RegData$BikePaths <- as.numeric(RegData$BikePaths)
RegData$LiveNear <- as.numeric(RegData$LiveNear)
RegData$PreferredSpace <- as.numeric(RegData$PreferredSpace)
RegData$RecProgramNo <- as.numeric(RegData$RecProgramNo)
RegData$Guranteed <- as.numeric(RegData$Guranteed)
RegData$Gender <- as.numeric(RegData$Gender)
RegData$Income <- as.numeric(RegData$Income)

write.csv(RegData, file = 'RegDataCode.csv') #This is the file used for the regressions


##################################
#--------------------Research Quetsion 2-----------------
##################################
#What drives an individual's decision to drive alone to work?

#This section will impute the data and perform a binary logistic regression on pooled and imputed data

####Impute Data
#good source: http://web.maths.unsw.edu.au/~dwarton/missingDataLab.html, http://www.r-bloggers.com/imputing-missing-data-with-r-mice-package/
RegData <- read.csv("RegData.csv", na.strings=c(""," ","NA")) #make sure all blank spaces are NA
RegData <- RegData[-c(1)]

#relevel data - used for interpretation simplicity only
RegData$BikePaths <- relevel(as.factor(RegData$BikePaths), "No")
RegData$Predictability <- relevel(as.factor(RegData$Predictability), "Somewhat Predictable")
RegData$LiveNear <- relevel(as.factor(RegData$LiveNear), ref = "No-DK")
RegData$PreferredSpace <- relevel(as.factor(RegData$PreferredSpace), ref = "No-DK")
RegData$Gender <- relevel(as.factor(RegData$Gender), ref = "Man")
RegData$Income <- relevel(as.factor(RegData$Income), ref = "Under $60,000")
RegData$Age <- relevel(as.factor(RegData$Age), ref = "18-25")
RegData$HousingType <- relevel(as.factor(RegData$HousingType), ref = "SINGLE FAMILY")

#explore data
require(VIM)
require(mice)
require(lattice)

#visualize where data is missing
md.pattern(RegData) 
regdata_aggr = aggr(RegData, col=mdc(1:2), numbers=TRUE, sortVars=TRUE, labels=names(RegData), cex.axis=.7, gap=3, ylab=c("Proportion of missingness","Missingness Pattern"))

#impute
RegData <- RegData[-c(6,7,12,13,14,20)]
RegData.imp <- mice(RegData, seed = 45) 
#test.imp.3 <- complete(RegData.imp) #just testing for regression iteration below
#write.csv(test.imp.2, "test.imp.2")

behav.imp1 <- pool(with(data=RegData.imp, exp=glm(IndividualMode ~ CommuteDays + PresCommuteDist  + Predictability  + Transfers + BikePaths + Gender + Age  + Incentive + Income + HousingType, family = binomial, weights = RegData.imp$NRWeight))) #imputes and pools all iterations for the regression
summary(behav.imp1)

behav.imp2 <- pool(with(data=RegData.imp, exp=glm(IndividualMode ~ CommuteDays + PresCommuteDist  + Predictability  + Transfers + BikePaths + Errands + Gender + Age  + Incentive + Income + HousingType + (HousingType*Age), family = binomial, weights = RegData.imp$NRWeight))) #same as above just testing a model with more variables
summary(behav.imp2)

##Diagnostic plots for the imputed datasets, all visual diagnostics look reasonable: NOT WORKING, MB's COMMENTS
densityplot(behav.imp,~Errands) #Note: similar density to observed values
bwplot(behav.imp) #Note: similar range to observed values
stripplot(behav.imp) #Note: none of imputed variables different from observed values

####Check for Collinearity
#Make everything numeric
RegDataCode <- read.csv("RegDataCode.csv")
RegDataCode <- RegDataCode[-c(1, 18:22)]

pairs(RegDataCode[5:21])
#run regression IndReg then:
require(car)
vif(IndReg)
#vifs higher than 1: Commutedays (3.8), HBD(2.4), Predictability(3.0),, regbuspass(2.4), cleanliness(5), shower (2.24), Abilities(3.23), Bikepaths (3.067), guaranteed(2.3), gender(2.24)

##########################################
#----------------Regression for Objective one--------------------------------------------#
###########################################

#This set of regressions just tests the quality of the data for Research Quetsion 1, it was not used in actual analysis. You can find these results in the Appendices of our project. It was essentially just adding context into who lives in what type of housing (i.e. are certain incomes more likely to live in certain housing) in preparation to defend our results. May be of use for having numbers to some ideas.

###Using imputed data from above, test HousingType
housing.imp1 <- pool(with(data=RegData.imp, exp=glm(HousingType ~Gender + Age + Income, family = binomial, weights = RegData.imp$NRWeight)))
summary(housing.imp1)

commute.imp1 <- pool(with(data=RegData.imp, exp=lm(PresCommuteDist ~Gender + Age + Income, weights = RegData.imp$NRWeight)))
summary(commute.imp1)

#Aud and Buffer
InAUD$AUD <- "AUD"
InBuffer$Buffer <- "Buffer"
write.csv(InAUD, "InAUD2.csv")
write.csv(InBuffer, "InBuffer2.csv")

#get ready for imputation then impute
AudBuff <- AudBuff[-c(1,5,7:54,58,59,61,62,63)]
#Housing Type - SFH and MH into one
AudBuff$HousingType <- ifelse(AudBuff$HousingType == "SINGLE FAMILY RESIDENCE" | AudBuff$HousingType == "MOBILE HOMES", "SINGLE FAMILY","APARTMENT")
AudBuff$HousingType <- relevel(as.factor(AudBuff$HousingType), "SINGLE FAMILY")

AudBuff$Income <- as.character(AudBuff$Income)
AudBuff$Income <- ifelse(AudBuff$Income == '$150,000-$199,999'| AudBuff$Income == '$200,000-$249,999' | AudBuff$Income == '$250,000+', '$150,000+', AudBuff$Income)
#lump incomes even more
AudBuff$Income <- ifelse(AudBuff$Income == "Under $30,000" | AudBuff$Income == "$30,000-$59,999", "Under $60,000",ifelse(AudBuff$Income == "$100,000-$149,999" | AudBuff$Income == "$150,000+","$100,000+","$60,000-$99,000"))

write.csv(AudBuff, "AudBuff.csv")
AudBuff <- read.csv("AudBuff.csv", na.strings=c(""," ","NA"))

audbuff.imp <- mice(AudBuff, seed = 5783)
ab.comp <- complete(audbuff.imp)
write.csv(ab.comp, "ab.comp.csv")
AudBuff <- read.csv("AudBuff.csv")

#add in the weights for the regression
AudBuff$NRWeight <- c(1:nrow(AudBuff))
for(i in 1:nrow(AudBuff)){
  if(AudBuff[i,6] == 'Man' && AudBuff[i,7] == '18-25')
    AudBuff[i,11] <- 5.099
  if(AudBuff[i,6] == 'Man' && AudBuff[i,7] == '26-35')
    AudBuff[i,11] <- 1.301
  if(AudBuff[i,6] == 'Man' && AudBuff[i,7] == '36-45')
    AudBuff[i,11] <- 2.765
  if(AudBuff[i,6] == 'Man' && AudBuff[i,7] == '46-55')
    AudBuff[i,11] <- 1.685
  if(AudBuff[i,6] == 'Man' && AudBuff[i,7] == '55+')
    AudBuff[i,11] <- 2.445
  if(AudBuff[i,6] == 'Woman' && AudBuff[i,7] == '18-25')
    AudBuff[i,11] <- 1.813
  if(AudBuff[i,6] == 'Woman' && AudBuff[i,7] == '26-35')
    AudBuff[i,11] <- 0.829
  if(AudBuff[i,6] == 'Woman' && AudBuff[i,7] == '36-45')
    AudBuff[i,11] <- 2.204
  if(AudBuff[i,6] == 'Woman' && AudBuff[i,7] == '46-55')
    AudBuff[i,11] <- 16.847
  if(AudBuff[i,6] == 'Woman' && AudBuff[i,7] == '55+')
    AudBuff[i,11] <- 2.21
}

AudBuff$Buffer <- relevel(AudBuff$Buffer, ref = "Buffer")
audbuff.imp.reg <- glm(Buffer ~ Gender + Age + Income, data = AudBuff, family ="binomial", weights = AudBuff$NRWeight)
summary(audbuff.imp.reg)

###################################################
#------------------------------Research Question 2: Data Check on Commute Distance-------------------------
###################################################
#What drives an individual's decision to drive a car alone to work?

#We did not find that commute distance affected an indivdual's decision to drive alone to work, so we looked deeper into the commute distance variable, comparing the mileage between all mode types

#Kruskal Wallis for Commute Dist By Vehicle
require(pgirmess)
distmode <- Responses[-c(1:4, 8:66)]
distmode <- subset(distmode, as.numeric(distmode$PresCommuteDist) > 0.01 & distmode$PresPrimMethod != "Other (Please specify)")
distaov <- kruskal.test(PresCommuteDist ~ PresPrimMethod, data = distmode)
#Kruskal-Wallis chi-squared = 30.718, df = 4, p-value = 3.495e-06 
# updated 2/8/2016

posthoc <- kruskalmc(PresCommuteDist ~ PresPrimMethod, data = distmode)
#differences between bus-walk, carpool-walk, and sov-walk

write.csv(distmode, 'ANOVA_DistMode.csv')

####################################################
#------------------Research Question 2: Data Check on Housing Type/Mode Association----------
#####################################################

#What drives an individual's decision to drive alone to work?
#This is just putting our results into more context in preparation to defend our results, we asked: Is there an association between housing type and mode of transportation? There is, but this test doesn't tell where, it just says that the association exists.

#make subset of data for just present housing type and mode choice
HTM <- Responses[-c(1:5, 7:59, 61:65)]
Apt <- subset(HTM, HTM$HousingType == 'APARTMENTS, 5 OR MORE UNITS')
House <- subset(HTM, HTM$HousingType == 'SINGLE FAMILY RESIDENCE' | HTM$HousingType == 'MOBILE HOMES')

#Make contingency table
row1 <- cbind(25, 5, 6, 5, 8, 2)
row2 <- cbind(20, 1, 2, 5, 1, 8)
HTMTable <- rbind(row1, row2)
colnames(HTMTable) <- cbind("Car", "Carpool", "Bus", "Bicycle", "Walk", "Other")
rownames(HTMTable) <- rbind("Apartments", "Single Family Homes")

#Perform chi-squared
HTMChisq <- chisq.test(HTMTable) #X-squared = 12.352, df = 5, p-value = 0.03027
HTMProp <- prop.table(HTMTable)

write.csv(HTMProp, 'HTMProp.csv')

######################################################
#---------------Research Question 2: Data Check on Moving Closer to Work and Mode Choice-------------------
#######################################################

#What drives an individual's decision to drive alone to work?

#This was also supplemental analysis, looking to see if individual's switched their mode choice once they moved to the South Coast or closer to work. We went away from this analysis for data quality concerns only; we didn't ask how long ago respondents moved and thus didn't fee comfortable making a conclusion with such uncertainty as to what other forces could affect this decision (i.e. if they moved 20 years ago maybe their life stage has more to do with the decision than now being in the South Coast). This is still a great question to explore, and can be used in the post-move in survey analysis

#Switching Modes Moving Closer to Work Witin South Coast
require(nnet)
require(ggplot2)
require(alr3)
require(MASS)
require(reshape2)

#Make subset of respondents that previously also lived in south coast
PrevZipSC <- subset(Responses, Responses$PrevResZip == '93116' | Responses$PrevResZip == '93117' |  Responses$PrevResZip == '93101' | Responses$PrevResZip == '93102' | Responses$PrevResZip == '93103' | Responses$PrevResZip == '93105' | Responses$PrevResZip == '93106' | Responses$PrevResZip == '93107' | Responses$PrevResZip == '93108' | Responses$PrevResZip == '93109' | Responses$PrevResZip == '93110' | Responses$PrevResZip == '93111' | Responses$PrevResZip == '93120' | Responses$PrevResZip == '93121' | Responses$PrevResZip == '93130' | Responses$PrevResZip == '93140' | Responses$PrevResZip == '93150' | Responses$PrevResZip == '93118' |  Responses$PrevResZip == '93199' | Responses$PrevResZip == '93013' | Responses$PrevResZip == '93014')

#create new column checking if current commute distance is >= or < previous
PrevZipSC$CloserFurther <- ifelse(PrevZipSC$PresCommuteDist >= PrevZipSC$PrevCommuteDist, 'further', 'closer')

#subset people who previously took cars
PrevCar <- subset(PrevZipSC, PrevZipSC$PrevPrimaryMethod == 'Car - Individual')

PrevCar$CarAlt <- ifelse(PrevCar$PresPrimMethod == 'Car - Individual','Car','NotCar')

#if we want 3 categories:
PrevCar$CarAlt <- 1:nrow(PrevCar)
for(i in 1:nrow(PrevCar)){
  if(PrevCar[i,6] == 'Car - Individual')
    PrevCar[i,70] <- 'Car'
  if(PrevCar[i,6] == 'Car - Carpool' | PrevCar[i,6] == 'Bus' | PrevCar[i,6] == 'Other (Please specify)')
    PrevCar[i,70] <- "GHG"
 if(PrevCar[i,6] == 'Bicycle' | PrevCar[i,6] == 'Walk')
    PrevCar[i,70] <- "NOGHG"
}

#relevel to ensure its car switching to alt mode
PrevCar$CarAlt <- relevel(as.factor(PrevCar$CarAlt), ref = "Car")
PrevCar$CloserFurther <- relevel(as.factor(PrevCar$CloserFurther), ref= "further")

#perform mutinomial logistic regression (needs to be BLR if just 2 options, results seem to be the same)
SwitchMLR <- glm(CarAlt ~ CloserFurther , data = PrevCar, family = "binomial", weights = PrevCar$NRWeight)
#manually find pvalue
z1 <- summary(SwitchMLR)$coefficient/summary(SwitchMLR)$standard.errors
p1 <- (1-pnorm(abs(z1),0,1))*2

#exponentiate for relative risk
Risk <- exp(coef(SwitchMLR))

#Visualize - Only if we include age
#view predicted probabilities with fitted function
ObservedProb <- fitted.values(SwitchMLR)

#new data frame with series that will be used to create predicted probabilities
Frame <- data.frame(CloserFurther = rep(c("closer", "further"), each = 56), AvgAge = rep(seq(0, 55),2))

#now use this to find predicted probablities, Frame is info we use to feed
PredProb <- cbind(Frame, predict(SwitchMLR, newdata = Frame, type = "probs"))

#melt is basically the same as stacking data, necessary for graphing
PredProbMelt <- melt(PredProb, id.vars = c("CloserFurther", "AvgAge"), value.name = "Probability")

Graph1 <- ggplot(PredProbMelt, aes(x = AvgAge, y = Probability, colour = CloserFurther)) +
  geom_line() +
  facet_grid(variable ~., scale = "free")+
  xlab("Average Age (year)") +
  ylab("Predicted Probabilities") +
  ggtitle("Effects of Age and Moving Closer to Work \non Mode Choice in the South Coast") #~ because you could say i want to first split by var A and then by var B
#good way to view results in terms of odds and probability, type Graph1 into console window to view

#################################################
#---------------Research Question 2: Data Check on Zip Code and Mode------------------------------
#What dirves an individual's decision to drive alone to work?
#################################################

#Also a supplemental analsysis to our regression for more context. We tested association between home zip code and mode choice, trying to see if certain areas of the city support some trasportaion more/less than others. Our problem was that we just didn't have enough responses for meaningful results but it would be a great analysis to redo.

#make table
row1 <- c(14,2,4,2,5,1) #93101
row2 <- c(8,0,2,3,1,3) #93105
row3 <- c(11,2,1,2,2,0) #93117

MapTable <- rbind(row1, row2, row3)
colnames(MapTable) <- c("Car", "Carpool", "Bus", "Bike", "Walk", "Other")
rownames(MapTable) <- c('93101', '93105', '93117')

#perform analysis
MapX2 <- chisq.test(MapTable) #X-squared = 10.09, df = 10, p-value = 0.4326

#same idea but linear regression
require(nnet)
Responses$PresPrimMethod <- relevel(as.factor(Responses$PresPrimMethod), ref = "Car - Individual")
locationMLR <- multinom(PresPrimMethod ~ PresWorkZip, data = Responses)
#manually find pvalue
z1 <- summary(locationMLR)$coefficient/summary(locationMLR)$standard.errors
p1 <- (1-pnorm(abs(z1),0,1))*2

#exponentiate for relative risk
Risk <- exp(coef(locationMLR))

#########################################
#---------------------Research Question 3----------------------------------------
#########################################

#This is the discrete choice experiment portion. Our last section of the survey was for individuals that selcted a car as their primary mode choice. We asked the question 'Choose the option that best suits your lifestyle' and they were given two option, 1) drive my car alone and 2) alternative transportation with an incentive + parking fee ($0, $10, $15). These choices were shown randomly. The analysis is intended to back out if any incentive is more effective than others or if any mode is easier to switch to compared to others. This code organizes the data and performs a binary logistic regression. A great analysis to do again with more data!

choice <- read.csv('RawRandomized_01282016.csv') #coded answers downloaded from Qualtrics

bike.m <- read.csv("bike.m.csv") #used excel to organize, but this is just responses for the biking questions
bus.m <- read.csv("bus.m.csv") #just the bus questions
cp.m <- read.csv("cp.m.csv") #just the carpool questions


#delete unnecessary columns, rename columns
choice <- choice[-c(1:17, 19:60, 73:76, 86:89)]
choice <- choice[-c(1), ]
colnames(choice) <- c("Mode", "Bike1", "Bike2", "Bike3", "Bus1", "Bus2", "Bus3", "Carpool1", "Carpool2", "Carpool3", "Gender", "Age", "Income", "dobike1", "dobike2", "dobike3", "dobus1", "dobus2", "dobus3", "docarpool1", "docarpool2", "docarpool3")

#subset to just have car drivers
choice <- subset(choice, choice$Mode == 1)

###recode display order columns to make it usable 

#make all display order columns characters instead of factors
choice$dobike1 <- as.character(choice$dobike1)
choice$dobike2 <- as.character(choice$dobike2)
choice$dobike3 <- as.character(choice$dobike3)
choice$dobus1 <- as.character(choice$dobus1)
choice$dobus2 <- as.character(choice$dobus2)
choice$dobus3 <- as.character(choice$dobus3)
choice$docarpool1 <- as.character(choice$docarpool1)
choice$docarpool2 <- as.character(choice$docarpool2)
choice$docarpool3 <- as.character(choice$docarpool3)

#get rid of 1| in every row starting at column 14 (display orders)
for(i in 1:nrow(choice)){
  for(j in 14:ncol(choice)){
    choice[i,j] <- substring(choice[i,j], 3)
  }
}

write.csv(choice, "choice.csv") #out of order, easiest to change in excel, make sure this step happens
choice <- read.csv("choice.csv") #read it back in after fixing the misnamed columns and reordering

#delete rows where individuals didn't even go through the section
choice <- choice[-c(41, 44, 46, 61), ]


#will need fcp package for clustering
require(flexmix)
require(reshape2)
require(cjoint)
 
###bike organization and regression
#transpose, melt, and set fees
bike.choice <- choice[-c(1, 5:19)]
bike.t <- t(bike.choice)
write.csv(bike.m, "bike.m.csv")
bike.m <- melt(bike.t)

colnames(bike.m) <- c("fee", "respondent", "choice", "NRWeight")
bike.m$fee <- ifelse(bike.m$fee == "Bike1",0,ifelse(bike.m$fee == "Bike2",10,15))

bike.do <- choice[-c(1:10, 14:20)]
bike.do.t <- t(bike.do)
bike.do.m <- melt(bike.do.t)
bike.do.use <- bike.do.m[-c(1)]
colnames(bike.do.use) <- c("respondent", "incentive")

#merge incentive onto bike.m data frame
bike.m$incentive <- bike.do.use$incentive
#get rid of NAs
bike.m <- bike.m[-c(5,11,12,44,45,50,51,86,87,121,122,123,130,131,132,136,137,138,181,182,183), ]
bike.m$choice <- ifelse(bike.m$choice == "1", 1,0) #binary
bike.m$choice <- relevel(as.factor(bike.m$choice), ref = "1")
bike.m$incentive <- relevel(as.factor(bike.m$incentive), ref = "6")
bike.m$fee <- as.numeric(bike.m$fee)

#require(glmmML)

bike.m$incentive <- as.factor(bike.m$incentive)
#bike.reg <- glmmML(choice ~ fee + incentive, data = bike.m, cluster = respondent, weights = bike.m$NRWeight)
#bike.reg2 <- glmmML(choice ~ fee + incentive + (fee*incentive), data = bike.m, cluster = respondent, weights = bike.m$NRWeight)

bike.reg <- glm(choice ~ fee + incentive, family = "binomial", data = bike.m, weights = bike.m$NRWeight)
summary(bike.reg)

library(clusterSEs)
clust.bike.p <- cluster.bs.glm(bike.reg, bike.m, ~ respondent, report = T)

###bus organizaton and regression
#transpose, melt, and set fees
bus.choice <- choice[-c(1:4, 8:19)]
bus.t <- t(bus.choice)
bus.m <- melt(bus.t)
write.csv(bus.m,"bus.m.csv")

colnames(bus.m) <- c("fee", "respondent", "choice", "NRWeight")
bus.m$fee <- ifelse(bus.m$fee == "Bus1",0,ifelse(bus.m$fee == "Bus2",10,15))

bus.do <- choice[-c(1:13, 17:20)]
bus.do.t <- t(bus.do)
bus.do.m <- melt(bus.do.t)
bus.do.use <- bus.do.m[-c(1)]
colnames(bus.do.use) <- c("respondent", "incentive")

#merge incentive onto bus.m data frame
bus.m$incentive <- bus.do.use$incentive

bus.m <- bus.m[-c(37,38,43,44,45,50,51,86,87,121,122,123,130,131,132,147,136,137,138,181,182,183), ]
bus.m$choice <- ifelse(bus.m$choice == "1", 1,0) #binary
bus.m$choice <- relevel(as.factor(bus.m$choice), ref = "1")
bus.m$incentive <- relevel(as.factor(bus.m$incentive), "5")
bus.m$fee <- as.numeric(bus.m$fee)

bus.m$incentive <- as.factor(bus.m$incentive)
#bus.reg <- glmmML(choice ~ fee + incentive, data = bus.m, cluster = respondent, weights = bus.m$NRWeight)
#bus.reg2 <- glmmML(choice ~ fee + incentive + (fee*incentive), data = bus.m, cluster = respondent, weights = bus.m$NRWeight)

bus.reg <- glm(choice ~ fee + incentive, family = "binomial", data = bus.m, weights = bus.m$NRWeight)
summary(bus.reg)
clust.bus.p <- cluster.bs.glm(bus.reg, bus.m, ~ respondent, report = T)

###carpool organization and regression
cp.choice <- choice[-c(1:7, 11:19)]
cp.t <- t(cp.choice)
cp.m <- melt(cp.t)
write.csv(cp.m, "cp.m.csv")
colnames(cp.m) <- c("fee", "respondent", "choice","NRWeight")
cp.m$fee <- ifelse(cp.m$fee == "Carpool1",0,ifelse(cp.m$fee == "Carpool2",10,15))

cp.do <- choice[-c(1:16,20)]
cp.do.t <- t(cp.do)
cp.do.m <- melt(cp.do.t)
cp.do.use <- cp.do.m[-c(1)]
colnames(cp.do.use) <- c("respondent", "incentive")

cp.m$incentive <- cp.do.use$incentive

cp.m <- cp.m[-c(37,38,39,43,44,45,50,51,85,86,87,121,122,123,130,131,132,147,136,137,138,181,182,183), ]
cp.m$choice <- ifelse(cp.m$choice == "1", 1,0) #binary
cp.m$choice <- relevel(as.factor(cp.m$choice), ref = "1")
cp.m$incentive <- relevel(as.factor(cp.m$incentive), ref = "3")
cp.m$fee <- as.numeric(cp.m$fee)

cp.m$incentive <- as.factor(cp.m$incentive)
#cp.reg <- glmmML(choice ~ fee + incentive, data = cp.m,cluster = respondent, weights = cp.m$NRWeight)
#cp.reg2 <- glmmML(choice ~ fee + incentive + (fee*incentive), data = cp.m, cluster = respondent, weights = cp.m$NRWeight)

cp.reg <- glm(choice ~ fee + incentive, family = "binomial", data = cp.m, weights = cp.m$NRWeight)
summary(cp.reg)
clust.cp.p <- cluster.bs.glm(cp.reg, cp.m, ~ respondent, report = T)


write.csv(bike.m, "bike.m.csv")
write.csv(bus.m, "bus.m.csv")
write.csv(cp.m,"cp.m.csv")

#######################################
#-----------------------------Data Quality Check: MDE-------------------------------------------
#######################################

#Some statistics to check the Minimum Detectable Effect to defend our results

#commute dist coef and se: 0.008944215	0.01087072, df = 119
se <- 0.01087072
sims = 5

significant.experiments <- rep(NA, sims)  # Empty object to count significant experiments

choose <- rt(n = 1000, df = 119, ncp = 0.81)*se
choose <- as.data.frame(choose)

choose$row <- 1:1000
colnames(choose) <- c("result", "num")
greater <- subset(choose, choose$result >=0) #need a subset greater than 80
#our coef gives only 495
#we need coef of 0.81 to get 806/1000

###########################################
#-----------------------Data Quality Check: Historgrams-----------------------------
###########################################

#Just chcking out the data -> we used non-parametric because this data is not normally dstributed and some have less than 3 responses

apt <- subset(Responses, Responses$HousingType == 'APARTMENTS, 5 OR MORE UNITS')
sfh <- subset(Responses, Responses$HousingType == 'SINGLE FAMILY RESIDENCE' | Responses$HousingType == "MOBILE HOMES")

hist(apt$PresCommuteDist)
hist(sfh$PresCommuteDist)
