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
D<-H[[7]]
nRegimes=length(D)
BN=list()

#Learning BN for each regime #L2
for (i in 1:nRegimes) {
  #BN<-hc(R[[i]],score = 'bde')
  #GBN[[i]]<-as.grain(bn.fit(BN,data=R[[i]]))
  BN[[i]]<-hc(D[[i]],score = 'bde')
}

#lookback window length, intial choice #L3
tau=5

#Value of threshold for the gates, initial choice
theta=1.5

#number of resamples #L5

#number of bayesian optimisation iteration #L6
nBayesOptimiseIteration=100


#exploration-exploitation tradeoff coefficient
eta=100

Lambda<-matrix(nrow = nBayesOptimiseIteration,ncol=2) #Container for parameteres #L14

f<-numeric(length = nBayesOptimiseIteration) #Container for accuracies #L15

calc_accuracy<-function(tau,theta){
  accuracy_container<-c()
  #nResample=sample(x=1:100,size = 5,replace = FALSE)
  nResample=1:5
  #print(nResample)
  for(resample in nResample){
  #as we are looking at hypothesis 7
  n_regimes<-length(H[[7]])
  for (regime  in 1:n_regimes) {
    n<-dim(Synth_D_H2[[resample]][[regime]])[1]
    #accuracy over each regime
    accur1<-c()
      for(t in 1:n){
        if(t>(tau)){
  
          if(regime==1){Log_Ratio=LL_GBN(Synth_D_H2[[resample]][[regime]][t-tau:t,],BN[[2]])-LL_GBN(Synth_D_H2[[resample]][[regime]][t-tau:t,],BN[[1]])}
          else if (regime==2){Log_Ratio=LL_GBN(Synth_D_H2[[resample]][[regime]][t-tau:t,],BN[[3]])-LL_GBN(Synth_D_H2[[resample]][[regime]][t-tau:t,],BN[[2]])}
          else if (regime==3){Log_Ratio=LL_GBN(Synth_D_H2[[resample]][[regime]][t-tau:t,],BN[[1]])-LL_GBN(Synth_D_H2[[resample]][[regime]][t-tau:t,],BN[[3]])}
          else if (regime==4){ Log_Ratio=LL_GBN(Synth_D_H2[[resample]][[regime]][t-tau:t,],BN[[4]])-LL_GBN(Synth_D_H2[[resample]][[regime]][t-tau:t,],BN[[1]])}
          #Log_Ratio=LL_GBN(subset_data,CBN) - LL_GBN(subset_data,PBN)
           #testing if active BN is GBN corresponds to true regime according to R
          accuracy_container<-c(accuracy_container,ifelse(Log_Ratio>log(theta),0,1))
    
        }
      }

    
    
  }

}
return(mean(accuracy_container))
}


test_tau=round(seq(5,50,length.out = 20))
test_theta=seq(0.15,15,length.out = 20)
Xtest<-expand.grid(test_tau,test_theta)
X<-matrix(data=c(tau,theta),ncol=2)

 
for (n_iter in 1:nBayesOptimiseIteration ){
  
  
  f[n_iter]<-calc_accuracy(tau = tau,theta=theta)
  
  
  D_xx<-laGP::distance(X,X)
  D_xxt<-laGP::distance(X,Xtest)
  D_xtx<-laGP::distance(Xtest,X)
  D_xtxt<-laGP::distance(Xtest,Xtest)
  
  c<-0.5
  k_xx<-exp(-c*D_xx)
  k_xxt<-exp(-c*D_xxt)
  k_xtx<-exp(-c*D_xtx)
  k_xtxt<-exp(-c*D_xtxt)
  
  mu<-k_xtx%*%solve(k_xx)%*%f[1:n_iter]
  var<-k_xtxt-(k_xtx%*%solve(k_xx)%*%k_xxt)
  
  print('\n')
  print(f[n_iter])
  ##UCB
  ind=which.max(mu+ eta * sqrt(diag(var)))
  print(Xtest[ind,])
  
  
  tau=Xtest$Var1[ind]
  theta=Xtest$Var2[ind]
  
  X<-rbind(X,c(tau,theta))
  Xtest<-Xtest[-ind,]
}
 


