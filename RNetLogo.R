#' R interface for trout migration model 
#' tutorial for RNetLogo
#' https://www.youtube.com/watch?v=3EmHi0roiM8
#' you may need to download 64 bit java if you get an error
#' https://www.java.com/en/download/manual.jsp

#' load the libraries 
library(RNetLogo)
library(ggplot2)
library(tidyverse)

#' identify the location of NetLogo 
NLStart("C:\\Program Files\\NetLogo 6.0.4\\app", gui = T, nl.jarname = "netlogo-6.0.4.jar")

#' path to the model on my desktop
#NLLoadModel("C:\\Users\\Adam Kane\\Documents\\Manuscripts\\Trout migration\\trout-migration-full-time.nlogo")

#' path to the model on my laptop
NLLoadModel("C:\\Users\\Adam\\Documents\\Science\\Manuscripts\\trout-migration\\trout-migration-full-time-DA.nlogo")

#' setup the model 
NLCommand("setup")

#' run it for 1000 ticks 
NLDoCommand(1000, "go")

#' specifiy the variables we won't to collect from the model
vars <- c("who", "g")

#' set up a reporter to collect data on the genotype of the males
agents <- "males"
reporters <- sprintf("map [x -> [%s] of x ] sort %s", vars, agents)
nlogo_ret <- RNetLogo::NLReport(reporters)
df1 <- data.frame(nlogo_ret, stringsAsFactors = FALSE)
names(df1) <- vars
df1
#' examine the values
summary(df1$g)
hist(df1$g)

#' set up a reporter to collect data on the genotype of the females
agents <- "females"
reporters <- sprintf("map [x -> [%s] of x ] sort %s", vars, agents)
nlogo_ret <- RNetLogo::NLReport(reporters)
df2 <- data.frame(nlogo_ret, stringsAsFactors = FALSE)
names(df2) <- vars
df2
#' examine the values
summary(df2$g)
hist(df2$g)

#' run the model for 5 by 1000 ticks and extract the reporters (the genotype)
#' every 1000 ticks
test <- NLDoReport(5, "repeat 1000 [go]", c("ticks",reporters), as.data.frame=T, df.col.names=c("ticks",reporters)) 
print(test) 
class(test)
test$`map [x -> [g] of x ] sort females`

g_female <- test$`map [x -> [g] of x ] sort females`

hist(unlist(g_female[1]))

#' plot individual histograms for each sampling period in base R
for (i in seq_along(g_female)) { 
  hist(g_female[[i]])
}

#' plot box plots for each sampling period using ggplot
p1 <- data.frame(x = unlist(g_female), 
                 grp = rep(letters[1:length(g_female)],times = sapply(g_female,length)))
ggplot(p1,aes(x = grp, y = x)) + geom_boxplot()

#' Plot histograms for each sampling period using ggplot
#' this uses facet wrap to plot individual histograms  
p2 <- data.frame(x = unlist(g_female), 
                 grp = rep(letters[1:length(g_female)],times = sapply(g_female,length)))

ggplot(p2) + 
  geom_histogram(aes(x)) + 
  facet_wrap(~grp)

#' set up a reporter to collect data on the genotype of both sexes
vars <- c("ticks", "who", "g" ,"sex", "anadromous")
agents <- "turtles"
reporters <- sprintf("map [x -> [%s] of x ] sort %s", vars, agents)
nlogo_ret <- RNetLogo::NLReport(reporters)
df3 <- data.frame(nlogo_ret, stringsAsFactors = FALSE)
names(df3) <- vars
df3
#' examine the values, note this combines the values for both sexes
summary(df3$g)
hist(df3$g)

#' run the model for 5 by 1000 ticks and extract the reporters (the genotype)
#' every 1000 ticks
test <- NLDoReport(5, "repeat 1000 [go]", c("ticks",reporters), as.data.frame=T, df.col.names=c("ticks",reporters)) 
print(test) 
class(test)
test$`map [x -> [g] of x ] sort turtles`

mydata <- data.frame(cbind(unlist(test$`map [x -> [sex] of x ] sort turtles`)
,unlist(test$`map [x -> [g] of x ] sort turtles`), unlist(test$`map [x -> [ticks] of x ] sort turtles`),unlist(test$`map [x -> [anadromous] of x ] sort turtles`)
))

#' rename the variables
mydata <- rename(mydata, sex = X1, g = X2, iteration = X3, anadromous = X4)
head(mydata)

#' make sure g is classified as numeric
mydata$g <- as.numeric(as.character(mydata$g))
head(mydata)

#' plot the data
#' note the dot used in place of mydata because 
#' we're using pipes 

