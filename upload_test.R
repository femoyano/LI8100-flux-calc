# setwd("/home/lukas/test/Influx_upload_test/"); source("upload_test.R")


library(influxR)

tags <- "station=tower,height=45,unit=g_kg-1,level=1,version=test"
# tags <- "station=tower,height=45,unit=g_kg-1,level=1"

# system.time(upload_dir(path = "data_no_na", pattern = ".dat", host = "134.76.19.175", db = "db_test", measurement = "meteo_test_01", tags = tags, timestamp = 1, format = "%Y-%m-%d %H:%M:%S", tz = "Etc/GMT-1"))

counter <- 0

while(TRUE){
  system.time(upload_dir(path = "data_no_na", pattern = ".dat", host = "134.76.19.175", db = "db_test", measurement = "meteo_test_02", tags = tags, timestamp = 1, format = "%Y-%m-%d %H:%M:%S", tz = "Etc/GMT-1"))
  print(paste("This is upload number:", counter))
  counter <- counter + 1
}