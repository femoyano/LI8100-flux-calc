FlagTSOutliers <- function(vector, min = NULL, max = NULL, dif = NULL, xsd = NULL, sdmax = NULL, n = 5, exclude = NULL, remove = FALSE) {
  # Fernando Moyano; fmoyano@uni-goettingen.de
  # This function flags outlier values in a given vector according to the following criteria:
  # 1) values are outside the range of min or max (flag = 1)
  # 2) the value itself or all nearby values are missing (flag = 2)
  # 3) value deviates by more than dif from the mean of n*2+1 values centered at the evaluated value (flag = 3)
  # 4) value deviates by more than xsd*sd from the mean of n*2+1 values centered at the evaluated value (flag = 4)
  # 5) standard deviation of n*2+1 values centered at the evaluated value is higher than sdmax (flag = 5)
  # If a vector is passed through the 'exclude' argument, all values where exclude!=0 will be excluded from further calculations.
  # All flagging steps are optional and executed only if a value is passed to the respective function argument.
  # Arguments 'n' determines how many values before and after the evaluated value are used for calculating the mean and sd.
  # If the 'remove' argument is set to TRUE, each step will remove the flagged values from further calculations.
  
  flag <- rep(0, length(vector))
  if(!is.null(exclude)) {
    vector[exclude!=0] <- NA
  }
  if(!is.null(min)) {flag[vector < min] <- 1; if(remove) vector[vector < min] <- NA}
  if(!is.null(max)) {flag[vector > max] <- 1; if(remove) vector[vector > max] <- NA}
  end <- length(vector)
  
  # flag outliers determined by sd
  if(!is.null(dif) | !is.null(xsd)) {
    for(i in 1:end) {
      if(i <= n*2) {
        sd <- sd(vector[1:(n*2)], na.rm = TRUE)
        m <- mean(vector[1:(n*2)], na.rm = TRUE)
      } else if(i >= (end-(n*2))) {
        sd    <- sd(vector[(end-(n*2)):end], na.rm = TRUE)
        m  <- mean(vector[(end-(n*2)):end], na.rm = TRUE)
      } else {
        sd <- sd(vector[(i-(n)):(i+(n))], na.rm = TRUE)
        m <- mean(vector[(i-(n)):(i+(n))], na.rm = TRUE)
      }
      # print(paste("i=", i, " mean=", m, " sd=", sd))
      if(is.na(sd) | is.na(vector[i])) flag[i] <- 2 else {
        if(!is.null(dif))   {if(abs(vector[i]-m) > dif)      flag[i] <- 3}
        if(!is.null(xsd))   {if(abs(vector[i]-m) > (sd*xsd)) flag[i] <- 4}
        if(!is.null(sdmax)) {if(sd > sdmax)                  flag[i] <- 5}
      }
      if(remove & flag[i] != 0) vector[i] <- NA
    }
  }
  return(flag)
}
