# Based on work by Bendtsen M. (2017), https://link.springer.com/article/10.1007/s10618-017-0510-5
# Helper function for Construct.R

Loglikelihood_GBN<-function(dataset,bn){
  
  #Learning Bayesian Network using Hill Climbing Algorithm
  #bn<-hc(dataset,score = 'bde')
  #Bayesian Dirichilet Equivalent score
  BDE_score<-score(bn, dataset, type = "bde")
  return(BDE_score)
}




#Accuracy_GBN<-function(GBN,resamples,R,tau,theta){
  
  accuracies<-c() #container for accuracy #L28
  
  for (regime in 1:length(resampled_regime)){
    
    n<-dim(resampled_regime[[regime]])[1] # number of observation in the regime
   
    
    #bn_active<-as.grain(bn.fit(GBN[[1]])) #activated BN from GBN
    
    for(t in 1:n){
      
      if(t> (tau-1)){
        
        resampled_regime[[regime]][1:t,]
        
        
        
      }
      
    }
    
    
    } 
  
#}