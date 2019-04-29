#' Mortality rates
#' https://stats.stackexchange.com/questions/289462/converting-annual-to-daily-mortality-rate
#' annual mortality rate is given as 3.082%
amr <- 0.03082
#' what is the daily mortality rate?
1 - (1 - amr)^(1/365)
#' or 
1 - exp(1/365 * log (1-amr))

#' annual mortality rate is given as 10%
amr <- 0.1
#' what is the daily mortality rate?
1 - (1 - amr)^(1/365)
#' or 
1 - exp(1/365 * log (1-amr))
