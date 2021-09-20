#This script contains, a helper function for Merge.R and 
source('Combine.R')

Collapse_Regime_Child<-function(R,C,RC){
  
  #k'number of elements in R #L13
  k_star=length(R)
  for (i in 1:k_star) {
    
    for (j in (i+1):k_star) {
      
      if(j!=C[i] & i!=C[j] ){
        
        RnewCnew=Combine_Regime_Child(R,C,i,j)
        
        RC=list(RC,Rnew,Cnew)
        
        Collapse_Regime_Child(Rnew,Cnew,RC)
      }
      
    }
    
  }
  
}