#' first for males
filter(mydata, sex == "male") %>% ggplot(.) + 
  geom_histogram(aes(g)) + 
  facet_wrap(~iteration)

#' now for females
filter(mydata, sex == "female") %>% ggplot(.) + 
  geom_histogram(aes(g)) + 
  facet_wrap(~iteration)

#' filter by resident males
filter(mydata, sex == "male", anadromous=="FALSE") %>% ggplot(.) + 
  geom_histogram(aes(g)) + 
  facet_wrap(~iteration)

#' plot individual histograms for each sampling period in base R
for (i in seq_along(g_female)) { 
  hist(g_female[[i]])
}

#' plot box plots for each sampling period using ggplot
p1 <- data.frame(x = unlist(g_female), 
                grp = rep(letters[1:length(g_female)],times = sapply(g_female,length)))
ggplot(p1,aes(x = grp, y = x)) + geom_boxplot()

#' Plot histograms for each sampling period using ggplot
#' this uses facet wrap to plot individual histograms  
p2 <- data.frame(x = unlist(g_female), 
                grp = rep(letters[1:length(g_female)],times = sapply(g_female,length)))

ggplot(p2) + 
  geom_histogram(aes(x)) + 
  facet_wrap(~grp)

##### NetLogo Parallelization  ----

#' Simple example
testfun1 <- function(x) {
  return(x*x)
   }

my.v1 <- 1:10
my.v1.quad <- sapply(my.v1, testfun1)
my.v1.quad 
library(parallel) 

processors <- detectCores()
# create a cluster
cl <- makeCluster(processors)
# call parallel sapply
my.v1.quad.par <- parSapply(cl, my.v1, testfun1)
print(my.v1.quad.par)
stopCluster(cl)

#' NetLogo example
#' use clusters to run multiple versions of the model

#'  To parallelize RNetLogo we need this initialization to be
#'  done for every processor, because they are independent from each 
#'  other (which is a very important property, because, for example, 
#'  random processes in parallel simulations should not be influenced 
#'  by each other).
#'  
#'  Therefore, it makes sence to put the initialization, the simulation, 
#'  and the quiting process into separate functions. These functions can 
#'  look like the following (if you want to test these, don't forget to 
#'  adapt the paths appropriate):

library(rJava)
library(RNetLogo)
#setwd("C:\\Program Files\\NetLogo 6.0.4\\app") #path where netlogo.jar file is stored - ymmv

# load the parallel package
library(parallel)

# detect the number of cores available
processors <- detectCores()
processors

# create a cluster
cl <- makeCluster(processors)
cl


### When using parallelization, everything has to be done for every processor separately.
# Therefore, make functions:

# the initialization function
prepro <- function(dummy, gui, nl.path, model.path) {
  library(RNetLogo)
  NLStart(nl.path, gui=gui,nl.jarname = "netlogo-6.0.4.jar")
  NLLoadModel(model.path)
}


simfun <- function(density) {
  
  sim <- function(density) {
    NLCommand("set density ", density, "setup")
    NLDoCommandWhile("any? turtles", "go");
    ret <- NLReport("(burned-trees / initial-trees) * 100")
    return(ret)
  }
  
  lapply(density, function(x) replicate(20, sim(x)))
}



# the quit function
postpro <- function(x) {
  NLQuit()
}


### Start Cluster
#run the initialization function in each processor, which will open as many NetLogo windows as we have processors


# set variables for the start up process
# adapt path appropriate (or set an environment variable NETLOGO_PATH)
gui <- TRUE
nl.path <- "C:\\Program Files\\NetLogo 6.0.4\\app"
model.path <- "models\\Sample Models\\Earth Science\\Fire.nlogo"


# load NetLogo in each processor/core
invisible(parLapply(cl, 
                    1:processors, 
                    prepro, 
                    gui=gui,
                    nl.path=nl.path, 
                    model.path=model.path)
)


### Run over these 11 densities
d <- seq(55, 65, 1)
result.par <- parSapply(cl, d, simfun) # runs the simfunfunction over  clusters varying by density
result.par

burned.df <- data.frame(density=rep(55:65,each=20), pctburned=unlist(result.par))

library(ggplot2)
ggplot(burned.df, aes(x=factor(density), y=pctburned)) + geom_boxplot(alpha=.1) + geom_point()

#' can quit out of NetLogo with NLQuit()
#' note that you cannot reopen NetLogo once you do this
#' you have to restart R to get it going again

# Quit NetLogo in each processor/core
invisible(parLapply(cl, 1:processors, postpro))

# stop cluster
stopCluster(cl)

