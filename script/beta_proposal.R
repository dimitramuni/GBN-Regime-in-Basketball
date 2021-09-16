#Beta Proposal Values using equation 7 to 11

#k is maximum number of transitions
k=2
n=39
current_betas=c(10,30)
propose_betas<-function(current_betas,n,k){ 
  
  for (j in 1:k) {
    
    #Lower Bound for Beta proposal;equation 7
    
    
    if (j==1){lower_bound_beta_proposal=1}
    
    else {  
      beta_temp_difference= (current_betas[j] -current_betas[(j-1)])/2
      lower_bound_beta_proposal= current_betas[j]-floor(beta_temp_difference)-1
    }
    
    #Upper Bound for Beta proposal;equation 8
    
    if(j==k){upper_bound_beta_proposal=n}
    
    else{  
      beta_temp_difference= (current_betas[(j+1)] -current_betas[j])/2
      upper_bound_beta_proposal= current_betas[j]+floor(beta_temp_difference)-1
    }
    
    #Kappa; equation 9
    Kappa= max(current_betas[j]-lower_bound_beta_proposal, upper_bound_beta_proposal-current_betas[j])
 
    #Normalising constant; equation 11
    Z1=0
    for (i in lower_bound_beta_proposal:current_betas[j]) {
      
      Z1=Z1+1+i-current_betas[j]+Kappa
    }
    
    Z2=0
    for (i in (current_betas[j]+1):upper_bound_beta_proposal){
      
      Z1=Z1+1-i+current_betas[j]+Kappa
    }
    Z=Z1+Z2 
    
    #Probability of any of the proposed Betas; equaation 12
    prob1=c()
    for (i in lower_bound_beta_proposal:current_betas[j]) {
      
      prob1=c(prob1, (1+i-current_betas[j]+Kappa)/Z )
      
    }
    
    
    prob2=c()
    for (i in current_betas[j]:upper_bound_beta_proposal){
      
      prob2=c(prob2, (1-i+current_betas[j]+Kappa)/Z ) 
      
    }
    
    cat('\nprobabilities',c(prob1,prob2) )
    
  }
  

}
