An effort to _model trends of monthly temperatures around Finland_. The main interest is on seasonal trends after 1980 and on the overall trend and its uncertainty. 

Work in progress. Current model:
- Trends by month, common to stations. Baseline temperature per month-station combination.
- Handles missing data.
- MA(1) for temporal autocorrelation.
- Covariance for stations.
- Residual variance varies by station, month.
- Latitudinal and longitudinal variation in trends (not significant).

![Monthly trends](/figs/monthly.png?raw=true)
![Overall trend](/figs/trend.png?raw=true)
