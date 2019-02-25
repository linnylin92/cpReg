rm(list=ls())
library(simulation)
library(cpReg)

paramMat <- as.matrix(expand.grid(round(exp(seq(log(100), log(1000), length.out = 10))), c(1,2),
                                  1/2))
colnames(paramMat) <- c("n", "X_type", "d/n")

X_type_vec <- c("identity", "toeplitz", "equicorrelation")
true_partition <- c(0,0.3,0.7,1)

#############

create_coef <- function(vec, full = F){
  d <- vec["d/n"]*vec["n"]
  beta1 <- c(rep(1, 2), rep(0, d-2))
  beta2 <- c(rep(0, d-2), rep(1, 2))
  lis <- list(beta1 = beta1, beta2 = beta2)

  if(!full){
    lis
  } else {
    mat <- matrix(0, nrow = vec["n"], ncol = vec["d"])
    idx <- round(true_partition*vec["n"])
    for(i in 1:(length(idx)-1)){
      zz <- i %% 2; if(zz == 0) zz <- 2
      mat[(idx[i]+1):idx[i+1],] <- rep(lis[[zz]], each = idx[i+1]-idx[i])
    }
    mat
  }
}

rule <- function(vec){
  lis <- create_coef(vec, full = F)

  cpReg::create_data(list(lis$beta1, lis$beta2, lis$beta1), round(true_partition*vec["n"]),
              cov_type = X_type_vec[vec["X_type"]])
}

criterion <- function(dat, vec, y){
  lambda <- cpReg::oracle_tune_lambda(dat$X, dat$y, true_partition)
  tau <- cpReg::oracle_tune_tau(dat$X, dat$y, lambda, true_partition)

  res <- cpReg::high_dim_feasible_estimate(dat$X, dat$y, lambda = lambda, tau = tau,
                                    verbose = F)
  beta_mat <- cpReg::unravel(res)
  true_beta <- create_coef(vec, full = T)

  beta_error <- sum(sapply(1:vec["n"], function(x){.l2norm(beta_mat[x,] - true_beta[x,])^2}))/vec["n"]
  haus <- cpReg::hausdorff(res$partition, round(true_partition*vec["n"]))

  list(beta_error = beta_error, haus = haus, partition = res$partition,
       lambda = lambda, tau = tau)
}

# set.seed(1); criterion(rule(paramMat[1,]), paramMat[1,], 1)
# set.seed(2); criterion(rule(paramMat[4,]), paramMat[4,], 2)

###########################

res <- simulation::simulation_generator(rule = rule, criterion = criterion,
                                        paramMat = paramMat, trials = 100,
                                        cores = 15, as_list = T,
                                        filepath = "../results/low_dim_simulation_tmp.RData",
                                        verbose = T)
save.image("../results/low_dim_simulation.RData")