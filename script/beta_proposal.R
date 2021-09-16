#Beta Proposal Values using equation 7 to 11

#k is maximum number of transitions
k=2
n=39
current_betas=c(1,39)
propose_betas<-function(current_betas,n,k){ 
  
  beta_probabilities=data.frame()
  
  for (j in 1:k) {
    
    #Lower Bound for Beta proposal;equation 7
    
    
    if (j==1){lower_bound_beta_proposal=1}
    
    else {  
      beta_temp_difference1= (current_betas[j] -current_betas[(j-1)])/2
      cat('\nbeta_temp_difference1',beta_temp_difference1)
      lower_bound_beta_proposal= current_betas[j]-floor(beta_temp_difference1)+1
    }
    
    #Upper Bound for Beta proposal;equation 8
    
    if(j==k){upper_bound_beta_proposal=n}
    
    else{  
      beta_temp_difference2= (current_betas[(j+1)] -current_betas[j])/2
      upper_bound_beta_proposal= current_betas[j]+floor(beta_temp_difference2)-1
    }
    
    #Kappa; equation 9
    Kappa= max(current_betas[j]-lower_bound_beta_proposal, upper_bound_beta_proposal-current_betas[j])
    
    cat('\nKappa:-', Kappa)
    #Normalising constant; equation 11
    Z1=0
    if(current_betas[j]>=lower_bound_beta_proposal){
        for (i in lower_bound_beta_proposal:current_betas[j]) {
         
          Z1=Z1+1+i-current_betas[j]+Kappa
        }
    }
    Z2=0
    if(upper_bound_beta_proposal>=(current_betas[j]+1)){
      for (i in (current_betas[j]+1):upper_bound_beta_proposal){
        
        Z2=Z2+1-i+current_betas[j]+Kappa
      }
    }
    Z=Z1+Z2 
    cat('\nZ:',Z)
    cat('\n')
    #Probability of any of the proposed Betas; equaation 12
    beta_values1=c()
    prob1=c()
    
    if(current_betas[j]>=lower_bound_beta_proposal){
    
      for (i in lower_bound_beta_proposal:current_betas[j]) {
        cat('\n i=',i)
        beta_values1=c(beta_values1,i)
        prob1=c(prob1, (1+i-current_betas[j]+Kappa)/Z )
        
      }
    }
    
    
    prob2=c()

    beta_values2=c()
    cat('\n -----')
    if(upper_bound_beta_proposal>=(current_betas[j]+1)){
      for (i in (current_betas[j]+1):upper_bound_beta_proposal){
        cat('\n i=',i)
        beta_values2=c(beta_values2,i)
        prob2=c(prob2, (1-i+current_betas[j]+Kappa)/Z ) 
        
      }
    }
    probabilities=c(prob1,prob2) 
    df=data.frame(x=c(beta_values1,beta_values2),y=probabilities)
    beta_probabilities=rbind(beta_probabilities,df)    
    
    
    cat('\ncurrent_beta[j]',current_betas[j])
    cat('\n lower bound beta proposal',lower_bound_beta_proposal)
    cat('\ncurrent_beta[j]+1',(current_betas[j]+1))
    cat('\n upper bound beta proposal',upper_bound_beta_proposal)
  }

 plot(x=beta_probabilities$x,y=beta_probabilities$y)  
return(beta_probabilities)
}
propose_betas(current_betas,n,k)
