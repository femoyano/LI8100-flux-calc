##### Start here!

# This script will calculate and plot multiplexed soil respiration fluxes from .dat LI-8100 streamed files
# (not to be confused with .81x files where the fluxes are already calculated).

# How to use:
# Set the values in LI8100-stream-chambersetup.csv, LI8100-stream-configcalc.csv
# and the data folder path (below) and then run this script.
# Note: all .dat files in the given folder will be used.

### Set here the path to folder with raw data files
data_folder <- "./2020-stream"

# Read in functions and setup parameters
source("LI8100-stream-mergedat.R")
source('LI8100-stream-process.R')
col_names    <- names(read.csv('LI8100-stream-chambersetup.csv', nrows = 0))
chambersetup <- read.csv("LI8100-stream-chambersetup.csv", skip = 2, col.names = col_names, header = FALSE)
configcalc   <- read.csv("LI8100-stream-configcalc.csv", row.names = "name")

### Call functions
rawdata <- LI8100_stream_mergedat(data_folder)
fluxdata <- LI8100_stream_process(rawdata, chambersetup, configcalc)

### Plot values

library(ggplot2)

ggplot(data = fluxdata, aes(x = TIME_START, y = SR, group = label, color = as.factor(label))) + geom_line() # + ylim(-5, 10)
ggplot(data = fluxdata, aes(x = TIME_START, y = SR_lin, group = label, color = as.factor(label))) + geom_line() # + ylim(-5, 10)
ggplot(data = fluxdata, aes(x = TIME_START, y = R2_lin, group = label, color = as.factor(label))) + geom_line()
ggplot(data = fluxdata, aes(x = TIME_START, y = RSE_exp, group = label, color = as.factor(label))) + geom_line() + ylim(0, 10)
