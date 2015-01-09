library(dplyr)
library(ggplot2)
library(rstan)

d <- readRDS("data/t2.rds")
d <- d %>% mutate(time = as.factor(12*year+imonth))

m1 <- lm(t ~ name*month + month/decade + I(lat-62):decade + I(lon-29):decade, data=d)
summary(m1)

d.complete <- expand.grid(name=unique(d$name), time=unique(d$time)) %>% left_join(d, by=c("name", "time")) 
dark <- d.complete %>% filter(is.na(t))
d2 <- d.complete %>% filter(!is.na(t)) # To keep factor levels equal between d2 and dark

m <- stan_model(file="model2.stan")
stan.data <- with(d2, list(
    N=nrow(d), S=nlevels(name), T=nlevels(time), 
    t=t, lat=lat-60, lon=lon-25, 
    time=as.numeric(time),
    month=imonth, station=as.numeric(name), decade=decade, 
    darkN = nrow(dark), darkTime = as.numeric(dark$time), darkStation = as.numeric(dark$name)))
s <- sampling(m, data=stan.data, iter=100, thin=1, init=0, chains=1, refresh=1, seed=4, chain_id=1)

