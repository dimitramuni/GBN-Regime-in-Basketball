# 95% bands for accuracy 
library(plotly)
library()
eta=10
accuracy=c(0.9170472, 0.8955167, 0.8996183, 0.8899547, 0.9070677, 0.8601064, 0.8870992, 0.8917674, 0.8862406, 0.8793846, 0.8932663, 0.8764386,
            0.8611894, 0.8608491, 0.8977692, 0.8632353, 0.8394246, 0.8651017, 0.8882075, 0.8692552, 0.9278309, 0.9007212, 0.8970681, 0.8805423,
            0.8851763, 0.8350080, 0.9067308, 0.8606973, 0.8540221, 0.8298905, 0.8512442, 0.8561146, 0.8946923, 0.9266462, 0.8645137, 0.8859517,
            0.8612782, 0.8366769, 0.8383846, 0.8505418, 0.8266719, 0.8263693, 0.7889151, 0.8506839, 0.8261329, 0.8628571, 0.8497623, 0.8223285,
            0.8302083, 0.9083459, 0.9126888, 0.8854863, 0.9041221, 0.8905385, 0.8832043, 0.9045101, 0.8690923, 0.9139151, 0.9386688, 0.8562998,
            0.8812500, 0.8416006, 0.8933754, 0.8976874, 0.8664263, 0.9061033, 0.8888025, 0.9135449, 0.8816923, 0.9343798, 0.9263678, 0.8762840,
            0.9188722, 0.9078947, 0.8770393, 0.9303191, 0.8751908, 0.9072308, 0.8931115, 0.8929238, 0.9103286, 0.9487421, 0.8731379, 0.9099681,
            0.8799679, 0.9256079, 0.8952672, 0.9039275, 0.8969173, 0.9323077, 0.8882353, 0.9115863, 0.8975743, 0.8966195, 0.9282092, 0.9114035,
            0.8544872, 0.9054711, 0.8954962, 0.9143505)
Ttheta=read.csv('~/Desktop/GBN-Regime-in-Basketball/results/GBN_Optimisation/gbn_opt_ttheta1.csv',sep='')

df=as.data.frame(cbind(Ttheta,accuracy))
#l1=list('eta'=eta,'accuracy'=accuracy,'tau_theta'=Ttheta)
#rlist::list.save(l1,file='~/Desktop/GBN-Regime-in-Basketball/results/GBN_Optimisation/gbn_opt1.RData')
#a=rlist::list.load(file='~/Desktop/GBN-Regime-in-Basketball/results/GBN_Optimisation/gbn_opt1.RData')
fig <- plot_ly(df, x = ~tau, y = ~theta, z = ~accuracy)%>% add_markers()
fig


temp=read.csv('~/Desktop/GBN-Regime-in-Basketball/data/A003024.csv', sep=' ')
plot(x=temp$nodes,y=log(temp$graphs),main='Exponential increase in number of DAGs',
     xlab='number of nodes',
     ylab = 'log(# of DAGs)',col='red')
