# load data

library(lubridate)
library(ggplot2)
library(readr)

### Settings --------------
setwd("~/Work/Sites/Hainich/Soil Respiration/Automatic_chambers")
file <- "~/Work/Sites/Hainich/Soil Respiration/Automatic_chambers/data/2019/SR_LI8100_Ha_2019.csv"

### --------------
dat <- read_csv(file)

# for(i in files) {
#   if(i == files[1]) {
#     dat_all <- read.delim(i, skip = 1)
#   } else {
#     dat_all <- rbind(dat, read.delim(i, skip = 1))
#   }
# }

PlotTimeSeries <- function(var, datebreak="1 month", basesize=30, start=startDay, end=endDay, ymin, ymax) {
  # browser()
  dat_plot <- dat[dat$Date >= start & dat$Date <= end,]
  png(filename = paste0("plots/", var, "_", startDay, "-", endDay, ".png"), width = 900, height = 700)
  p <- ggplot(data = dat_plot, aes_string(x = "Date", y = var, color = "Label")) +
    geom_point() +
    # geom_point(aes(alpha=as.numeric(as.logical(flag_Exp_Flux)), shape=as.factor(flag_Exp_Flux))) +
    scale_alpha_continuous(range = c(1, 0.3)) +
    ylim(ymin,ymax) +
    geom_hline(yintercept = 0, color = "grey50") +
    # scale_x_datetime(date_breaks = datebreak) +
    theme_set(theme_bw(base_size = basesize)) +
    theme_set(theme_update(legend.position = c(0.87, 0.85)))
  print(p)
  dev.off()
}

startDay <- "2019-01-01" # min(dat$Date) # "format yyyy-mm-dd
endDay   <- "2019-12-30" # max(dat$Date) # format yyyy-mm-dd
PlotTimeSeries(var = "Exp_Flux", datebreak = "3 months", basesize = 30, ymin = -1, ymax = 15)
PlotTimeSeries(var = "Exp_Flux_QC", datebreak = "3 months", basesize = 30, ymin = -1, ymax = 15)
PlotTimeSeries(var = "soil_temp", datebreak = "3 months", basesize = 30, ymin = -3, ymax = 30)
PlotTimeSeries(var = "soil_temp_QC", datebreak = "3 months", basesize = 30, ymin = -3, ymax = 30)
PlotTimeSeries(var = "soil_moist", datebreak = "3 months", basesize = 30, ymin = -0.1, ymax = 1.1)
PlotTimeSeries(var = "soil_moist_QC", datebreak = "3 months", basesize = 30, ymin = 0, ymax = 0.50)

startDay <- "2017-01-01" # min(dat$Date) # "format yyyy-mm-dd
endDay   <- "2017-12-30" # max(dat$Date) # format yyyy-mm-dd
PlotTimeSeries(var = "Exp_Flux", datebreak = "3 months", basesize = 30, ymin = -1, ymax = 15)
PlotTimeSeries(var = "Exp_Flux_QC", datebreak = "3 months", basesize = 30, ymin = -1, ymax = 15)
PlotTimeSeries(var = "soil_temp", datebreak = "3 months", basesize = 30, ymin = -3, ymax = 30)
PlotTimeSeries(var = "soil_temp_QC", datebreak = "3 months", basesize = 30, ymin = -3, ymax = 30)
PlotTimeSeries(var = "soil_moist", datebreak = "3 months", basesize = 30, ymin = 0, ymax = 0.50)
PlotTimeSeries(var = "soil_moist_QC", datebreak = "3 months", basesize = 30, ymin = 0, ymax = 0.50)

startDay <- "2018-01-01" # min(dat$Date) # "format yyyy-mm-dd
endDay   <- "2018-12-30" # max(dat$Date) # format yyyy-mm-dd
PlotTimeSeries(var = "Exp_Flux", datebreak = "1 months", basesize = 30, ymin = -1, ymax = 15)
PlotTimeSeries(var = "Exp_Flux_QC", datebreak = "1 months", basesize = 30, ymin = -1, ymax = 15)
PlotTimeSeries(var = "soil_temp", datebreak = "1 months", basesize = 30, ymin = -3, ymax = 30)
PlotTimeSeries(var = "soil_temp_QC", datebreak = "1 months", basesize = 30, ymin = -3, ymax = 30)
PlotTimeSeries(var = "soil_moist", datebreak = "1 months", basesize = 30, ymin = 0, ymax = 0.50)
PlotTimeSeries(var = "soil_moist_QC", datebreak = "1 months", basesize = 30, ymin = 0, ymax = 0.50)
