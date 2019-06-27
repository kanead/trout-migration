#!/usr/bin/env Rscript
#' R interface for trout migration model
#' tutorial for RNetLogo
#' https://www.youtube.com/watch?v=3EmHi0roiM8
#' you may need to download 64 bit java if you get an error
#' https://www.java.com/en/download/manual.jsp
#' write one script that produces one dataframe 

## Load libraries:
library(RNetLogo)
library(dplyr)
## Provide access to a copy of the command line arguments supplied when R session is invoked
args <- commandArgs(TRUE)
output_file <- args[1]            # Assign first argument as output

## Define paths to software:
jarname_path <- "C:\\Program Files\\NetLogo 6.0.4\\app"
model_path <- "C:\\Users\\Adam\\Documents\\Science\\Manuscripts\\trout-migration\\trout-migration-full-time-matrix.nlogo"
wd_path <- getwd()
print(wd_path)

#' identify the location of NetLogo
#' this returns an error code but it still works
NLStart(jarname_path,
        gui = FALSE,
        nl.jarname = "netlogo-6.0.4.jar")

#' path to the model on my laptop
NLLoadModel(
  model_path
)

#' change the parameter values ---
#' starting population of trout
NLCommand("set n-trout 100")

#' male freshwater mortality
NLCommand("set mortalityM 1e-05")

#' female freshwater mortality
NLCommand("set mortalityF 1e-05")

#' male marine mortality multiplier
NLCommand("set anad-death-multiplierM 100")

#' female marine mortality multiplier
NLCommand("set anad-death-multiplierF 100")

#' cost of being parasitised multiplier
NLCommand("set parasite-load 2")

#' range that females can see potential mates
NLCommand("set female-mate-radius 2")

#' freshwater carrying capacity
NLCommand("set carryingCapacity 300")

#' proportion of marine patches that have parasites
NLCommand("set prop-parasites 0.1")

#' sneaker tactic by resident males on or off
NLCommand("set sneaker? TRUE")

#' set the threshold proportion of anadramous males
#' around which a resident should find itself before
#' adopting a sneaker tactic
NLCommand("set sneaker_thresh 0.8")

#' set the bump in quality that a sneaker male
#' gets which will affect its chance of being
#' selected
NLCommand("set sneaker_boost 200")

#' mean quality of resident trout
NLCommand("set res_quality_mean 100")

#' SD quality of resident trout
NLCommand("set res_quality_sd 10")

#' mean quality of parasitised trout
NLCommand("set paras_quality_mean 150")

#' SD quality of parasitised trout
NLCommand("set paras_quality_sd 10")

#' mean quality of marine trout
NLCommand("set anad_quality_mean 200")

#' SD quality of marine trout
NLCommand("set anad_quality_sd 10")

#' control the number of loci that have a different
#' sign in males than in females
#' 0 means all loci are the same between sexes
#' 20 means all loci are different between sexes
NLCommand("set n-loci-sign 0")

#' setup the model
NLCommand("setup")

#' set up a reporter to collect data on the genotype of both sexes
vars <- c("ticks", "who", "g" , "sex", "anadromous", "gm_val")
agents <- "turtles"
reporters <- sprintf("map [x -> [%s] of x ] sort %s", vars, agents)
nlogo_ret <- RNetLogo::NLReport(reporters)

#' run the model for x by y ticks and extract the reporters
#' every y ticks
print('Running...')
run <-
  NLDoReport(
    10,
    "repeat 5 [go]",
    c("ticks", reporters),
    as.data.frame = T,
    df.col.names = c("ticks", reporters)
  )

mydata <-
  data.frame(cbind(
    unlist(run$`map [x -> [sex] of x ] sort turtles`),
    unlist(run$`map [x -> [g] of x ] sort turtles`),
    unlist(run$`map [x -> [ticks] of x ] sort turtles`),
    unlist(run$`map [x -> [anadromous] of x ] sort turtles`),
    unlist(run$`map [x -> [who] of x ] sort turtles`)
  ))

#' rename the variables
print("Renaming variables...")
mydata <-
  rename(
    mydata,
    sex = X1,
    g = X2,
    iteration = X3,
    anadromous = X4,
    who = X5
  )
head(mydata)

#' make sure g is classified as numeric
mydata$g <- as.numeric(as.character(mydata$g))
head(mydata)

#' I had to make the folder in the wd_path
output <- paste(wd_path,
                "/",
                output_file,
                sep = "")

## write to file:
print("Writing to file...")
write.table(mydata,
            file = output,
            row.names = FALSE,
            col.names = FALSE,
            sep = "\t",
            quote = FALSE)

print("Complete!")
