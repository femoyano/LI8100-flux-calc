# Script to compare LICOR 81x flux values with those calcualted from .dat streamed files
rm(list=ls())
library(readr)
library(lubridate)

source('cosore-parse-LI8100.R')
source('cosore-parser.R')

# fluxes81x <- `parse_LI-8100A_RAW`('../Automatic_chambers/data/2020/')
# write_csv(x = fluxes81x, path = 'fluxes81x.csv')
fluxes81x <- read_csv('fluxes81x.csv')

source('LI8100-stream-runscript.R')
streamflux <-read_csv('fluxes-stream_01-03.08.20.csv')

varsfluxes81x <- c("Timestamp_begin", "Label", "Port", "CrvFitStatus", "Flux", "R2")
varsstream <- c("FLUX", "RH", "SoilT", "SoilWC", "TIME_FLOOR", "port", "label", "SR_lin", "R2_lin", "RSE_exp", "SR_exp")

fluxes81x <- subset(fluxes81x, select = varsfluxes81x)
streamflux <- subset(streamflux, select = varsstream)

names(fluxes81x) <- c("Timestamp_begin", "Label", "Port", "CrvFitStatus", "Flux81x", "R281x")
names(streamflux) <- c("FluxLIdat", "RH", "SoilT", "SoilWC", "TIME_FLOOR", "Port", "label", "Flux_lin", "R2_lin", "RSE_exp", "Flux_exp")

fluxes81x$TIME_FLOOR <- floor_date(fluxes81x$Timestamp_begin, unit = '30 minutes')

fluxes <- left_join(streamflux, fluxes81x)

ggplot(data = fluxes) +
  geom_line(aes(x = TIME_FLOOR, y = Flux_exp), color = "black") +
  geom_line(aes(x = TIME_FLOOR, y = Flux81x), color = "red") +
  geom_line(aes(x = TIME_FLOOR, y = FluxLIdat), color = "orange") +
  ylim(-5, 10)

png(filename = 'fluxcalc_compare.png', width = 600, height = 600)
ggplot(data = fluxes) +
  geom_point(aes(x = Flux81x, y = Flux_exp), color = "blue", alpha = 1/10) +
  geom_point(aes(x = Flux81x, y = FluxLIdat), color = "red", alpha = 1/10) +
  geom_point(aes(x = Flux81x, y = Flux_lin), color = "violet", alpha = 1/10) +
  geom_smooth(method='lm', aes(x = Flux81x, y = Flux_exp), se = FALSE, color = "blue") +
  geom_smooth(method='lm', aes(x = Flux81x, y = FluxLIdat), se = FALSE, color = "red") +
  geom_smooth(method='lm', aes(x = Flux81x, y = Flux_lin), se = FALSE, color = "violet") +
  geom_abline(intercept = 0, slope = 1, color="black", linetype="dashed", size=0.5) +
  ylim(-2, 10) + xlim(-2, 10) +
  ylab("CO2 flux (variable methods)") + xlab("CO2 flux (.81x files)") +
  ggtitle("LI8100 flux calculations comparison [umol CO2 m-2 s-1]")
dev.off()
