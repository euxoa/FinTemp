library(dplyr)
library(tidyr)

t0 <- read.table("data/v3.mean_GISS_homogenized_cleaned.txt", header=T, sep=";") %>% tbl_df()
s0 <- read.table("data/station_list_cleaned.txt", header=T, sep=";") %>% tbl_df()

sids <- s0 %>% filter(lat>58 & lat<80 & lon>20 & lon<38) %>% .$sid
t2 <- t0 %>% filter(sid %in% sids) %>% 
  gather(month, t, Jan:Dec) %>% 
  filter(t>-9990) %>%
  left_join(s0, by="sid") %>%
  mutate(sid=as.factor(sid), imonth=as.numeric(month), t=t/10) %>%
  filter(year>1780 & sid != 10490000)  # Alta lufthavn is broken

if (F) {
  y <- t2 %>% group_by(year) %>% summarise(n=n())
  with(y, plot(year, n/12, type="l"))
  hist(t2$t, n=100)
  library(mgcv)
  plot(gam(t ~ sid + s(imonth) + s(year), data=t2), scale=F)
  plot(gam(t ~ sid + s(imonth) + s(year), data=t2 %>% filter(year>1980)), scale=F)
  library(lme4)
  m <- lmer(t ~ (1 + decade | name) + (1 + decade | month) + decade, 
            data=t2 %>% filter(year>1980) %>% mutate(decade=(year-mean(year))/10))
  summary(m)
  ranef(m)
}

library(mgcv)
