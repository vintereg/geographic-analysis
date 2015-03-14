require(ggplot2)
require(scales)
require(Cairo)
require(grid)
require(zipcode)

cat('\f') # Clear the console by sending a form-feed character to it
rm(list = ls(all.names = TRUE))  # Clean up the workspace by removing all the old objects

data(zipcode)
# Note: The CSV input file might have some blank rows and/or some header rows that are duplicated,
# because of the way that smaller "sub-files" were concatenated in DOS into the complete file.
# These blanks & duplicates will be filtered-out further down.
admissions <- read.csv("input-data/all_years.csv")

# This next line makes sure that all the animal IDs are valid.  The effect is to drop blank rows as well
# as duplicate header rows:
admissions <- admissions[which(substr(admissions$Animal.ID, 1, 2) %in% c("A0", "A1", "A2")),]

# Convert the intake date-time into a data type that R understands:
admissions$Posix.Time <- as.POSIXct(admissions$Operation.Date, format="%m/%d/%Y %I:%M %p", tzone="America/New_York")

# Drop any admissions that occurred earlier than the year 2000:
admissions <- admissions[which(format(admissions$Posix.Time,"%Y") >= 2000),]

# Read the CSV file that maps zip codes to counties (this file is courtesy of Luke Wenschhof):
zip.to.county <- read.csv("input-data/zip_codes_mapped_to_counties.csv")