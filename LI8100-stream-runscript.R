##### Data required when calling the function to process streamed data

source("LI8100-stream-mergedat.R")
source('LI8100-stream-process-fun.R')

## What I can deduce from the data from 2020-07-13
## The first measurement starts at ca. second 60 of each hour and each measurement interval lasts ca. 4:10 (250 seconds)
## There are 110 seconds between measurements. (250+110) * 5 = 1800, so the 5 chambers are measured in half an hour.

# Chamber volumes and surface areas from https://www.licor.com/env/products/soil_flux/specs-chambers.html
chamberdata <- data.frame(
  index      = seq(1,10),
  label      = rep(seq(1:5), 2)   , # chamber labels
  vol        = rep(4076.1, 10)    , # [cm^3] Needs correcting for actual volume in field.
  area       = rep(317.8, 10)     , # [cm^2] 
  meas_start = seq(60, 3600, 360)   # [s] Meas start times within the hour in seconds
)

configcalc <- c(
  meas_length   = 250  , # [s] Time between chamber close and chamber open
  exclude_start = 30   , # [s] Times to exclude (deadband) after chamber close for calculating fluxes
  exclude_end   = 30   , # [s] Times to exclude (deadband) before chamber open for calculating fluxes
  linfit_secs   = 30     # [s] Seconds after deadband to use for the linear fit
)

##### Call functions
rawdata <- merge_LI8100A_dat("data1")
fluxdata <- process_LI8100_stream(rawdata, chamdata, measdata)

#### Plot values
library(ggplot2)
ggplot(data = fluxdata, aes(x = TIME_START, y = SR, group = label, color = as.factor(label))) + geom_line()
