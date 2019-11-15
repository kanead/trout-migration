#' Run the trout migration model 
#' The nlrx r package: A next generation framework for reproducible NetLogo model analyses
#' https://besjournals.onlinelibrary.wiley.com/doi/epdf/10.1111/2041-210X.13286
#' https://github.com/ropensci/nlrx

#' load the package
#' install if needed with install.packages("nlrx")
library(nlrx)

#' Defining an nl object
#' this will be computer specific 
my_modelversion<-"trout-migration-full-time-matrix-2019-11-15-nlrx.nlogo"  #Model version used
netlogopath <- file.path("C:/Program Files/NetLogo 6.0.4")  #My laptop
my_modelpath <- file.path(netlogopath, "app/models/Sample Models/Biology/",my_modelversion)

nl <- nl(
  nlversion = "6.0.4",
  nlpath = netlogopath,
  modelpath = my_modelpath,
  jvmmem = 1024
)

#' define where you want the data saved
my_outputpath<-"C:/Users/danay/Documents/TRABAJO/UFZ/Models NetLogo/Sea Trout - Adam  Kane"  #My laptop

outpath <- file.path(my_outputpath)


#' defining an experiment
my_metrics <- c(
  'year'  #year in which data are collected
  ,'count turtles with [anadromous = true] / count turtles' # proportion of anadromous trout
  ,'count turtles with [sex = "male" and anadromous = true] / count turtles with [sex = "male"]'  # proportion of anadromous trout within males
  ,'count turtles with [sex = "female" and anadromous = true] / count turtles with [sex = "female"]'  # proportion of anadromous trout within females
  ,'anadromous-spawners'  # proportion of anadromous trout within spawners
)

my_constants <- list(
    "Check-Stability?" = "true" 
    ,"n-trout" = 3000 
    ,"carryingCapacity" = 3000
    
    ,"mortalityM" = 0.01543
    ,"anad-death-multiplierM" = 1.65
    ,"mortalityF" = 0.01543
    ,"anad-death-multiplierF" = 1.65
    
    ,"res_quality_mean" = 230
    ,"res_quality_sd" = 10
    ,"anad_quality" = 170
    ,"anad_quality_sd" = 0
    
    ,"evolution?" = "true"
    ,"n-loci-sign" = 0
    
    ,"sneaker?" = "true"
    ,"sneaker_radius" = 5
    ,"sneaker_thresh" = 0.9
    ,"sneaker_boost" = 300
    
    ,"female-mate-radius" = 6
    ,"Fec-reduction-resid" = 1
    ,"lifespan" = 416
    
    ,"prop-parasites" = 0
    ,"parasite-load" = 1.4
    ,"paras_quality" = 0.4
  )


#' attaching an experiment
nl@experiment <- experiment(
  expname = "trout_migration",
  outpath = outpath,
  repetition = 1,
  tickmetrics = "true",
  idsetup = "setup",
  idgo = "go",
  runtime = 52 * 500, # the model runs for 500 years
  evalticks=seq(52 * 100,52 * 500,52), # the model will extract data every year after 100 years
  metrics = my_metrics,
  constants = my_constants
)

#' Evaluate if variables and constants are valid:
eval_variables_constants(nl)
nl@simdesign <- simdesign_simple(nl = nl, nseeds = 1)

# Run Simulation
init <- Sys.time()
results <- run_nl_all(nl = nl)
Sys.time() - init #' see how long it takes

#' Check the results
head(results)
tail(results)

#' plot the data
plot(results$`[step]`, results$`count turtles with [anadromous = true] / count turtles`)
