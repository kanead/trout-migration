#' R interface for trout migration model
#' tutorial for RNetLogo
#' https://www.youtube.com/watch?v=3EmHi0roiM8
#' you may need to download 64 bit java if you get an error
#' https://www.java.com/en/download/manual.jsp
#' write one script that produces one dataframe 

#' load the libraries
library(RNetLogo)
library(ggplot2)
library(tidyverse)
library(Hmisc) # used for plotting

#' identify the location of NetLogo
#' this returns an error code but it still works
NLStart("C:\\Program Files\\NetLogo 6.0.4\\app",
        gui = T,
        nl.jarname = "netlogo-6.0.4.jar")

#' path to the model on my desktop
NLLoadModel(
  "C:\\Users\\Adam Kane\\Documents\\Manuscripts\\Trout migration\\trout-migration\\trout-migration-full-time-matrix.nlogo"
)

#' path to the model on my laptop
NLLoadModel(
  "C:\\Users\\Adam\\Documents\\Science\\Manuscripts\\trout-migration\\trout-migration-full-time-matrix.nlogo"
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

#' test the model
#' run it for 100 ticks
#' NLDoCommand(100, "go")
#' setup the model again after the test
#' NLCommand("setup")

#' set up a reporter to collect data on the genotype of both sexes
vars <- c("ticks", "who", "g" , "sex", "anadromous", "gm_val")
agents <- "turtles"
reporters <- sprintf("map [x -> [%s] of x ] sort %s", vars, agents)
nlogo_ret <- RNetLogo::NLReport(reporters)

#' run the model for x by y ticks and extract the reporters
#' every y ticks
run <-
  NLDoReport(
    10,
    "repeat 100 [go]",
    c("ticks", reporters),
    as.data.frame = T,
    df.col.names = c("ticks", reporters)
  )

print(run)
class(run)
run$`map [x -> [g] of x ] sort turtles`

mydata <-
  data.frame(cbind(
    unlist(run$`map [x -> [sex] of x ] sort turtles`),
    unlist(run$`map [x -> [g] of x ] sort turtles`),
    unlist(run$`map [x -> [ticks] of x ] sort turtles`),
    unlist(run$`map [x -> [anadromous] of x ] sort turtles`),
    unlist(run$`map [x -> [who] of x ] sort turtles`)
  ))

#' rename the variables
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


#' iteration should be treated as a factor for plotting so we need to make sure the order of levels makes sense
levels(mydata$iteration)
mydata$iteration <-
  factor(mydata$iteration,
         levels = c(1000, 2000, 3000, 4000, 5000, 6000, 7000, 8000, 9000, 10000))

#' plot the data
#' note the dot used in place of mydata because
#' we're using pipes
#'

#' first for males
filter(mydata, sex == "male") %>% ggplot(.) +
  geom_histogram(aes(g)) +
  #' class of iteration needs to be changed so that it plot in numerical order
  facet_wrap(~ reorder(iteration, sort(as.numeric(iteration))))

#' now for females
filter(mydata, sex == "female") %>% ggplot(.) +
  geom_histogram(aes(g)) +
  facet_wrap(~ iteration)

#' filter by resident males
filter(mydata, sex == "male", anadromous == "FALSE") %>% ggplot(.) +
  geom_histogram(aes(g)) +
  #' class of iteration needs to be changed so that it plot in numerical order
  facet_wrap( ~ reorder(iteration, sort(as.numeric(iteration))))

#' boxplots
mydata %>% ggplot(.) +
  geom_boxplot(aes(x = reorder(iteration, sort(
    as.numeric(iteration)
  )), y = g))

#' line plot
ggplot(mydata, aes(as.numeric(as.character(sort(
  iteration
))), g, col = sex)) +  stat_summary(geom = "line", fun.y = mean) +
  stat_summary(geom = "ribbon",
               fun.data = mean_cl_normal,
               alpha = 0.3)

#' check the summary stats
mydata %>% group_by(iteration, sex) %>% summarise(mean = mean(g))

#' can extract the allele frequencies
alleleFreq <-
  data.frame(cbind(unlist(run$`map [x -> [gm_val] of x ] sort turtles`)))
head(alleleFreq)

#' rename
alleleFreq <-
  rename(alleleFreq, gm_val = cbind.unlist.run..map..x.....gm_val..of.x...sort.turtles...)
head(alleleFreq)
tail(alleleFreq, 21)
length(alleleFreq$gm_val) / 21

#' extract them for each fish
#' check this again to make sure it matches up!
lst <-
  split(alleleFreq$gm_val, (seq_along(alleleFreq$gm_val) - 1) %% 21 + 1)
do.call(cbind, lapply(lst, "length<-", max(lengths(lst))))

#' stick them all together with the rest of the data
cbind(mydata, lst)
mydata <- cbind(mydata, lst)
tail(mydata)



#######' run the model multiple times on the same core ----
#' this samples the model once every 520 weeks ~ 10 years
#' the function for the model 
simfun <- function(carryingCapacity) {
  NLCommand("set carryingCapacity ", carryingCapacity, "setup")
  #' the reporters for the model 
  vars <- c("ticks", "who", "g" , "sex", "gm_val")
  agents <- "turtles"
  reporters <- sprintf("map [x -> [%s] of x ] sort %s", vars, agents)
  nlogo_ret <- RNetLogo::NLReport(reporters)
  run <-
    NLDoReport(
      10,
      "repeat 520 [go]",
      c("ticks", reporters),
      as.data.frame = T,
      df.col.names = c("ticks", reporters)
    )
}

#' Replicate the simulation
rep.sim <- function(carryingCapacity, rep) {
  lapply(carryingCapacity, function(x) replicate(rep, simfun(x)))
}

#' will take about 10 minutes !
K <- c(300) #' carrying capacity 
res <- rep.sim(K, 3)  #' replicate sim 5 times for each K

#' pull out the data for each run from the list columns 
res1<-res[[1]][,1]
res2<-res[[1]][,2]
res3<-res[[1]][,3]
res4<-res[[1]][,4]
res5<-res[[1]][,5]

test<-select()

#' transform each run into a dataframe 
mydata1 <-
  data.frame(cbind(
    unlist(res1$`map [x -> [sex] of x ] sort turtles`),
    unlist(res1$`map [x -> [g] of x ] sort turtles`),
    unlist(res1$`map [x -> [ticks] of x ] sort turtles`),
    unlist(res1$`map [x -> [who] of x ] sort turtles`)
  ))

mydata2 <-
  data.frame(cbind(
    unlist(res2$`map [x -> [sex] of x ] sort turtles`),
    unlist(res2$`map [x -> [g] of x ] sort turtles`),
    unlist(res2$`map [x -> [ticks] of x ] sort turtles`),
    unlist(res2$`map [x -> [who] of x ] sort turtles`)
  ))


mydata3 <-
  data.frame(cbind(
    unlist(res3$`map [x -> [sex] of x ] sort turtles`),
    unlist(res3$`map [x -> [g] of x ] sort turtles`),
    unlist(res3$`map [x -> [ticks] of x ] sort turtles`),
    unlist(res3$`map [x -> [who] of x ] sort turtles`)
  ))


mydata4 <-
  data.frame(cbind(
    unlist(res4$`map [x -> [sex] of x ] sort turtles`),
    unlist(res4$`map [x -> [g] of x ] sort turtles`),
    unlist(res4$`map [x -> [ticks] of x ] sort turtles`),
    unlist(res4$`map [x -> [who] of x ] sort turtles`)
  ))


mydata5 <-
  data.frame(cbind(
    unlist(res5$`map [x -> [sex] of x ] sort turtles`),
    unlist(res5$`map [x -> [g] of x ] sort turtles`),
    unlist(res5$`map [x -> [ticks] of x ] sort turtles`),
    unlist(res5$`map [x -> [who] of x ] sort turtles`)
  ))

#' rename the variables
mydata1 <-
  rename(
    mydata1,
    sex = X1,
    g = X2,
    iteration = X3,
    who = X4
  )

#' make sure g is classified as numeric
mydata1$g <- as.numeric(as.character(mydata1$g))
head(mydata1)

#' rename the variables
mydata2 <-
  rename(
    mydata2,
    sex = X1,
    g = X2,
    iteration = X3,
    who = X4
  )

#' make sure g is classified as numeric
mydata2$g <- as.numeric(as.character(mydata2$g))
head(mydata2)

#' rename the variables
mydata3 <-
  rename(
    mydata3,
    sex = X1,
    g = X2,
    iteration = X3,
    who = X4
  )

#' make sure g is classified as numeric
mydata3$g <- as.numeric(as.character(mydata3$g))
head(mydata3)

#' rename the variables
mydata4 <-
  rename(
    mydata4,
    sex = X1,
    g = X2,
    iteration = X3,
    who = X4
  )

#' make sure g is classified as numeric
mydata4$g <- as.numeric(as.character(mydata4$g))
head(mydata4)

#' rename the variables
mydata5 <-
  rename(
    mydata5,
    sex = X1,
    g = X2,
    iteration = X3,
    who = X4
  )

#' make sure g is classified as numeric
mydata5$g <- as.numeric(as.character(mydata5$g))
head(mydata5)

#' combine the data frames 
library(gdata)
all_data<-combine(mydata1,mydata2,mydata3,mydata4,mydata5)

#' iteration needs to be ordered properly 
all_data$iteration <-
  factor(all_data$iteration,
         levels = c(3650, 7300, 10950, 14600, 18250, 21900, 25550, 29200, 32850, 36500))

#' plot a smooth of mean genetic value g for each run over time
#' do a separate plot for males and females 
all_data %>% filter(sex == "male") %>%
ggplot(., aes(as.numeric(iteration), g, colour = source)) +
  geom_smooth(se = T,alpha=0.2) + ggtitle("starting pop 100: males marine mortality")

all_data %>% filter(sex == "female") %>%
  ggplot(., aes(as.numeric(iteration), g, colour = source)) +
  geom_smooth(se = T,alpha=0.2) + ggtitle("starting pop 100: females marine mortality")

#' compare the last run of the model
#' with the last dataframe as a check
mydata5 %>% filter(iteration == 36500) %>%
  group_by(sex) %>%
  dplyr::summarize(Length = length(sex))

#' plot the variance of g over time
all_data %>% filter(sex == "male") %>% group_by(iteration, source) %>% summarise(var = var(g)) %>%  ggplot(., aes(as.numeric(iteration), var, colour = source)) +
  geom_line() + ggtitle("starting pop 100: males")

all_data %>% filter(sex == "female") %>% group_by(iteration, source) %>% summarise(var = var(g)) %>%  ggplot(., aes(as.numeric(iteration), var, colour = source)) +
  geom_line() + ggtitle("starting pop 100: females")

#' export the data
#' desktop
write.csv(all_data, file = "C:\\Users\\Adam Kane\\Documents\\Manuscripts\\Trout migration\\trout-migration\\baseline_run_100.csv", row.names = F)

#' laptop
write.csv(all_data, file = "C:\\Users\\Adam\\Documents\\Science\\Manuscripts\\trout-migration\\marine_mort_100_100.csv", row.names = F)


#' can load in previously saved data 
#' desktop
mydata <- read.csv(file = "C:\\Users\\Adam Kane\\Documents\\Manuscripts\\Trout migration\\trout-migration\\baseline_run_100.csv", header = TRUE)

#' laptop
mydata <- read.csv(file = "C:\\Users\\Adam\\Documents\\Science\\Manuscripts\\trout-migration\\baseline_run_100.csv", header = TRUE)

#' and plot it 
mydata %>% filter(sex == "male") %>% group_by(iteration, source) %>% summarise(var = var(g)) %>%  ggplot(., aes(as.numeric(iteration), var, colour = source)) +
  geom_line() + ggtitle("starting pop 100: males")

mydata %>% filter(sex == "female") %>% group_by(iteration, source) %>% summarise(var = var(g)) %>%  ggplot(., aes(as.numeric(iteration), var, colour = source)) +
  geom_line() + ggtitle("starting pop 100: females")

#' clean the code more efficiently 
#' can convert the whole list into a data frame 
#' where each column is an iteration of the model
test <- as.data.frame(res)

#' combine the data frames 
test_bind <- bind_rows(test$X1,test$X2,test$X3, .id = "id")

test_bind <-  data.frame(cbind(
    unlist(test_bind$`map [x -> [sex] of x ] sort turtles`),
    unlist(test_bind$`map [x -> [g] of x ] sort turtles`),
    unlist(test_bind$`map [x -> [ticks] of x ] sort turtles`),
    unlist(test_bind$`map [x -> [who] of x ] sort turtles`)
  ))

names(test_bind)

#' rename the variables
test_bind <-
  rename(
    test_bind,
    sex = X1,
    g = X2,
    iteration = X3,
    who = X4
  )

head(test_bind)

str(test, list.len = 2)


example <- bind_rows(test, .id = "column_label")


test_bind <- select(test_bind, id, iteration, g, sex, who)
test_bind$g <- as.numeric(test_bind$g)
mean(test_bind$g)
##### NetLogo Parallelization  ----

#' Simple example
testfun1 <- function(x) {
  return(x * x)
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
  NLStart(nl.path, gui = gui, nl.jarname = "netlogo-6.0.4.jar")
  NLLoadModel(model.path)
}


simfun <- function(density) {
  sim <- function(density) {
    NLCommand("set density ", density, "setup")
    NLDoCommandWhile("any? turtles", "go")
    
    ret <- NLReport("(burned-trees / initial-trees) * 100")
    return(ret)
  }
  
  lapply(density, function(x)
    replicate(20, sim(x)))
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
invisible(
  parLapply(
    cl,
    1:processors,
    prepro,
    gui = gui,
    nl.path = nl.path,
    model.path = model.path
  )
)


### Run over these 11 densities
d <- seq(55, 65, 1)
result.par <-
  parSapply(cl, d, simfun) # runs the simfunfunction over  clusters varying by density
result.par

burned.df <-
  data.frame(density = rep(55:65, each = 20),
             pctburned = unlist(result.par))

library(ggplot2)
ggplot(burned.df, aes(x = factor(density), y = pctburned)) + geom_boxplot(alpha = .1) + geom_point()

#' can quit out of NetLogo with NLQuit()
#' note that you cannot reopen NetLogo once you do this
#' you have to restart R to get it going again

# Quit NetLogo in each processor/core
invisible(parLapply(cl, 1:processors, postpro))

# stop cluster
stopCluster(cl)

#'----
#' do the same for the trout model
#' 
#' load the libraries
#' load the parallel package
library(parallel)
library(RNetLogo)

# detect the number of cores available
processors <- detectCores()
processors

# create a cluster
cl <- makeCluster(processors)
cl

# the initialization function
prepro <- function(dummy, gui, nl.path, model.path) {
  library(RNetLogo)
  NLStart(nl.path, gui = gui, nl.jarname = "netlogo-6.0.4.jar")
  NLLoadModel(model.path)
}


#' the function for the model 
simfun <- function(carryingCapacity) {
  NLCommand("set carryingCapacity ", carryingCapacity, "setup")
  #' the reporters for the model 
  vars <- c("ticks", "who", "g" , "sex", "anadromous", "gm_val")
  agents <- "turtles"
  reporters <- sprintf("map [x -> [%s] of x ] sort %s", vars, agents)
  nlogo_ret <- RNetLogo::NLReport(reporters)
  run <-
    NLDoReport(
      2,
      "repeat 1000 [go]",
      c("ticks", reporters),
      as.data.frame = T,
      df.col.names = c("ticks", reporters)
    )
}

# the quit function
postpro <- function(x) {
  NLQuit()
}


# set variables for the start up process
# adapt path appropriate (or set an environment variable NETLOGO_PATH)
gui <- TRUE
nl.path <- "C:\\Program Files\\NetLogo 6.0.4\\app"
model.path <-
  "C:\\Users\\Adam Kane\\Documents\\Manuscripts\\Trout migration\\trout-migration\\trout-migration-full-time-matrix.nlogo"

# load NetLogo in each processor/core
invisible(
  parLapply(
    cl,
    1:processors,
    prepro,
    gui = gui,
    nl.path = nl.path,
    model.path = model.path
  )
)
#' the number of 1000 ticks simulations we want to run
#' sampling takes place every 1000th tick
slice <- 10
print(slice)

result.par <- parSapply(cl, slice, simfun)

# Quit NetLogo in each processor/core
invisible(parLapply(cl, 1:processors, postpro))

# stop cluster
stopCluster(cl)



#' matrix multiplication for genetic architecture
#' weights matrix
WM <- matrix(
  c(
    0.9280339,
    0.8612468,
    0.7992662,
    0.7417461,
    0.6883655,
    0.6388265,
    0.5928526,
    0.5501873,
    0.5105924,
    0.4738471,
    0.4397461,
    0.4080993,
    0.3787300,
    0.3514742,
    0.3261800,
    0.3027061,
    0.2809215,
    0.2607046,
    0.2419427,
    0.2245310,
    0
  ),
  ncol = 21
)
dim(WM)

#' genotype matrix
GM <- matrix(sample(0:2, size = 21, replace = T), ncol = 21)
dim(GM)

#' transpose of weights matrix
WMt <- t(WM)

#' multiply genotype matrix by transpose of weights matrix
#' this produces the genetic value
GM %*% WMt

#' extract data more neatly
NLCommand("setup")

reporters <- c("[who] of turtles", "[g] of turtles" , "[sex] of turtles", "[gm_val] of turtles")
model_run <- NLDoReport(
  10,
  "repeat 100 [go]",
  reporter = c("ticks", reporters),
  as.data.frame = TRUE,
  df.col.names = c("tick", reporters)
)

mydata <-
  data.frame(cbind(
    unlist(model_run$`[who] of turtles`),
    unlist(model_run$`[g] of turtles`),
    unlist(model_run$`[sex] of turtles`)
  ))



c(NLReport(c("ticks",
             nrow(
               unique(NLGetAgentSet("who", "g", "gm_val", "sex"))
             ))))

model_run <- NLDoReport(
  10,
  "repeat 100 [go]",
  reporter = (c("ticks",
               NLGetAgentSet("who", "g", "gm_val", "sex"),"turtles")
                ))

test<-do.call(rbind.data.frame, res)

