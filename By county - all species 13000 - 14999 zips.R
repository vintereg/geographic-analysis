# Plots all viable admissions by full year.
# Last modified on Feb. 8, 2015

# Egan comments.

source("do housekeeping and read data.R")

# Create a variable (column) that corresponds to the year of each admission:
admissions$Year <- as.numeric(format(admissions$Posix.Time,"%Y"))

# Create a new dataframe that contains only certain selected variables (columns), so that
# we can then apply the table() function to the dataframe:
admissions.trimmed <- admissions[c("Person.ID", "Postal.Code", "Operation.Type", "Operation.Subtype", "Animal.ID", "Year")]

# Clean-up the Zip codes (invalid Zip codes are replaced with "NA"):
admissions.trimmed$Postal.Code <- clean.zipcodes(admissions.trimmed$Postal.Code)

# Drop any Zip codes that are equal to "NA":
admissions.trimmed <- admissions.trimmed[which(!is.na(admissions.trimmed$Postal.Code)),]

# "Viable admissions" refers to animals that are potentially adoptable at the time of admission.
# Non-viable admissions are euthanasia requests, DOAs, wildlife admissions, service-in animals, etc.
source("drop all non-viable admissions.R")

# Keep only the last five years, inclusive:
admissions.trimmed <- admissions.trimmed[which(admissions.trimmed$Year >= 2010 &
                                               admissions.trimmed$Year <= 2014),]

# Keep only zip codes that start with 13- and 14-:
admissions.trimmed <- admissions.trimmed[which(substr(admissions.trimmed$Postal.Code, 1, 2) == "13" |
                                               substr(admissions.trimmed$Postal.Code, 1, 2) == "14"),]

# Use the factor() function to do some clean-up (eliminate factors that aren't present anymore):
admissions.trimmed$Year <- factor(admissions.trimmed$Year)
admissions.trimmed$Postal.Code <- factor(admissions.trimmed$Postal.Code)
admissions.trimmed$Operation.Type <- factor(admissions.trimmed$Operation.Type)
admissions.trimmed$Operation.Subtype <- factor(admissions.trimmed$Operation.Subtype)

# Aggregate the admissions data by zip code:
admissions.by.zip.code <- as.data.frame(table(admissions.trimmed$Postal.Code))
colnames(admissions.by.zip.code)[1] <- "zip" # Change the column name (variable name)
colnames(admissions.by.zip.code)[2] <- "Admissions"

# zipcode is a dataframe that contains Zip codes mapped to city, state, latitute, longitude:
admissions.by.zip.code <- merge(admissions.by.zip.code, zipcode, by = "zip")

# Reorder by descending number of admissions:
admissions.by.zip.code <- admissions.by.zip.code[order(-admissions.by.zip.code$Admissions),]
cat("\n\nAdmissions by zip code:\n")
print(admissions.by.zip.code)

# Write data to file:
write.csv(admissions.by.zip.code, file="all_viable_admissions_zip_code_2010-2014.csv", row.names=FALSE)

# Aggregate the zip-code data by city/town, sort the data, and write it to an output file:
admissions.by.town <- admissions.by.zip.code[c("city", "Admissions")]
admissions.by.town.aggregated <- aggregate(admissions.by.town$Admissions, by=list(admissions.by.town$city), FUN="sum")
admissions.by.town.aggregated <- admissions.by.town.aggregated[order(-admissions.by.town.aggregated$x),]
write.csv(admissions.by.town.aggregated, file="all_viable_admissions_aggregated_by_town.csv", row.names=FALSE)

# Aggregate the zip-code data by county, sort the data, and write it to an output file:
admissions.by.county <- merge(admissions.by.zip.code, zip.to.county, by="zip")
admissions.by.county.aggregated <- aggregate(admissions.by.county$Admissions, by=list(admissions.by.county$county), FUN="sum")
admissions.by.county.aggregated <- admissions.by.county.aggregated[order(-admissions.by.county.aggregated$x),]
admissions.by.county.aggregated$State <- "NY"
colnames(admissions.by.county.aggregated)[1] <- "County"
colnames(admissions.by.county.aggregated)[2] <- "Admissions"
write.csv(admissions.by.county.aggregated, file="all_viable_admissions_aggregated_by_county.csv", row.names=FALSE)

# Aggregate data by Greater Rochester counties, Western NY counties, and all other counties:
# (Note that I'm re-using some of the county names, because R won't easily allow you to introduce new factors)
greater.rochester.counties <- c("Monroe", "Ontario", "Wayne", "Livingston")
western.ny.counties <- c("Orleans", "Genesee", "Wyoming", "Niagara", "Erie", "Allegany", "Cattaraugus", "Chautauqua")
admissions.by.county.aggregated$County[admissions.by.county.aggregated$County %in% greater.rochester.counties] <- "Monroe"
admissions.by.county.aggregated$County[admissions.by.county.aggregated$County %in% western.ny.counties] <- "Erie"
admissions.by.county.aggregated$County[!(admissions.by.county.aggregated$County %in% c("Erie", "Monroe"))] <- "Seneca"
admissions.by.county.aggregated <- aggregate(admissions.by.county.aggregated$Admissions, by=list(admissions.by.county.aggregated$County), FUN="sum")

# Process the dataframe a little to make it more readable in the output file:
colnames(admissions.by.county.aggregated)[1] <- "County"
colnames(admissions.by.county.aggregated)[2] <- "Admissions"
admissions.by.county.aggregated$Group[admissions.by.county.aggregated$County == "Monroe"] <- "Greater.Rochester"
admissions.by.county.aggregated$Group[admissions.by.county.aggregated$County == "Erie"]   <- "West.of.Rochester"
admissions.by.county.aggregated$Group[admissions.by.county.aggregated$County == "Seneca"] <- "All.Other"
write.csv(admissions.by.county.aggregated, file="all_viable_admissions_aggregated_by_county_groups.csv", row.names=FALSE)
