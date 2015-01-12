
// To add/fix:
// - GP for months
data {
  int S; int T; int darkN;
  real temp[T, S];
  real lat[S]; real lon[S];
  int month[T];
}
transformed data {
  vector[S] zeroS;
  for (i in 1:S) zeroS[i] <- 0;
}
parameters {
  matrix[S, 12] baseline;
  vector[12] trend;
  vector<lower=0>[12] tau_month;
  real trend_lat;
  real trend_lon;
  cholesky_factor_corr[S] LOmega;
  vector<lower=0>[S] tau; // station (margin) sd's
  vector[darkN] darkErr;  
  real<lower=0, upper=1> rho;
}
model {
  matrix[S, S] LSigma[12];
  matrix[T, S] TSerr;
  real m; real decade; int i_dark;
  i_dark <- 1;
  for (t in 1:T) {
    decade <- (t-T/2.0)/120.;
    for (s in 1:S) 
       if (temp[t, s]<5000) {
          m <- baseline[s, month[t]] 
                     + trend[month[t]]/10*decade 
                     + trend_lat/100*lat[s]*decade 
                     + trend_lon/100*lon[s]*decade;
          if (t>1) 
               TSerr[t, s] <- rho*TSerr[t-1, s] + temp[t, s] - m; 
          else 
               TSerr[t, s] <- temp[t, s] - m; }
       else {
               TSerr[t, s] <- darkErr[i_dark]; i_dark <- i_dark+1; }}
  for (i in 1:12) LSigma[i] <- diag_pre_multiply(tau*tau_month[i], LOmega);
  for (i in 1:T) TSerr[i] ~ multi_normal_cholesky(zeroS, LSigma[month[i]]);
  darkErr ~ normal(0, 30);  
  tau ~ lognormal(0.7, 1.0);
  tau_month ~ lognormal(0.0, 1.0); // Fix one index?
  // LOmega ~ lkj_corr_cholesky(1.0); 
  for (i in 1:S)  baseline[i] ~ normal(5, 50);
  trend ~ normal(0, 30);
  trend_lat ~ normal(0, 30);
  trend_lon ~ normal(0, 30);
}

