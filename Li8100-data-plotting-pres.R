# load data

library(lubridate)
library(ggplot2)
library(readr)

### Settings --------------
setwd("~/Work/Sites/Hainich/Soil Respiration/Automatic_chambers/data/")
file <- "SR_LI8100_Ha_2018.csv"

### --------------
dat <- read_csv(file)

# for(i in files) {
#   if(i == files[1]) {
#     dat_all <- read.delim(i, skip = 1)
#   } else {
#     dat_all <- rbind(dat, read.delim(i, skip = 1))
#   }
# }

## Set date range for plots
# dat <- dat[!is.na(dat$Date),]
startDay <- "2018-01-01" # min(dat$Date) # "format yyyy-mm-dd
endDay   <- "2018-12-20" # max(dat$Date) # format yyyy-mm-dd

dat_plot <- dat[dat$Date >= startDay & dat$Date <= endDay,]
# dat_plot <- SR2016_flagged[SR2016_flagged$Date >= startDay & SR2016_flagged$Date <= endDay,]
# dat_plot <- SR2017_flagged[SR2017_flagged$Date >= startDay & SR2017_flagged$Date <= endDay,]
# dat_plot <- out[out$Date >= startDay & out$Date <= endDay & out$Instrument.Name == "81A-0450", ]

## Plot flux data ----------------------------------------------------
ggplot(data = dat_plot, aes(x = Date, y = Exp_Flux, color = Label)) +
  # geom_point() +
  geom_point(aes(alpha=as.numeric(as.logical(flag_Exp_Flux)), shape=as.factor(flag_Exp_Flux))) +
  scale_alpha_continuous(range = c(1, 0.3)) +
  ylim(-1,12.5) +
  theme(legend.position = c(0.9, 0.75))

ggplot(data = dat_plot, aes(x = Date, y = soil_temp, color = Label)) +
  # geom_line() +
  geom_point(aes(alpha=as.numeric(as.logical(flag_soil_temp)), shape=as.factor(flag_soil_temp))) +
  scale_alpha_continuous(range = c(1, 0.3)) +
  ylim(-3,30) +
  theme(legend.position='none')

ggplot(data = dat_plot, aes(x = Date, y = soil_moist, color = Label)) +
  # geom_line() +
  geom_point(aes(alpha=as.numeric(as.logical(flag_soil_moist)), shape=as.factor(flag_soil_moist))) +
  scale_alpha_continuous(range = c(1, 0.3)) +  
  ylim(0, 0.5) +
  theme(legend.position='none')


## Plot flux data without outliers ------------------------------------------------
ggplot(data = dat_plot, aes(x = Date, y = Exp_Flux_corr, color = Label)) +
  geom_point() +
  # geom_point(aes(alpha=as.numeric(as.logical(flag_Exp_Flux)), shape=as.factor(flag_Exp_Flux))) +
  scale_alpha_continuous(range = c(1, 0.3)) +
  ylim(-1,15) +
  theme_bw()

ggplot(data = dat_plot, aes(x = Date, y = soil_temp_corr, color = Label)) +
  geom_point() +
  # geom_point(aes(alpha=as.numeric(as.logical(flag_soil_temp)), shape=as.factor(flag_soil_temp))) +
  scale_alpha_continuous(range = c(1, 0.3)) +
  ylim(-3,30) +
  theme_bw()

ggplot(data = dat_plot, aes(x = Date, y = soil_moist_corr, color = Label)) +
  geom_point() +
  # geom_point(aes(alpha=as.numeric(as.logical(flag_soil_moist)), shape=as.factor(flag_soil_moist))) +
  scale_alpha_continuous(range = c(1, 0.3)) +  
  ylim(0, 0.5) +
  theme_bw()
