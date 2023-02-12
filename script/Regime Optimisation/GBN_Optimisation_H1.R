#Constructing GBN
# Based on work by Bendtsen M. (2017), https://link.springer.com/article/10.1007/s10618-017-0510-5
require(kernlab)
require(bnlearn)


LL_GBN<-function(data_set,bn){
  
  #Bayesian Dirichilet Equivalent score
  BDE_score<-bnlearn::score(bn, data_set, type = "bde")
  return(BDE_score)
}


#GBN_Construct<-function(dataset,R,C){ #L1
D<-H[[1]]
nRegimes=length(D)
BN=list()

#Learning BN for each regime #L2
for (i in 1:nRegimes) {
  #BN<-hc(R[[i]],score = 'bde')
  #GBN[[i]]<-as.grain(bn.fit(BN,data=R[[i]]))
  BN[[i]]<-hc(D[[i]],score = 'bde')
  Rgraphviz::plot(BN[[i]])
  
}

#lookback window length, intial choice #L3
tau=15

#Value of threshold for the gates, initial choice
theta=22

#number of resamples #L5

#number of bayesian optimisation iteration #L6
nBayesOptimiseIteration=100


#exploration-exploitation tradeoff coefficient
eta=5

Lambda<-matrix(nrow = nBayesOptimiseIteration,ncol=2) #Container for parameteres #L14
colnames(Lambda)<-c('Tau','Theta')

f<-numeric(length = nBayesOptimiseIteration) #Container for accuracies #L15

calc_accuracy<-function(tau,theta){
  accuracy_container<-c()
  nResample=sample(x=1:100,size = 5,replace = FALSE)
  #nResample=1:5
  #print(nResample)

  for(resample in nResample){
    #as we are looking at hypothesis 1
    n_regimes<-1:4
    for (regime  in n_regimes) {
      n<-dim(Synth_D_H1[[resample]][[regime]])[1]
      #accuracy over each regime
      accur1<-c()
      for(t in 1:n){
        if(t>(tau)){
          
          if(regime==1){Log_Ratio=LL_GBN(Synth_D_H1[[resample]][[regime]][t-tau:t,],BN[[2]])-LL_GBN(Synth_D_H1[[resample]][[regime]][t-tau:t,],BN[[1]])}
          else if (regime==2){Log_Ratio=LL_GBN(Synth_D_H1[[resample]][[regime]][t-tau:t,],BN[[3]])-LL_GBN(Synth_D_H1[[resample]][[regime]][t-tau:t,],BN[[2]])}
          else if (regime==3){Log_Ratio=LL_GBN(Synth_D_H1[[resample]][[regime]][t-tau:t,],BN[[4]])-LL_GBN(Synth_D_H1[[resample]][[regime]][t-tau:t,],BN[[3]])}
          else if (regime==4){ Log_Ratio=LL_GBN(Synth_D_H1[[resample]][[regime]][t-tau:t,],BN[[5]])-LL_GBN(Synth_D_H1[[resample]][[regime]][t-tau:t,],BN[[4]])}
          #Log_Ratio=LL_GBN(subset_data,CBN) - LL_GBN(subset_data,PBN)
          #testing if active BN is GBN corresponds to true regime according to R
          accuracy_container<-c(accuracy_container,ifelse(Log_Ratio>log(theta),0,1))
          accur1<-c(accur1,ifelse(Log_Ratio>log(theta),0,1))
          
        }
      }
      
      #cat('\nregime',regime,' accuracy', mean(accur1))
      
    }
    
  }
  return(mean(accuracy_container))
}


test_tau=round(seq(5,50,length.out = 20))
test_theta=seq(1.5,150,length.out = 20)
Xtest<-expand.grid(test_tau,test_theta)
X<-matrix(data=c(tau,theta),ncol=2)


for (n_iter in 1:nBayesOptimiseIteration ){
  
  Lambda[n_iter,]=c(tau,theta)
  f[n_iter]<-calc_accuracy(tau = tau,theta=theta)
  
  #distance() find the euclidean distance, d= (x1-x2)**2 + (y1-y2)**2
  D_xx<-laGP::distance(X,X)
  D_xxt<-laGP::distance(X,Xtest)
  D_xtx<-laGP::distance(Xtest,X)
  D_xtxt<-laGP::distance(Xtest,Xtest)
  
  l<-1
  sigma_F<-50
  k_xx<-sigma_F*exp(-((D_xx)/(2*l*l)))
  k_xxt<-sigma_F*exp(-((D_xxt)/(2*l*l)))
  k_xtx<-sigma_F*exp(-((D_xtx)/(2*l*l)))
  k_xtxt<-sigma_F*exp(-((D_xtxt)/(2*l*l)))
  
  mu<-k_xtx%*%solve(k_xx)%*%f[1:n_iter]
  var<-k_xtxt-(k_xtx%*%solve(k_xx)%*%k_xxt)
  
  cat('\n n_iter',n_iter,' acc: ',f[n_iter])
  ##UCB
  ind=which.max(mu+ eta * sqrt(diag(var)))
  cat('\n')
  print(Xtest[ind,])
  
  
  tau=Xtest$Var1[ind]
  theta=Xtest$Var2[ind]
  

  
  X<-rbind(X,c(tau,theta))
  Xtest<-Xtest[-ind,]
}


#gbn_opt4<-list('eta'=eta,'accuracy'=f,'tau_theta'=Lambda)
#capture.output(gbn_opt4,file='~/Desktop/GBN-Regime-in-Basketball/results/GBN_Optimisation/gbn_opt4.csv')

