#With the courtsey of Marcus Bendtsen
## Identifyinig regime change in the data set using Rcpp implmentation
## Based on work by Bendtsen M. (2017), https://link.springer.com/article/10.1007/s10618-017-0510-5
setwd("~/Desktop/GBN-Regime-in-Basketball/script/Regime Identification")
#source('uniform_distribution.R')
#source('beta_proposal.R')
require(textshape)
require(bnlearn)
require(Rlab)
require(Rcpp)
require(RcppArmadillo)
Rcpp::sourceCpp('uniform_distribution.cpp')
Rcpp::sourceCpp('beta_proposal.cpp')

#n=1000 #number of data points (L2)
#k=4 #maximum number of transition
#n_iteration=200 # number of MCMC iterations

Loglikelihood_Calculation_hc<-function(dataset){
 
  #data=gamelog_discrete
  blacklisted_arcs1<-data.frame(from = c("WL", "WL","WL", "WL","WL", "WL","WL", "WL","WL", "WL",
                                         "OffeFGper","OffTOVper","OffORBper","OffFT_d_FGA","DefeFGper","DefTOVper","DefDRBper","DefFT_d_FGA","PlayOff",
                                         "OffeFGper","OffTOVper","OffORBper","OffFT_d_FGA","DefeFGper","DefTOVper","DefDRBper","DefFT_d_FGA","HomeAway"), 
                                to = c("OffeFGper","OffTOVper","OffORBper","OffFT_d_FGA","DefeFGper","DefTOVper","DefDRBper","DefFT_d_FGA","PlayOff", "HomeAway",
                                       "HomeAway","HomeAway","HomeAway","HomeAway","HomeAway","HomeAway","HomeAway","HomeAway","HomeAway",
                                       "PlayOff","PlayOff","PlayOff","PlayOff","PlayOff","PlayOff","PlayOff","PlayOff","PlayOff"))
                                       
  #Learning Bayesian Network using Hill Climbing Algorithm
  #bn<-hc(x=dataset,score = 'bde')
  bn<-hc(x=dataset,score = 'bde')
  #Bayesian Dirichilet Equivalent score
  BDE_score<-bnlearn::score(bn, dataset, type = "bde")
  return(BDE_score)
}



