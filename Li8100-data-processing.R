### Licor 8100 soil respiration data processing ###
## This script works with text files created using the SoilFluxPro program ##

### User Settings --------------
setwd("~/Work/Sites/Hainich/Soil Respiration/Automatic_chambers/data/2019/")
files <- dir(pattern = "Fluxes_Li8100")
site <- 'Hainich'
version <- 1  # Version of the data (e.g. for different recomputations)

### Non-user Settings --------------
library(lubridate)
library(ggplot2)
options(stringsAsFactors=F)

# dat_all <- read.delim(files[2], skip = 1)
for(i in files) {
  if(i == files[1]) {
    dat_all <- read.delim(i, skip = 1)
  } else {
    dat_all <- rbind(dat_all, read.delim(i, skip = 1))
  }
}

# Make sure all numeric variables are stored as such.
for (i in c("Exp_Flux", "Exp_FluxCV", "Exp_R2", "Lin_Flux", "Lin_FluxCV", "Lin_R2",
            "V1_IV", "V2_IV", "V3_IV", "V4_IV", "Tcham_IV", "Pressure_IV",
            "H2O_IV", "CO2_IV")) {
  dat_all[,i] <- as.numeric(dat_all[,i])
}

dat_all$Date <- ymd_hms(dat_all$Date_IV)
dat_all$soil_temp <- dat_all$V3_IV
dat_all$soil_moist <- dat_all$V2_IV
dat_all$month <- month(dat_all$Date)
dat_all$year <- year(dat_all$Date)
dat_all$Port <- dat_all$Port.

# Subset, removing unnecessary variables
dat <- subset(dat_all, select = c('Date', 'Instrument.Name', 'Label', 'Port', 'soil_temp', 'soil_moist',
                                  'Exp_Flux', 'Exp_FluxCV', 'Exp_R2', 'Lin_Flux', 
                                  "Lin_FluxCV", "Lin_R2", 'CrvFitStatus', "Tcham_IV",
                                  "Pressure_IV", "H2O_IV", "CO2_IV"))

# startdate <- strftime(min(dat$Date, na.rm=TRUE), format = "%Y%m%d")
# enddate <- strftime(max(dat$Date, na.rm=TRUE), format = "%Y%m%d")
startdate <- paste0(dat_all$year[1], formatC(yday(min(dat$Date, na.rm=TRUE)), width=3, flag = 0))
enddate <- paste0(dat_all$year[1], formatC(yday(max(dat$Date, na.rm=TRUE)), width=3, flag = 0))

rm(dat_all, i, files)

write.csv(x = dat, file = paste0('SR-Li8100-', site, '-', 'v', version, '-', startdate, '-', enddate, '.csv'), row.names = FALSE)

