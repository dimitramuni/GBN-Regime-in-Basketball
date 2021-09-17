## Identifyinig regime change in the data set
## Based on work the by Bendtsen M. (2017), https://link.springer.com/article/10.1007/s10618-017-0510-5

#n=dim(dataset)[1]

n=1000 #number of data points (L2)
k=5 #maximum number of transition
n_iteration=30 # number of MCMC iterations

beta_current=numeric(length=k)# container for current Betas
beta_current=(1:k)*n/(k+1) #spacing out Beta evenly (L3)

#Current indicator variable is set to 1 intially for all the splits
indicator_current= rep(1,k) #current indicator variable (L4)

#Current delta variable
delta_current=numeric(length = k)
delta_current=beta_current*indicator_current# mulitplying beta_i * indicator_i (L5)

iteration=0 # (L6) for consistency with algorithm

# Matrix container for posterior samples
I=matrix(NA,nrow=n_iteration,ncol=k) # current Indicator (L7)
Delta=matrix(NA,nrow=n_iteration,ncol=k) #current Delta (L8)

repeat{                  #L9
  
  iteration=iteration+1  #L10
  
  #propose new betas, eq:7 to 11  #L11
  beta_proposal= propose_betas(beta_current,n,k)

  
  #proposing indicator variable  #L12 (Bernoulli Distribution; p=0.5)
  I_proposal=rbinom(n=k,size=1,prob=0.5)
  
  #calculating proposal delta #L13
  delta_proposal=beta_proposal*I_proposal
  
  #selecting current nonzeros deltas #L15
  delta_current_nonzero= subset(delta_current,delta_current>0)
  
  #selecting proposal nonzeros deltas #L16
  delta_proposal_nonzero= subset(delta_proposal,delta_proposal>0)
  
  
}



