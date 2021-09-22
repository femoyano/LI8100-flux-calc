setwd("C:/Users/ftiedem/Desktop/Bearbeitung/ICOS_chambers")

header <- c('Type', 'Etime',	'Date', 'Time',	'Tcham',	'Pressure',	'H2O',	'CO2',	'Cdry',	'Tbench',
            'V1',	 'rH', 'Tsoil', 'V4', 'LATITUDE', 'LONGITUDE', 'STATUS', 'SPEED', 'COURSE', 'RH',
            'Tboard', 'Vin',	'CO2ABS',	'H2OABS',	'Hour',	'DOY',	'RAWCO2',	'RAWCO2REF',	'RAWH2O',
            'RAWH2OREF', 'Annotation')
head.flux <- c('chamber', 'CrvFitStatus', 'Exp_Flux', 'Exp_FluxCV', 'Exp_dCdry/dt', 'Exp_R2',
               'Exp_SSN', 'Exp_SE', 'Exp_a', 'Exp_Co', 'Exp_Cx', 'Exp_t0', 'Exp_Iter',
               'Exp_MaxIter', 'Lin_Flux', 'Lin_FluxCV', 'Lin_dCdry/dt', 'Lin_R2', 'Lin_SSN',
               'Lin_SE', 'Crv_Domain', 'Crv_', 'Dead')
chamber.names <- c('81N-0116', '81N-2367', '81N-2368', '81N-2369', '81N-2370')


files <- list.files(path = getwd(), pattern = ".81x")

for(i in files){
  chamber.count <- c(0, 0, 0, 0, 0)
  raw <- read.table(i, col.names = header, fill = TRUE)
  end.raw <- dim(raw)
  
  chamber.change <- c(1, which(raw[,1] == "TimeClosing:") + 1)
  dim <- length(chamber.change)
  index <- 1
  while(index < dim){
    chamber.ident <- raw[chamber.change[index] + 8, 2]
    raw.name <- sprintf('raw_%s', chamber.ident)
    raw.data <- raw[(chamber.change[index] + 31) : (chamber.change[index + 1] - 24),]
    used.fit <- as.character(raw[(chamber.change[index + 1] - 23), 2])
    exp.flux <- as.numeric(as.character(raw[(chamber.change[index + 1] - 22), 2]))
    exp.flux.cv <- as.numeric(as.character(raw[(chamber.change[index + 1] - 21), 2]))
    lin.flux <- as.numeric(as.character(raw[(chamber.change[index + 1] - 10), 2]))
    lin.flux.cv <- as.numeric(as.character(raw[(chamber.change[index + 1] - 9), 2]))
    end <- dim(raw.data)
    temp <- round(mean(as.numeric(as.character(raw.data[(5:(end[1]-5)),5]))), 2)
    press <- round(mean(as.numeric(as.character(raw.data[(5:(end[1]-5)),6]))), 2)
    if(index == 1){
      raw.all <- cbind(raw.data[1,], raw.data[1,], raw.data[1,], raw.data[1,], raw.data[1,])
      raw.all <- raw.all[-1,]
      summary <- data.frame('chamber.ID' = as.character(chamber.ident), raw.data[end[1], 3:4],temp,
                            press, used.fit, exp.flux, exp.flux.cv, lin.flux, lin.flux.cv, raw.data[end[1]-1, 12:13])
    }else{
      summ <- data.frame('chamber.ID' = as.character(chamber.ident), raw.data[end[1], 3:4],temp,
                         press, used.fit, exp.flux, exp.flux.cv, lin.flux, lin.flux.cv, raw.data[end[1]-1, 12:13])
      summary <- rbind(summary, summ)
      }
    raw.all[(chamber.count[which(chamber.names[] == chamber.ident)] + 1) : 
            (chamber.count[which(chamber.names[] == chamber.ident)] + end[1]),
            (which(chamber.names[] == chamber.ident) * 31 - 30):
            (which(chamber.names[] == chamber.ident) * 31)]  <- as.data.frame(raw.data,
                                                        row.names = NULL, stringsAsFactors = FALSE)
    raw.all[(chamber.count[which(chamber.names[] == chamber.ident)] + 1) : 
            (chamber.count[which(chamber.names[] == chamber.ident)] + end[1]),
            (which(chamber.names[] == chamber.ident) * 31 - 28): 
            (which(chamber.names[] == chamber.ident) * 31 - 27)]     <- raw.data[,3:4]
    chamber.count[which(chamber.names[] == chamber.ident)] <- chamber.count[
      which(chamber.names[] == chamber.ident)] + end[1]
    

    
    index <- index + 1
  }
  chamber.5m <- raw.all[,1:31]
  chamber.4m <- raw.all[,32:62]
  chamber.3m <- raw.all[,63:93]
  chamber.2m <- raw.all[,94:124]
  chamber.1m <- raw.all[,125:155]
  
  name.prep <- strsplit(i, split = ".81x")

  write.table(raw.all[,1:31], sprintf("%s_5m.raw", name.prep[1]), row.names = FALSE)
  write.table(raw.all[,32:62], sprintf("%s_4m.raw", name.prep[1]), row.names = FALSE)
  write.table(raw.all[,63:93], sprintf("%s_3m.raw", name.prep[1]), row.names = FALSE)
  write.table(raw.all[,94:124], sprintf("%s_2m.raw", name.prep[1]), row.names = FALSE)
  write.table(raw.all[,125:155], sprintf("%s_1m.raw", name.prep[1]), row.names = FALSE)
  
  write.table(summary, sprintf("%s_summary.raw", name.prep[1]), row.names = FALSE)
}



