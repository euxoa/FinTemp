An effort to model trends of monthly temperatures around Finland. The main interest is on seasonal trends after 1980 and on the overall trend and its uncertainty. Spatial differences will be also be modelled. 

Work in progress, not much models yet. Current plan:
- At least the mixed model (lme4 model in preprocess2.R) improved and fitted properly with Stan. 
- AR(1) residuals. 
- Gaussian/von-Mises process for monthly trends. 
- Gaussian process for spatial trends.

This is with lme4:

      > m3 <- lmer(t ~ 1+ name*month + (0 + decade | month) + (0 + decade | name) + decade, data=t2 )
      > fixef(m3)["decade"]
        decade 
      0.441727 
      > # ±0.06 but does not have autocorrelation of the residuals taken into account.
      > ranef(m3)$month
                decade
      Jan  0.139847286
      Feb -0.206245745
      Mar -0.243496415
      Apr  0.108498686
      May -0.133570023
      Jun -0.056933494
      Jul  0.006802484
      Aug  0.024848107
      Sep  0.068195997
      Oct -0.209714445
      Nov  0.182208805
      Dec  0.319558756
      