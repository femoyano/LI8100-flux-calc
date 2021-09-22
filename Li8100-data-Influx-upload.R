#### Uploading of Licor-8100 data to Influx ####

## User settings
setwd("/home/fernando/Documents/Work/Group_Tasks/SR-data-processing/processed/")
file <- "SR-Li8100-Hainich-v1-20170101-20171128.csv"
database <- "db_Hainich"  # an existing database in the InfluxDB
measurement <- "Licor8100_Hainich" #  The measurement group (existing or not) inside the database
version <- 1  # data version

### --------------
dat_all <- read.csv(file)
library(influxR)

## Split the data into different chambers and upload to database
for(i in unique(dat_all$Port)) {
  dat <- dat_all[dat_all$Port==i,]
  Port <- i
  Label <- dat$Label[1]
  # date <- as.POSIXct(x = dat$Date, format = '%Y-%m-%d %H:%M:%S', tz = "Etc/GMT-1")
  date <- dat$Date
  dat$Port <- NULL; dat$Label <- NULL; dat$Date <- NULL
  tags <- paste0('Label=', Label, ',Port=', Port,  ',version=', version)
  influx_write(host =  "134.76.19.175", db = database, tags = tags, dataframe = dat, 
               measurement = measurement, timestamp = date, format = '%Y-%m-%d %H:%M:%S', tz = "Etc/GMT-1")
}
