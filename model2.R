library(dplyr)
library(ggplot2)
library(tidyr)
library(rstan)

d <- readRDS("data/t2.rds")
d <- d %>% mutate(itime = 12*year+imonth) %>% mutate(itime = as.integer(1+itime-min(itime)))

if (F) {
    m1 <- lm(t ~ name*month + month/decade + I(lat-62):decade + I(lon-29):decade, data=d)
    summary(m1)
}

itimes <- 1:max(d$itime)
names <- unique(d$name)
d.complete <- expand.grid(name=names, itime=itimes) %>% 
  left_join(d, by=c("name", "itime")) 
temp <- matrix(d.complete$t, nrow=length(itimes), ncol=length(names), byrow=T)
if (F) 
  image(temp)
time.vars <- data.frame(itime=itimes) %>% left_join(d %>% 
                   select(itime, year, month, imonth, decade) %>% distinct(), by="itime")
station.vars <- data.frame(name=names) %>% left_join(d %>% 
                   select(name, sid, sub, lat, lon, subsid) %>% distinct(), by="name")
darks <- which(is.na(temp), T)
temp[is.na(temp)] <- 10000

stan.data <- list(
  S=length(names), T=length(itimes), 
  temp=temp, lat=station.vars$lat-60, lon=station.vars$lon-25, 
  month=time.vars$imonth, 
  darkN = nrow(darks))
    

m <- stan_model(file="model2.stan")
s <- sampling(m, data=stan.data, iter=100, thin=1, init=0, chains=1, refresh=1, seed=5, chain_id=1)
saveRDS(s, "s.rds")
s <- readRDS("s.rds")
plot(s)
traceplot(s, "trend", ask=T)
trend.samples <- extract(s, "trend")[[1]]
plot(density(apply(trend.samples, 1, mean)))
Omega <- matrix(apply(apply(extract(s, "LOmega")[[1]], 1, function (m) m %*% t(m)), 1, mean), rep(length(names), 2))
rownames(Omega) <- names
colnames(Omega) <- names
heatmap(Omega, symm=T)
traceplot(s, "tau", inc_warmup=F, ask=T)
traceplot(s, "trend_lat", inc_warmup=F)
traceplot(s, "Omega", inc_warmup=F, ask=T)
