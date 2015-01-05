library(dplyr)
library(tidyr)

t0 <- read.table("data/v3.mean_GISS_homogenized_cleaned.txt", header=T, sep=";") %>% tbl_df()
s0 <- read.table("data/station_list_cleaned.txt", header=T, sep=";") %>% tbl_df()

sids <- s0 %>% filter(lat>55 & lat<80 & lon>12 & lon<38) %>% .$sid
t2 <- t0 %>% filter(sid %in% sids) %>% 
  gather(month, t, Jan:Dec) %>% 
  filter(t>-9990 & year>1980) %>%
  left_join(s0, by="sid") %>%
  mutate(sid=as.factor(sid), 
         subsid=as.factor(paste(sid, sub, sep=".")), name=as.factor(paste(name, sub, sep=":")),
         imonth=as.numeric(month), t=t/10, decade=(year-mean(year))/10)
if (F) {
  t2 %>%  ggplot(aes(x=year, y=t, color=name)) + geom_line() + facet_wrap(~ month)
  m <- lmer(t ~ (1 + decade | subsid) + (1 + decade | month) + decade, data=t2)
  ranef(m)$subsid["(Intercept)"] # Outliers
  t2 %>% group_by(subsid) %>% summarise(n=n()) %>% filter(n<12*5) # Almost no obs
}

t2 <- t2 %>% filter(! (subsid %in% c("10490000.1336", "10920000.4037", "22260000.4257", "10920000.6340")) )
t2 %>%  ggplot(aes(x=year, y=t, color=name)) + geom_line() + facet_wrap(~ month)

if (F) {
  y <- t2 %>% group_by(year) %>% summarise(n=n())
  with(y, plot(year, n/12, type="l"))
  hist(t2$t, n=100)
}

m <- lmer(t ~ (1 + decade | name) + (1 + decade | month) + decade, data=t2 )
summary(m)
ranef(m)
t2 %>%  ggplot(aes(x=year, y=t, color=name)) + geom_line() + facet_wrap(~ month)
t2 %>% mutate(r=resid(m)) %>% ggplot(aes(x=year, y=r, color=name)) + geom_point() + facet_wrap(~ month)
t2 %>% mutate(r=resid(m)) %>% ggplot(aes(x=year, y=r, color=month)) + geom_point() + facet_wrap(~ name)
# There's significant name-month interaction
# Monthly residuals are different
m2 <- lm(t ~ decade*name + month*name, data=t2)
t2 %>% mutate(r=resid(m2)) %>% ggplot(aes(x=year, y=r, color=name)) + geom_point() + facet_wrap(~ month)
t2 %>% mutate(r=resid(m2)) %>% ggplot(aes(x=year, y=r, color=month)) + geom_point() + facet_wrap(~ name)
# There is lag-1 autocorrelation
acf((t2 %>% mutate(r=resid(m2)) %>% group_by(year, imonth) %>% 
       summarise(r=mean(r)) %>% mutate(ym=year+imonth/12) %>% arrange(ym))$r)

m3 <- lmer(t ~ 1+ name*month + (0 + decade | month) + (0 + decade | name) + decade, data=t2 )
fixef(m3)["decade"] # 0.441727
ranef(m3)$month

