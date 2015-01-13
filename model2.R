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
s <- sampling(m, data=stan.data, warmup=250, iter=1000, thin=5, init=0, chains=4, refresh=1)
saveRDS(s, "s.rds")
s <- readRDS("s.rds")
plot(s)
plot(s, par="trend")
plot(s, par="rho")
plot(s, par="tau_month")
traceplot(s, "trend", inc_warmup=F, ask=T)
trend.samples <- extract(s, "trend")[[1]]
plot(density(apply(trend.samples, 1, mean)))
hist(apply(trend.samples, 1, mean), n=100)
Omega <- matrix(apply(apply(extract(s, "LOmega")[[1]], 1, function (m) m %*% t(m)), 1, mean), rep(length(names), 2))
rownames(Omega) <- names
colnames(Omega) <- names
heatmap(Omega, symm=T)
traceplot(s, "tau_month", inc_warmup=F, ask=F)
traceplot(s, "trend_lat", inc_warmup=F)
#traceplot(s, "LOmega", inc_warmup=F, ask=T)
sort(setNames(svd(Omega)[[2]][,1], names), decr=T)
sort(setNames(svd(Omega)[[2]][,2], names), decr=T)


trend.samples %>% apply(., 2, function (v) quantile(v, c(.025, .25, .5, .75, .975))/10) %>% 
  t  %>% data.frame %>% setNames(c("ll", "l", "m", "u", "uu")) %>% 
  data.frame(., month=reorder(levels(d$month), 1:12)) %>% 
  ggplot(., aes(x=month, y=m)) + #geom_point(size=2) + 
  geom_pointrange(aes(ymax=u, ymin=l), size=1) + 
  geom_pointrange(aes(ymax=uu, ymin=ll), size=.5)  + 
  ylab("°C / decade") + xlab("") + ggtitle("1980-2014 (bars 50% and 95%)") +
  expand_limits(y=0) +
  theme_bw(20)
ggsave("figs/monthly.png", scale=.7)

trend.samples %>% apply(., 1, mean) %>% data.frame(trend=./10) %>%
  ggplot(., aes(x=trend)) + geom_density(fill="grey80", color="white") + theme_bw(20) +
  xlab("°C / decade") + ylab("") + scale_y_continuous(breaks=NULL) + 
  geom_vline(aes(xintercept=mean(trend.samples)/10), color="red") +
  geom_vline(aes(xintercept=quantile(apply(trend.samples, 1, 
                                           function (x) mean(x)/10), c(.025, .25, .75, .975))), color="red", linetype=2) +
  ggtitle("1980-2014 (lines 50% and 95%)")
ggsave("figs/trend.png", scale=.7)

ggplot(d.complete, aes(x=itime, y=name, fill=t)) + geom_tile() + ggtitle("Raw data")
ggsave("figs/data.png", scale=.7) 

ggplot(reshape2::melt(Omega), aes(x=Var1, y=Var2, fill=value)) + geom_raster() + 
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) + xlab("") + ylab("")
ggsave("figs/statcorr.png", scale=.7)

extract(s, "tau_month")[[1]] %>% 
  apply(., 2, function (v) quantile(v, c(.025, .25, .5, .75, .975))) %>% 
  t  %>% data.frame %>% setNames(c("ll", "l", "m", "u", "uu")) %>% 
  data.frame(., month=reorder(levels(d$month), 1:12)) %>% 
  ggplot(., aes(x=month, y=m)) + #geom_point(size=2) + 
  geom_pointrange(aes(ymax=u, ymin=l), size=1) + 
  geom_pointrange(aes(ymax=uu, ymin=ll), size=.5)  + 
  ylab("") + xlab("") + ggtitle("Monthly sd (relative)") +
  expand_limits(y=0) +
  theme_bw(20) 
ggsave("figs/tau_month.png", scale=.7)

extract(s, "tau")[[1]] %>% 
  apply(., 2, function (v) quantile(v, c(.025, .25, .5, .75, .975))) %>% 
  t  %>% data.frame %>% setNames(c("ll", "l", "m", "u", "uu")) %>% 
  data.frame(., month=names) %>% 
  ggplot(., aes(x=month, y=m)) + #geom_point(size=2) + 
  geom_pointrange(aes(ymax=u, ymin=l), size=1) + 
  geom_pointrange(aes(ymax=uu, ymin=ll), size=.5)  + 
  ylab("") + xlab("") + ggtitle("Station sd (relative)") +
  expand_limits(y=0) + coord_flip() +
  theme_bw(20) 
ggsave("figs/tau.png", scale=.7)

