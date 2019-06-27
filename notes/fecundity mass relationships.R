# https://sci-hub.tw/https://onlinelibrary.wiley.com/doi/abs/10.1111/j.1095-8649.1999.tb00716.x

W = 50 # somatic weight in grams 
log.Fecundity = 0.970 * log(W) + 1.303; log.Fecundity
exp(log.Fecundity)

# freshwater
FW.fec <- 0.836 * log(W) + 1.735  
exp(FW.fec)
