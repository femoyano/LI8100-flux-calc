# soil-respiration-scripts

#### Warning! As of 2021-09-23 the calculations no longer seem to be correct: calculated fluxes are way too high. (possible error/bug in LI8100-stream-process.R, in the raw data, or config files?)


This repository holds scripts related to processing and visualizing soil respiration data.

The files named cosore* are from the COSORE project (Bond-Lamberty). https://github.com/bpbond/cosore. Other files were written by Fernando Moyano

cosore-parse-LI8100 can be used to exctract fluxes from the .81x Licor files

LI8100-stream* files are for calculating fluxes from streamed Li8100 data (.dat files).

File LI8100-stream-chambersetup.csv has settings that are chamber specific. File LI8100-stream-configcalc.csv has settings that are used in all calculations.

Chamber volumes and surface areas from https://www.licor.com/env/products/soil_flux/specs-chambers.html

Information on the measurement cycles can be found here:  
https://www.licor.com/env/support/LI-8100A/topics/measurement-cycle.html
