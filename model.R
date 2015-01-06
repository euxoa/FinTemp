library(dplyr)
library(ggplot2)
library(rstan)

d <- readRDS("data/t2.rds")

m1 <- lm(t ~ name*month + month/decade + I(lat-62):decade + I(lon-29):decade, data=d)
summary(m1)

m <- stan_model(file="model1.stan")
s <- sampling(m, data=with(d, list(
                           N=nrow(d), S=nlevels(name), t=t, lat=lat-60, lon=lon-25, 
                           month=imonth, station=as.numeric(name), decade=decade)),
         iter=100, thin=1, init=0, chains=1, refresh=1, seed=5, chain_id=1)
