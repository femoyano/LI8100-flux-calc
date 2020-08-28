require(lubridate)

col_names    <- names(read.csv('LI8100-stream-chambersetup.csv', nrows = 0))
chambersetup <- read.csv("LI8100-stream-chambersetup.csv", skip = 2, col.names = col_names, header = FALSE)
configcalc   <- read.csv("LI8100-stream-configcalc.csv", row.names = "name")

list2env(chambersetup, envir = environment())
calcpars <- configcalc$value
names(calcpars) <- row.names(configcalc)

meas_start <- NA
meas_end  <- NA
calc_start <- NA
calc_end <- NA
for(i in order) {
  if(i == 1) {meas_start[i] <- prepurge[i]  + calcpars['closing_time']} else {
    meas_start[i] <- meas_end[i-1] + postpurge[i-1] + prepurge[i] + calcpars['closing_time'] }
  meas_end[i]   <- meas_start[i] + obslength[i]
  calc_start[i] <- meas_start[i] + exclude_start[i]
  calc_end[i]   <- meas_end[i] - exclude_end[i]
}


library(ggplot2)
pd <- rawdata[rawdata$TIME >= ymd_hms("2020-07-13 21:00:00") & rawdata$TIME <= ymd_hms("2020-07-13 22:00:00"),]
# pd <- pd[which(pd$TIME == ymd_hms("2020-07-13 00:00:00")):nrow(pd),]

col <- rep(1, nrow(pd))
pd$secs <- pd$TIME - floor_date(pd$TIME, unit = '30 minutes')
for(i in 1:length(meas_start)) {
  s <- which(pd$secs==meas_start[i])
  for(j in s) {
    col[j:(j+obslength[i])] <- 2 
    col[(j+exclude_start[i]):(j+obslength[i]-exclude_end[i])] <- 3     
  }
}
col <- col[1:nrow(pd)]
qplot(x = TIME, y = CO2_dry, data = pd, col = as.factor(col))
qplot(x = TIME, y = H2O, data = pd, col = col)
qplot(x = TIME, y = CHAMBERTEMP, data = pd, col = col)
qplot(x = TIME, y = BENCHPRESSURE, data = pd, col = col)

# Plot different fits per 
for (i in fluxdata$label) {
  fp <- fluxdata[fluxdata$start_sec==i,]
  plot(fp$TIME_START, fp$SR_nlxb, col="green", type="l", ylim = c(0,max(fp$SR_nlxb)))
  lines(x = fp$TIME_START, y = fp$SR_lin, col="black")
  lines(x = fp$TIME_START, y = fp$SR_nlsLM, col="red")
  lines(x = fp$TIME_START, y = fp$SR_nls, col="blue")
}

# plotdat <- filedata[filedata$TIME_ROUND==unique(filedata$TIME_ROUND)[5],]
# plot(plotdat$CO2~plotdat$TIMESTAMPS)
# plot(filedata$CO2~filedata$TIMESTAMPS)