# https://sci-hub.tw/https://onlinelibrary.wiley.com/doi/abs/10.1111/j.1095-8649.1999.tb00716.x

W = 50 # somatic weight in grams 
log.Fecundity = 0.970 * log(W) + 1.303; log.Fecundity
exp(log.Fecundity)

# freshwater
FW.fec <- 0.836 * log(W) + 1.735  
exp(FW.fec)

#' http://www.freshwaterlife.org/projects/media/projects/images/1/50094_ca_object_representations_media_163_original.pdf
#' Erriff O'Farrell 1989
# log10(a) = -3.622
a = 0.000238781
b = 2.603
L = seq(200, 700, by = 50) # mm
L
N = a * L ^ b
N
N/50
plot(L,N)

# mean 
2.7514 * log10(L) - 4.0624
10^ (2.7514 * log10(L) - 4.0624)



#https://www.int-res.com/articles/aei2016/8/q008p675.pdf
# Length is in cm
Length = 30
eggs = 60.67 * Length - 1238.49
eggs
