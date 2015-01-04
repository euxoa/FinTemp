library(dplyr)
library(tidyr)

t0 <- read.table("data/v3.mean_GISS_homogenized_cleaned.txt", header=T, sep=";") %>% tbl_df()
s0 <- read.table("data/station_list_cleaned.txt", header=T, sep=";") %>% tbl_df()

sids <- s0 %>% filter(lat>58 & lat<80 & lon>20 & lon<38) %>% .$sid
t0 %>% filter(sid %in% sids)
y <- t0 %>% filter(sid %in% sids) %>% group_by(year) %>% summarise(n=n())
with(y, plot(year, n, type="l"))
