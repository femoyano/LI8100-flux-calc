# plotdat <- filedata[filedata$TIME_ROUND==unique(filedata$TIME_ROUND)[5],]
# plot(plotdat$CO2~plotdat$TIMESTAMPS)
# plot(filedata$CO2~filedata$TIMESTAMPS)
library(ggplot2)
pd <- rawdata[rawdata$TIME >= ymd_hms("2020-07-13 14:00:00") & rawdata$TIME <= ymd_hms("2020-07-13 14:30:00"),]
# pd <- pd[which(pd$TIME == ymd_hms("2020-07-13 00:00:00")):nrow(pd),]
col <- rep(1, nrow(pd))
starts <- seq(90, 3600, 360)
pd$secs <- pd$TIME - floor_date(pd$TIME, unit = 'hour')
for(i in starts) {
  s <- which(pd$secs==i)
  for(j in s) {
    col[j:(j+190)] <- 2 
  }
}
col <- col[1:nrow(pd)]
qplot(x = TIME, y = CO2_dry, data = pd, col = col)
qplot(x = TIME, y = H2O, data = pd, col = col)
qplot(x = TIME, y = CHAMBERTEMP, data = pd, col = col)
qplot(x = TIME, y = BENCHPRESSURE, data = pd, col = col)

