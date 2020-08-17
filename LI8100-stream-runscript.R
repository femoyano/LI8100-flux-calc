##### Data required when calling the function to process streamed data

## What I can deduce from the data from 2020-07-13
## The first measurement starts at ca. second 60 of each hour and each measurement interval lasts ca. 4:10 (250 seconds)
## There are 110 seconds between measurements. (250+110) * 5 = 1800, so the 5 chambers are measured in half an hour.
## Chamber volumes and surface areas from https://www.licor.com/env/products/soil_flux/specs-chambers.html

source("LI8100-stream-mergedat.R")
source('LI8100-stream-process-fun.R')
col_names <- names(read.csv('input_chambersetup.csv', nrows = 0))
chambersetup <- read.csv("input_chambersetup.csv", skip = 2, col.names = col_names)
configcalc   <- read.csv("input_configcalc.csv", row.names = "name")

##### Call functions
rawdata <- merge_LI8100A_dat("../Automatic_chambers/data/2020-stream/")
fluxdata <- process_LI8100_stream(rawdata, chambersetup, configcalc)

#### Plot values

library(ggplot2)

ggplot(data = fluxdata, aes(x = TIME_START, y = SR, group = label, color = as.factor(label))) + geom_line()
