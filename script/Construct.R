# Based on work by Bendtsen M. (2017), https://link.springer.com/article/10.1007/s10618-017-0510-5


#GBN_Construct<-function(dataset,R,C){ #L1
require(kernlab)
require(bnlearn)
source('Accuracy.R')

dataset=asia 
#number of regimes
nRegimes=length(C)
GBN=list()

#Learning BN for each regime #L2
for (i in 1:nRegimes) {
  #BN<-hc(R[[i]],score = 'bde')
#GBN[[i]]<-as.grain(bn.fit(BN,data=R[[i]]))
  GBN[[i]]<-hc(R[[i]],score = 'bde')
}

#lookback window length, intial choice #L3
tau=25

#Value of threshold for the gates, initial choice
theta=1.5

#number of resamples #L5
nResample=1000
#number of bayesian optimisation iteration #L6
nBayesOptimiseIteration=250

#exploration-exploitation tradeoff coefficient
eta=5

#resampled regimes
resampled_regime=R    #L9
for (iteration in 1:nResample) {    #L10
  
  for (i in 1:nRegimes) {
   
     #number of observation in Regime i
   
    nObservation= dim(resampled_regime[[i]])[1]
    
    #converting all the rownmaes of Regime i into integers
    all_indicies=as.integer(rownames(resampled_regime[[i]]))
    
    #sampling the indicies with replacement
    resampled_indicies=sample(all_indicies,size=nObservation,replace = F)
    
    resampled_regime[[i]]=dataset[resampled_indicies,]           #L11
    
  }
  
  
}       #L12
Lambda<-matrix(nrow = nBayesOptimiseIteration,ncol=2) #Container for parameteres #L14
f<-c() #Container for accuracies #L15
#################################GP############################################

for (iteration in 1:nBayesOptimiseIteration){
  
  accuracy<- Accuracy_GBN(GBN,resampled_regime,R,tau,theta) #L17

  Lambda[iteration,]=c(tau,theta)                          #L18
   
  f<-c(f,accuracy)                                          #L19
  
  SEkernel<-rbfdot(sigma = 0.5)
  #Update tau and theta using GP
  iteration=1
  x=matrix(Lambda[1:iteration,],byrow=T,nrow=1,ncol=2)
  #x=(x-mean(x))/sd(x)
  xstar=as.matrix.data.frame(expand.grid(x=seq(0,25,length.out = 10),y=seq(0,1.5,length.out =10 )))
  #xstar=x
  xstar<-as.matrix(t(xstar[24,])) 
  Kss<-kernelMatrix(kernel = SEkernel,x=xstar,y=xstar)
  Kxs<-kernelMatrix(kernel = SEkernel,x=x,y=xstar)
  Kxx<-kernelMatrix(kernel = SEkernel,x=x,y=x)
  
  #sigma_g(tau_i,theta_i)
  #mu_g(tau_i,theta_i)
  MeanVec<- t(Kxs)%*%solve(Kxx)*f
  CovMat<- Kss - t(Kxs)%*%solve(Kxx,Kxs)
  
  rmvnorm(1,mean=t(MeanVec),sigma = CovMat)
}

#parametrising GBN with Lambda pair for which accuracy is the greatest

 
#}