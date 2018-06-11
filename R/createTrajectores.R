library(SimInf)
library(SimInfInference)
library(magrittr)

##' dataGenerate
##'
##' Generate a trajectory
##'
##' Given parameter generate a trajectory.
##' @param theta parameter vector
##' @param binary if the data should pass through the binary filter
##' @return data frame with time and value
dataGenerate <- function(theta = c(0.0075, 0.05, 0.085, 0.1), binary = FALSE, threads = NULL){
    set.seed(0) ## set up simulator
    tspan <- seq(1,4*365, 1)
    obsspan <- 60
    tObs <- seq(100,4*365, obsspan)
    data("nodes", package = "SimInf")
    nObs <- sample(1:length(rownames(nodes)),100)    ## The Simulator.
    Simulator <- SimInfSimulator_sandbox

    if(binary){
        ##for parallell sampling
        cNum <- parallel::detectCores()
        cl <- parallel::makeCluster(getOption("cl.cores", cNum))
        parallel::clusterExport(cl=cl,
                                varlist=c("sample_herd",
                                          "predict_env_sample_SISe",
                                          "pool_prevalence",
                                          "sample_pools"))
    } else
        cl <- NULL

    ## load data that is included the SimInf package
    events <- SimInf::events_SISe()
    u0 <- SimInf::u0_SISe()

    ## levels found usefull
    phiLevel = 0.5
    prevLevel = 0.1

    extraArgsSimulator <- list(tspan = tspan, tObs = tObs,
                               nObs = nObs, runSeed = NULL, threads = threads,
                               includeTrue = FALSE, solver = "ssm", prevLevel = prevLevel,
                               prevHerds = prevLevel, phiLevel = phiLevel, u0 = u0,
                               events = events, binary = binary, cl = cl, nSim = 1)

    ## The Summary statistics
    SummaryStatistics <- NULL
    extraArgsSummaryStatistics <- NULL

    ## The Proposal When only estimating upsilon.
    Proposal <- NULL
    extraArgsProposal <- NULL

    ## The Estimator
    Estimator <- NULL

    thetaTrue <- c(upsilon = theta[1], beta_t1= theta[2], beta_t2 = theta[3], gamma = theta[4])

    extraArgsEstimator <- NULL

    ## Create object!
    infe <- Inference$new(Simulator = Simulator, SummaryStatistics = SummaryStatistics,
                          Proposal = Proposal, Estimator = Estimator,
                          extraArgsSimulator = extraArgsSimulator,
                          extraArgsSummaryStatistics = extraArgsSummaryStatistics,
                          extraArgsEstimator = extraArgsEstimator,
                          extraArgsProposal = extraArgsProposal)

    ## make observation
    obs <- infe$runSimulator(thetaTrue)

    if(binary)
        parallel::stopCluster(cl)

    return(obs[[1]])
}

##' dataAggregate
##'
##' Aggregate the data as a pre processing step before analysing the data
##'
##' @param data the generated observation from the simulator
##' @return aggregated data in data frame
dataAggregate <- function(data, column = "I", qtr = FALSE){
    if(qtr){
        data <- qtrStore(data, "time", column)
        data.mat <- matrix(data[,column], ncol = length(nodes))
    } else
        data.mat <- matrix(data[order(data$node),column], ncol = length(unique(data$node)))

    data.mean <- apply(data.mat, 1, function(x){mean(x, na.rm = TRUE)})
    data.df <- data.frame(time = unique(data$time), sample = data.mean)
    return(data.df)
}

##' dataSave
##'
##' generate CSV file given list of trajectories
##'
##' @param data list of trajectories (data frames)
##' @param filename name of the file
##' @param destination where the file should be saved
##' @return confirmations
dataSave <- function(data, filename, destination){
    output <- paste(destination, filename, sep = "")
    write.csv(data,file = output)
}

##' main function
##'
##' Create 3 trajectories and save as csv file.
main <- function(plot = FALSE){
    set.seed(1)
    ## data 1
    theta1 = c(0.0075, 0.05, 0.085, 0.1)
    obs <- dataGenerate(theta1, threads = 1) %>%
        dataAggregate
    ## data 2
    theta2 = runif(4, 0.98, 1.02)*theta1
    sim1 <- dataGenerate(theta2, threads = 1) %>%
        dataAggregate
    ## data 3
    theta3 = runif(4, 0.93, 1.07)*theta1
    sim2 <- dataGenerate(theta3, threads = 1) %>%
        dataAggregate

    if(plot){
        plot(x=c(0,1500), y = c(0,20), type = "n")
        lines(obs$time, obs$sample, col = "black")
        lines(sim1$time, sim1$sample, col = "red")
        lines(sim2$time, sim2$sample, col = "blue")
    }

    print("data generated")
    ## collect data in a list
    data.list <- list(obs = obs, sim1 = sim1, sim2 = sim2)

    ## save data as csv.
    filename = "genData.csv"
    destination = "~/Gits/SSexploring/DATA/"
    dataSave(data.list, filename, destination)

    print("data saved")

    print("done")
}
