##### Code for flagging data quality #####

# Choose working directory and file
wd <- "~/Work/Sites/Hainich/Soil Respiration/Automatic_chambers/data/2019/"
file1 <- "SR-Li8100-Hainich-v1-2019127-2019163.csv"
outfile <- 'SR_LI8100_Ha_2019.csv'

library(readr)
setwd("~/Work/Sites/Hainich/Soil Respiration/Automatic_chambers/processing-QC")
source("FlagTimeSeriesOutliers.R")
setwd(wd)
datin <- read_csv(file1)

  #### Wrapper function for finding outliers in the LI8100 SR data ####

FlagSR <- function(data) {
  for(i in unique(data$Port)) {
    dat <- data[data$Port==i,]
    dat$flag_Exp_Flux <- FlagTSOutliers(dat$Exp_Flux, min = 0.02, max = 25, dif = 4, xsd = 3, remove = TRUE, n = 3)
    dat$flag_soil_temp <- FlagTSOutliers(dat$soil_temp, min = -10, max = 30, dif = 0.5, xsd = 3, remove = TRUE)
    dat$flag_soil_moist <- FlagTSOutliers(dat$soil_moist, min = -0.02, max = 0.5, dif = 0.02, xsd = 3, sdmax = 0.05, remove = TRUE)
    assign(paste0('dat',i), dat)
  }
  # browser()
  for(i in unique(data$Port)) {
    if (i==1) out <- dat1 else {
      out <- rbind(out, get(paste0("dat", i)))
    }
  }
  return(out)
}

# SR2016_flagged <- FlagSR(data = dat)
out <- FlagSR(data = datin)

## Other flags
out$flag_Exp_Flux[is.na(out$Exp_R2) | out$Exp_R2 < 0.8] <- 6
out$flag_soil_temp[out$soil_temp == 0] <- 7
out$flag_soil_moist[out$Date > '2017-04-01' & out$Date < '2017-10-01' & out$Label == '81N-2368'] <- 7
out$flag_soil_temp[out$Date > '2017-04-01' & out$Date < '2017-10-01' & out$Label == '81N-2368'] <- 7

out$soil_temp_QC <- out$soil_temp
out$soil_temp_QC[out$flag_soil_temp != 0] <- NA
out$soil_moist_QC <- out$soil_moist
out$soil_moist_QC[out$flag_soil_moist != 0] <- NA
out$Exp_Flux_QC <- out$Exp_Flux
out$Exp_Flux_QC[out$flag_Exp_Flux != 0] <- NA

write_csv(x = out, path = outfile)

