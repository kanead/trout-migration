#' Run the trout migration model 
#' The nlrx r package: A next generation framework for reproducible NetLogo model analyses
#' https://besjournals.onlinelibrary.wiley.com/doi/epdf/10.1111/2041-210X.13286
#' https://github.com/ropensci/nlrx

#' load the package
#' install if needed with install.packages("nlrx")
library(nlrx)

#' Defining an nl object
#' this will be computer specific 
#' laptop version
nl <- nl(
  nlversion = "6.0.4",
  nlpath = "C:/Program Files/NetLogo 6.0.4/",
  modelpath = "C:/Program Files/NetLogo 6.0.4/app/models/Sample Models/Biology/trout-migration-full-time-matrix-2019-10-26-NewLifeHistory-NewTime.nlogo",
  jvmmem = 1024
)

#' define where you want the data saved
outpath <-
  file.path("C:/Users/Adam/Documents/Science/Methods & Stats/nlrx package")


#' desktop version
nl <- nl(
  nlversion = "6.0.4",
  nlpath = "C:/Program Files/NetLogo 6.0.4/",
  modelpath = "C:/Program Files/NetLogo 6.0.4/app/models/Sample Models/Biology/trout-migration-full-time-matrix-2019-10-26-NewLifeHistory-NewTime.nlogo",
  jvmmem = 1024
)

#' define where you want the data saved
outpath <-
  file.path("C:/Users/Adam Kane/Documents/Manuscripts/Trout migration/trout-migration")


#' attaching an experiment
nl@experiment <- experiment(
  expname = "trout_migration",
  outpath = outpath,
  repetition = 1,
  tickmetrics = "true",
  idsetup = "setup",
  idgo = "go",
  runtime = 100, #' the model runs for 100 ticks
  evalticks=seq(1,100,10), #' the model will extract data every 10 ticks
  metrics = c(
    "count turtles with [color = red]" #' count the males
  ),
  constants = list(
    "n-trout" = 3000, #' set the starting number of trout
    "Check-Stability?" = "false" #' turn this off for the time  being
  )
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
plot(results$`[step]`, results$`count turtles with [color = red]`)
