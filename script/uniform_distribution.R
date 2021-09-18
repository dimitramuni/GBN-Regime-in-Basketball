#This script is designed as helper function to IDENTIFY.R 
# function defined below utilises beta values(current or proposal) to compute 
# the uniform distribution, L#24 and #27 from IDENTIFY Algorithm

uniform_distribution<-function(betas,n,k){
  

  U_log=0
  #sorting the beta values in increasing order 
  betas=sort(betas,decreasing = FALSE)
  
  for (i in 1:k) {
    
    if(i==1){
      U_log=U_log+ dunif(x=betas[i],min =0 ,max =betas[i+1] ,log = TRUE)
    }
    else if(i==k){
      U_log=U_log+ dunif(x=betas[i],min =betas[i-1] ,max =n+1 ,log = TRUE)
    }
    
    else{
      U_log=U_log+ dunif(x=betas[i],min =betas[i-1] ,max =betas[i+1] ,log = TRUE)
    }
    
    
    
  }
 return(U_log) 
}