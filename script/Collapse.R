## Based on work  by Bendtsen M. (2017), https://link.springer.com/article/10.1007/s10618-017-0510-5
#This script contains, a helper function for Merge.R 
source('Combine.R')

Collapse_Regime_Child<-function(R,C,RC){
  
  #k'number of elements in R #L13
  k_star=length(R) 
  for (i in 1:k_star) {      #L14 Outer loop to keep track of regime i
    
    for (j in (i+1):k_star) { #L15 Inner loop to keep track of regime j
      
      # to check if to regimes are adjacent or not
      # combine and collapse regime if they are nonadjacent #L16
      if(!(j %in%C[i]) & !(i%in%C[j]) ){  
        
        #function call to Combine.R
        #returns new R and C
        cat('\ni= ',i, 'j= ', j)
        RnewCnew=Combine_Regime_Child(R,C,i,j) #L17
        Rnew=RnewCnew[[1]]
        Cnew=RnewCnew[[2]]
        #appending the new R and C to existing list #L18
        RC=list(RC,RnewCnew)
        
        #Recursion #L19
        Collapse_Regime_Child(Rnew,Cnew,RC)
      }            #L20
      
    }           #L21
    
  }     #L22
  
}  #L23
  
