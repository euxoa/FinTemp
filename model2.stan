
// To add:
// - error structure for stations, and AR(1)
// - month-varying sigmas
// - binding for monthly trends
data {
  int N; int S; int T; int darkN;
  real t[N];
  real lat[N]; real lon[N];
  int month[N];
  int station[N];
  real decade[N];
  int time[N];
  int darkTime[darkN]; int darkStation[darkN];
}
transformed data {
  vector[S] zeroS;
  for (i in 1:S) zeroS[i] <- 0;
}
parameters {
  matrix[S, 12] baseline;
  real trend[12];
  real trend_lat;
  real trend_lon;
  corr_matrix[S] Omega;
  vector<lower=0>[S] tau;
  vector[darkN] darkErr;  
}
model {
  vector[N] m;
  vector[N] err;
  matrix[S, S] Sigma;
  matrix[T, S] TSerr;
  for (i in 1:N) {
    m[i] <- baseline[station[i], month[i]] 
            + trend[month[i]]/100*decade[i] 
            + trend_lat/100*lat[i]*decade[i] 
            + trend_lon/100*lon[i]*decade[i];
  }
  Sigma <- quad_form_diag(Omega, tau);
  for (i in 1:N) TSerr[time[i], station[i]] <- t[i] - m[i]; // AR(1): -> k*TSerr[time[i]-1, station[i]] for time[i]>1 etc.
  for (i in 1:darkN) TSerr[darkTime[i], darkStation[i]] <- darkErr[i];
  for (i in 1:T) TSerr[i] ~ multi_normal(zeroS, Sigma);
  darkErr ~ normal(0, 20);  // FIXME, that 20
  tau ~ lognormal(0, 2);
  Omega ~ lkj_corr(2.0);
  for (i in 1:S)  baseline[i] ~ normal(5, 20);
  trend ~ normal(0, 300);
  trend_lat ~ normal(0, 30);
  trend_lon ~ normal(0, 30);
}