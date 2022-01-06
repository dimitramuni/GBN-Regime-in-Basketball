# Based on work by Bendtsen M. (2017), https://link.springer.com/article/10.1007/s10618-017-0510-5
# Helper function for Construct.R

LL_GBN<-function(dataset,bn){
  
  #Bayesian Dirichilet Equivalent score
  BDE_score<-bnlearn::score(bn, dataset, type = "bde")
  return(BDE_score)
}


Accuracy_GBN<-function(GBN,resamples,R,tau,theta){
  
  #counter to keep track of how many times the log ratio has been calculated
  n_ratio=0
  accuracies<-c() #container for accuracy #L28
  
  for (regime in 1:length(resampled_regime)){   #L29
    
    n<-dim(resampled_regime[[regime]])[1] # number of observation in the regime #L30

    for(t in 1:n){          #
      
        if(t> (tau-1)){
          

          
          #Parent BN
          PBN<-GBN[[regime]]
          
          #Child BN
          CBN<-GBN[[Cn[[3]][[regime]]]]
          
          # if there is no child BN for a particular BN stop
          if(is.null(CBN)) {break}
          
          #subset data to be used for Ratio test
          subset_data=resampled_regime[[regime]][t,]
          
          Log_Ratio=LL_GBN(subset_data,CBN) - LL_GBN(subset_data,PBN)
          
          #log ratio calculation increment
          n_ratio=n_ratio+1
          
          #testing if active BN is GBN corresponds to true regime according to R
          accuracies<-c(accuracies,ifelse(Log_Ratio>log(theta),0,1)) 
          
              
                      }
      
                }
    
    
    } 
  
final_accuracy<-sum(accuracies)/n_ratio  

  return(final_accuracy)  #L41
} #L42