Identify_Positions_hc<-function(data,k,n_iteration){
  
  dataset=data
  n=dim(dataset)[1]
  #set.seed(1728)
  
  
  
  beta_current=numeric(length=k)# container for current Betas
  beta_current=round((1:k)*n/(k+1)) #spacing out Beta evenly (L3)
  
  #Current indicator variable is set to 1 intially for all the splits
  I_current= rep(1,k) #current indicator variable (L4)
  
  #Current delta variable
  delta_current=numeric(length = k)
  delta_current=beta_current*I_current# mulitplying beta_i * indicator_i (L5)
  
  iteration=0 # (L6) for consistency with algorithm
  
  # Dataframe container for posterior samples
  I=data.frame(matrix(ncol =k,nrow = (n_iteration/2)) ) # current Indicator (L7)
  Delta=data.frame(matrix(ncol =k,nrow = (n_iteration/2) )) #current Delta (L8)
  
  repeat{                  #L9
    
    iteration=iteration+1  #L10
    
    
    #propose new betas, eq:7 to 11  #L11
    #beta_proposal_matrix= propose_betas(beta_current,n,k) // R implmentation 
    beta_proposal_matrix=beta_proposal_cpp(n=n,k=k,current_betas=beta_current) # Rcpp Implmentation
    
    beta_probabilities<-data.frame(x=beta_proposal_matrix[,1],y=beta_proposal_matrix[,2])
    
    beta_proposed=sample(x=beta_proposal_matrix[,1],size = k,prob = beta_proposal_matrix[,2])
    beta_proposed_sorted=sort(beta_proposed,decreasing = F)
    beta_proposal=beta_proposed_sorted
    
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
    
    
    #Structure learning using Hill Climbing Algorithm #L19 and #L23 partly(adding the loglikelihood)
    #n1=length(D_current)
    
    loglikelihood_D_current_nonzero_deltas=sum(sapply(D_current,Loglikelihood_Calculation_hc))
    
    #for (i in 1:n1) {
    
    #structure learning for subset i of D_proposal dataset
    #     bn<-hc(D_current[[i]],score = 'bde')
    #bayesian dirichlet score #23
    #      loglikelihood_D_current_nonzero_deltas=
    #       loglikelihood_D_current_nonzero_deltas+ score(bn, D_current[[i]], type = "bde")
    
    #  }
    
    
    
    #proposal subset of data #20
    D_proposal=split_index(dataset,delta_proposal_nonzero_sorted)
    
    #Structure learning using Hill Climbing Algorithm #L21 and L25 partly (adding the loglikelihood)
    #n2=length(D_proposal)
    loglikelihood_D_proposal_nonzero_deltas=sum(sapply(D_proposal,Loglikelihood_Calculation_hc))
    #  for (i in 1:n2) {
    
    
    #structure learning for subset i of D_proposal dataset
    #      bn<-hc(D_proposal[[i]],score = 'bde')
    #bayesian dirichlet score #L25
    #      loglikelihood_D_proposal_nonzero_deltas=
    #        loglikelihood_D_proposal_nonzero_deltas+ score(bn, D_proposal[[i]], type = "bde")
    
    #  }
    
    #Prior distribution for current beta varaibles
    U_distribution_current=uniform_distributioncpp(betas = beta_current,n=n,k=k)
    
    #Prior distribution for current Indicator variables 
    I_distribution_current= sum(dbern(x=I_current,prob=0.5,log = TRUE))
    
    #Prior distribution for proposal beta varaibles
    U_distribution_proposal=uniform_distributioncpp(betas = beta_proposal,n=n,k=k)
    
    #Prior distribution for proposal Indicator variables 
    I_distribution_proposal=sum(dbern(x=I_proposal,prob=0.5,log = TRUE))
    
    #adding logarithmic probability current distributions #L24
    log_posterior_D_current=loglikelihood_D_current_nonzero_deltas+U_distribution_current+I_distribution_current
    #cat('\n p(posterior_current_beta_I|D)',log_posterior_D_current)
    
    #adding logarithmic probability proposal distributions #L26
    log_posterior_D_proposal=loglikelihood_D_proposal_nonzero_deltas+ U_distribution_proposal+I_distribution_proposal
    #cat('\n p(posterior_proposal_beta_I|D)',log_posterior_D_proposal)
    
    
    #Transition Probabilities Jp (log scale) #L28
     
    Jp=sum(log(beta_probabilities[c(beta_probabilities$x %in% beta_current),2]))
    
    #Jp=sum(log(.subset2(beta_probabilities,2)[beta_probabilities$x %in% beta_current]))
    #cat('\nJp:',Jp)
    
    
    
    #Transition Probabilities Jc (log scale) #L29
    Jc=sum(log(beta_probabilities[c(beta_probabilities$x %in% beta_proposal),2]))
    #Jc=sum(log(.subset2(beta_probabilities,2)[beta_probabilities$x %in% beta_proposal]))
 #   if(is.na(Jc)){
#      print(beta_proposed)
 #     print(beta_proposal)
  #    temp_df<<-data.frame()
  #    temp_df<<-beta_probabilities
   #   print(beta_probabilities)}
    #cat('\tJc:',Jc)
    #cat('\n')
    
    #Calculating r; #L31
    log_r= (log_posterior_D_proposal-log_posterior_D_current)+(Jc-Jp)
    
    #converting into decimal scale
    r=exp(log_r)
    
    
    #a random sample from uniform distribution from 0 to 1 #L32
    u=runif(1,min = 0,max=1)
    
    #cat('\n log_r ',log_r,'\t r',r )
    #Acceptance Ratio
    #Accept or Reject?  #L33
    if(r>u){
      beta_current=beta_proposal              #L34
      I_current=I_proposal                    #L35
      delta_current=beta_current*I_current    #L36 
      
    }
    
    if(iteration > (n_iteration/2)){       #L39
      index=iteration-(n_iteration/2)
      I[index,]=I_current                  #L40
      Delta[index,]=delta_current          #L41 
    }
    
    if(iteration==n_iteration){break}         #L43
  }
  if(iteration %in% c(10000,20000,30000,40000,50000,60000,70000,80000,90000)){cat('\niteration',iteration)}
  
  ##Finding nonzero deltas #L45
  
  #Marginal mean of each indicator variable
  I_mean=colMeans(I)
  #Converting the marginal mean to binary 1/0
  I_Binary=ifelse(I_mean>0.5,1,0)
  
  #Marginal mean of each Delta variable
  Delta_mean=colMeans(Delta)
  #Rounding the Delta values as it is a position
  Delta_mean_integer=round(Delta_mean)
  
  #Idenfying delta values based on binary Indicator 
  Deltas_tentative=Delta_mean_integer*I_Binary
  #selecting nonzero delta values 
  NonZero_Deltas=subset(Deltas_tentative,Deltas_tentative>0)
  
  #Finding unique non-zero positions 
  Unique_NonZero_Deltas=unique(NonZero_Deltas)
  #sorting the unique non-zero positions in ascending order
  Unique_Sorted_NonZero_Deltas=sort(Unique_NonZero_Deltas,decreasing = FALSE)
  return(Unique_Sorted_NonZero_Deltas)
}