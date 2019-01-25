library(RNetLogo)
NLStart("C:\\Program Files\\NetLogo 6.0.4\\app", gui = T, nl.jarname = "netlogo-6.0.4.jar")
# https://www.youtube.com/watch?v=3EmHi0roiM8
#NLLoadModel("C:\\Program Files\\NetLogo 6.0.4\\app\\models\\Sample Models\\Earth Science\\Fire.nlogo") 
#NLCommand("set density",33)
#NLCommand("setup")
#NLDoCommand(10, "go")
#br.trees <- NLReport("burned-trees")
#print(br.trees) 

NLLoadModel("C:\\Users\\Adam Kane\\Documents\\Manuscripts\\Trout migration\\trout-migration-full-time.nlogo")
NLCommand("setup")
NLDoCommand(1000, "go")

vars <- c("who", "g")
agents <- "males"
reporters <- sprintf("map [x -> [%s] of x ] sort %s", vars, agents)
nlogo_ret <- RNetLogo::NLReport(reporters)
df1 <- data.frame(nlogo_ret, stringsAsFactors = FALSE)
names(df1) <- vars
df1

summary(df1$g)
hist(df1$g)

agents <- "females"
reporters <- sprintf("map [x -> [%s] of x ] sort %s", vars, agents)
nlogo_ret <- RNetLogo::NLReport(reporters)
df2 <- data.frame(nlogo_ret, stringsAsFactors = FALSE)
names(df2) <- vars
df2

summary(df2$g)
hist(df2$g)


library(parallel)
processors <- detectCores()
processors

Cl <- makeCluster(processors)
Cl


NLQuit()

# stop cluster
stopCluster(cl)
