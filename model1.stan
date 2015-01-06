
// To add:
// - error structure for stations, and AR(1)
// - month-varying sigmas
// - binding for monthly trends
data {
  int N; int S;
  real t[N];
  real lat[N]; real lon[N];
  int month[N];
  int station[N];
  real decade[N];
}
parameters {
  matrix[S, 12] baseline;
  real trend[12];
  real trend_lat;
  real trend_lon;
  real<lower=0> sigma0;
}
model {
  vector[N] m;
  vector[N] sigma;
  for (i in 1:N) {
    m[i] <- baseline[station[i], month[i]] 
            + trend[month[i]]/100*decade[i] 
            + trend_lat/100*lat[i]*decade[i] 
            + trend_lon/100*lon[i]*decade[i];
  }
  for (i in 1:N) {
    sigma[i] <- sigma0;
  }
  t ~ normal(m, sigma);
  sigma0 ~ lognormal(0, 2);
  for (i in 1:S)  baseline[i] ~ normal(5, 20);
  trend ~ normal(0, 300);
  trend_lat ~ normal(0, 30);
  trend_lon ~ normal(0, 30);
}