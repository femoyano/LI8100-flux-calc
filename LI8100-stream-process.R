##### Process streamed LI-8100 (with LI-8150 multiplexer) data
# Information on the measurement cycles can be found here:
# https://www.licor.com/env/support/LI-8100A/topics/measurement-cycle.html

LI8100_stream_process <- function(rawdata, chambersetup, configcalc) {

  require(lubridate)
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

  cycle_length <- paste(calcpars['cycle_length'], 'minutes')
  rawdata$TIME_FLOOR <- floor_date(rawdata$TIME, cycle_length)
  rawdata$SECS <-  rawdata$TIME-rawdata$TIME_FLOOR
  
  rawdata$start_sec <- NA
  rawdata$calc_flag <- 0
  rawdata$order     <- NA
  rawdata$port <- NA
  rawdata$label <- NA
  rawdata$meas_point <- NA

  for(i in order) {
    rawdata$order      [ rawdata$SECS >= meas_start[i] & rawdata$SECS < meas_end[i] ] <- i      # add order
    rawdata$start_sec  [ rawdata$order==i ] <- meas_start[i] # add time of measurement info
    rawdata$port       [ rawdata$order==i ] <- port[i]
    rawdata$label      [ rawdata$order==i ] <- label[i]
    rawdata$meas_point [ rawdata$order==i ] <- meas_point[i]
    rawdata$calc_flag  [ rawdata$SECS >= calc_start[i] & rawdata$SECS < calc_end[i] ] <- 1                      # add flag for exluding times
  }
  
  rawdata$TIME_START <- rawdata$TIME_FLOOR + rawdata$start_sec
  calcdata <- rawdata[rawdata$calc_flag==1 & !is.na(rawdata$TIME), ]
  calcdata <- subset(calcdata, select = -c(TIMESTAMPS, TIME_FLOOR, calc_flag))
  
  fluxdata <- getfluxes(calcdata, chambersetup, configcalc)
}


getfluxes <- function(calcdata, chambersetup, configcalc) {
  
  list2env(chambersetup, envir = environment())
  calcpars <- configcalc$value
  names(calcpars) <- row.names(configcalc)
  
  require(dplyr)
  
  calcfluxes <- function(df, gr) {
    
    require(minpack.lm)
    
    out <- as.data.frame(lapply(X = df, FUN=mean, na.rm = TRUE))
    ind <- out$order[1]

    ## Flux calculations ----
    # The calculations here follow the steps given in:
    # https://www.licor.com/env/support/LI-8100A/topics/deriving-the-flux-equation.html
    
    V <- chamvolume[ind] + extvolume[ind] + area[ind] * offset_chamsoil[ind]
    S <- area[ind]
    R <- 8.314 # Pa m3 K-1 mol-1
    
    df$t <- as.numeric(df$TIME - gr$TIME_START)
    dfi <- df[1:10,] # Initial measurements for lin fits used to estimate values at chamber closure 
    
    # H2O[mmol mol-1]: chamber water vapor mole fraction. W_0 = value at time of chamber closure.
    W0 <- lm(H2O~t, data = dfi)[['coefficients']][1]
    # BENCHPRESSURE[kPa]: chamber pressure. P0 = value at time of chamber closure.
    P0 <- lm(BENCHPRESSURE~t, data = dfi)[['coefficients']][1]
    # CHAMBERTEMP[degC]: chamber temperature. T0 = value at time of chamber closure.
    T0 <- lm(CHAMBERTEMP~t, data = dfi)[['coefficients']][1]
    # CO2_dry[umol mol-1]: water corrected CO2 mole fraction. C0 = value at time of chamber closure.
    C0 <- lm(CO2_dry~t, data = dfi)[['coefficients']][1]
    
    ### First calculate the flux from a linear fit
    linfit_CO2dry <- lm(CO2_dry ~ t, data = df[1:calcpars['linfit_secs'],]) # Select initial seconds to calculate the linear slope
    dC0_lin <- linfit_CO2dry[['coefficients']][2]
    out$SR_lin <- 10*V*P0*(1-W0/1000) / (R*S*(T0+273.15)) * dC0_lin
    out$R2_lin <- summary(linfit_CO2dry)$r.squared

    ### Then try to fit an exponential
    Cx <- NA
    a <- NA
    t0 <- NA
    out$RSE_exp <- NA
      
    # The base nls function fails in most cases. nlsLM (package minpack.lm) mostly succeeds. 
    expfit_CO2dry <- try(nlsLM(CO2_dry ~ Cx + (C0 - Cx)*exp(-a*(t-t0)), 
                               data = df, start = list(Cx=1000, a=0.0001, t0=0),
                               control = list(maxiter=100)))
    if(inherits(expfit_CO2dry, 'nls')) {
      Cx <- summary(expfit_CO2dry)['coefficients'][[1]]['Cx','Estimate']
      a  <- summary(expfit_CO2dry)['coefficients'][[1]]['a','Estimate']
      t0 <- summary(expfit_CO2dry)['coefficients'][[1]]['t0','Estimate']
      out$RSE_exp <- summary(expfit_CO2dry)[[3]]
    } 

    #   nlxb (pacakge nlsr). Fits successfully but is very slow.
    #   require (nlsr)
    #   expfit_CO2dry <- nlxb(CO2_dry ~ Cx + (C0 - Cx)*exp(-a*(t-t0)), data = df, start = c(Cx=1000, a=0.0001, t0=0))
    #   if(!inherits(expfit_CO2dry, "try-error")) {
    #     Cx <- expfit_CO2dry$coefficients['Cx']
    #     a  <- expfit_CO2dry$coefficients['a']
    #     t0 <- expfit_CO2dry$coefficients['t0']
    #   }

    dC0_exp <- a*(Cx-C0)
    out$SR_exp <- 10*V*P0*(1-W0/1000) / (R*S*(T0+273.15)) * dC0_exp
    
    out$SR <- out$SR_exp
    out$SR[is.na(out$SR)] <- out$SR_lin[is.na(out$SR)] # if an exp fit is missing, use the linear fit value.
    out$label <- label[ind]
    out$TIME_MEAN <- out$TIME
    out$TIME <- NULL
    
    return(out)
  }
  
  fluxes <- calcdata %>%
    group_by(TIME_START) %>%
    group_modify(calcfluxes)
  
  return (fluxes)
}


