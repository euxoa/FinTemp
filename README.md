Modelling trends of monthly average temperatures around Finland.

Work in progress, no models yet. The plan is to make a gaussian process for trends, over lat, lon, and month. 

This is with lme4, the first ranef is degenerate (correlation -1.0):
            
            Fixed effects:
                        Estimate Std. Error t value
            (Intercept)  1.65883    2.77753   0.597
            decade       0.48758    0.08725   5.588
             
            ranef(m)
            $name
                             (Intercept)        decade
            HAPARANDA          0.4451161 -0.0006701684
            HELSINKI/SEUTULA   3.6998105 -0.0055704488
            JOENSUU            1.0917783 -0.0016437856
            JOKIOINEN          2.9791491 -0.0044854183
            JYVASKYLA          1.3271028 -0.0019980910
            KAJAANI            0.4037400 -0.0006078725
            KARASJOK          -3.1434373  0.0047327712
            KARESUANDO        -3.2131585  0.0048377438
            KUUSAMO           -1.3868726  0.0020880808
            LAPPEENRANTA       2.4942866 -0.0037554075
            MAKKAUR FYR      -12.9703594  0.0195282227
            OULU               0.8483472 -0.0012772747
            SODANKYLA         -0.0944295  0.0001421734
            TURKU              3.6652015 -0.0055183414
            VAASA              3.4636812 -0.0052149317
            VARDO              0.3900441 -0.0005872518
            
            $month
                (Intercept)      decade
            Jan -11.3270193  0.05143326
            Feb -11.2533443 -0.46186151
            Mar  -7.0672237 -0.21322445
            Apr  -1.2862055  0.24873438
            May   4.9916025 -0.01585814
            Jun  10.0654277 -0.06462273
            Jul  13.0843234  0.00417619
            Aug  11.0273872  0.04488742
            Sep   6.1369805  0.07213818
            Oct   0.4334091 -0.21850466
            Nov  -5.4335109  0.18994640
            Dec  -9.3718267  0.36275566
