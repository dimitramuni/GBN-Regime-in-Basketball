## Identifyinig regime change in the data set
## Based on work the by Bendtsen M. (2017), https://link.springer.com/article/10.1007/s10618-017-0510-5
setwd("~/Desktop/GBN-Regime-in-Basketball/script")
source('uniform_distribution.R')
source('beta_proposal.R')
require(textshape)
require(bnlearn)
require(Rlab)
dataset=asia
n=dim(dataset)[1]

#n=1000 #number of data points (L2)
k=3 #maximum number of transition
n_iteration=10 # number of MCMC iterations

beta_current=numeric(length=k)# container for current Betas
beta_current=(1:k)*n/(k+1) #spacing out Beta evenly (L3)

#Current indicator variable is set to 1 intially for all the splits
I_current= rep(1,k) #current indicator variable (L4)

#Current delta variable
delta_current=numeric(length = k)
delta_current=beta_current*I_current# mulitplying beta_i * indicator_i (L5)

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
  delta_current_nonzero_sorted=sort(delta_current_nonzero,decreasing = F) #sorting positions in increasing order
  
  #selecting proposal nonzeros deltas #L16
  delta_proposal_nonzero= subset(delta_proposal,delta_proposal>0)
  delta_proposal_nonzero_sorted=sort(delta_proposal_nonzero,decreasing = F) #sorting positions in increasing order
  
  
  #current subset of data #L18
  D_current=split_index(dataset,delta_current_nonzero_sorted)
  
  #Structure learning using Hill Climbing Algorithm #L19 and L23 partly(adding the loglikelihood)
  n1=length(D_current)
  loglikelihood_D_current_nonzero_deltas=0
  for (i in 1:n1) {
    
    #ignoring the subset which has upto 30 data points (could be tuned later on)
    if(dim(D_current[[i]])[1]>0.30){
      #structure learning for subset i of D_proposal dataset
      bn<-hc(D_current[[i]],score = 'bde')
      #bayesian dirichlet score #23
      loglikelihood_D_current_nonzero_deltas=
        loglikelihood_D_current_nonzero_deltas+ score(bn, D_current[[i]], type = "bde")
    }
    
  }
  
  
  
  #proposal subset of data #20
  D_proposal=split_index(dataset,delta_proposal_nonzero_sorted)
  
  #Structure learning using Hill Climbing Algorithm #L21 and L25 partly (adding the loglikelihood)
  n2=length(D_proposal)
  loglikelihood_D_proposal_nonzero_deltas=0
  for (i in 1:n2) {
    
    #ignoring the subset which has upto 30 data points (could be tuned later on)
    if(dim(D_proposal[[i]])[1]>0.30){
      
      #structure learning for subset i of D_proposal dataset
      bn<-hc(D_proposal[[i]],score = 'bde')
      #bayesian dirichlet score #L25
      loglikelihood_D_proposal_nonzero_deltas=
        loglikelihood_D_proposal_nonzero_deltas+ score(bn, D_proposal[[i]], type = "bde")
    }
    
  }
  
  #Prior distribution for current beta varaibles
  U_distribution_current=uniform_distribution(betas = beta_current,n=n,k=k)
  #Prior distribution for proposal Indicator variables 
  I_distribution_current= dbern(x=beta_current,prob=0.5,log = TRUE)
  
  #Prior distribution for proposal beta varaibles
  U_distribution_proposal=uniform_distribution(betas = beta_proposal,n=n,k=k)
  #Prior distribution for proposal Indicator variables 
  I_distribution_proposal=dbern(x=beta_proposal,prob=0.5,log = TRUE)
  
  #adding logarithmic probability current distributions #L24
  log_posterior_D_current=loglikelihood_D_current_nonzero_deltas+U_distribution_current+I_distribution_current
  
  #adding logarithmic probability proposal distributions #L26
  log_posterior_D_proposal=loglikelihood_D_proposal_nonzero_deltas+ U_distribution_proposal+I_distribution_proposal
  
  }



