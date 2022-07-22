#csv_path = "./my_stan_code/ground_truth_and_results.csv"
csv_path = "./ground_truth_and_results.csv"

#path_stan = "./my_stan_code/my_NRM2.stan"
path_stan = "./my_stan_code/MDNRM.stan"


MY_SEED <- 1234


library(rstan)
library(dplyr)
library(tidybayes)


########################
########################
########################

resp <- read.csv(csv_path)
resp <- resp+1  

# After the above line
# 1 -> normal
# 2 -> non-COVID19 pneumonia
# 3 -> COVID19 pneumonia

types <- c(resp$GT)
resp <- resp[,2:7]
resp <- t(resp)

N <- nrow(resp)
T <- ncol(resp)

print(csv_path)
print("number of radiologists:")
print(N)
print("number of cases (problems):")
print(T)

head(resp)
head(types)


data_nrm <- list(n_doctor=N, n_case=T, response=resp, K=3, types=types)



print("starting stan model ...")
print(path_stan)

rstan_options(auto_write=TRUE)
options(mc.cores=parallel::detectCores())
model.NRM <- stan_model(path_stan)
fit.mcmc_nrm <- sampling(model.NRM, data=data_nrm, chains=8, iter=8000, warmup=4000, thin=1, seed=MY_SEED, control = list(adapt_delta = 0.9, max_treedepth = 15))



print(fit.mcmc_nrm)

fit.mcmc_nrm %>% spread_draws(beta[n_case, K]) %>% median_qi(.width = c(.95)) -> beta
print("***** beta *****")
#print(beta)
#head(beta, 10)
print(beta, n=450)


fit.mcmc_nrm %>% spread_draws(theta[n_doctor, K1, K2]) %>% median_qi(.width = c(.95)) -> theta
print("***** theta *****")
#print(theta)
#head(theta, 10)
print(theta, n=100)


# check Rhat values
rs = summary(fit.mcmc_nrm)$summary[,"Rhat"]
print("***** Rhat *****")
print(summary(rs))
print( all(rs < 1.10, na.rm=T) )


#For GUI
#library(shinystan)
#launch_shinystan(fit.mcmc_nrm)

