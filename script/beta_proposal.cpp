#include <Rcpp.h>
using namespace Rcpp;
// [[Rcpp::export]]


NumericMatrix beta_proposal_cpp(int n, int k, NumericVector current_betas) {
  NumericMatrix probmat(n-k+1, 2);
  double Kappa=0,upper_bound_beta_proposal=0,lower_bound_beta_proposal=0;
  double Z1=0,Z2=0,Z=0;
  double index=0;
  for(int j=0;j < k; j++){
    

    if(j==0){
      lower_bound_beta_proposal=1;
    }
    else{
      double beta_temp_difference1= (current_betas[j] -current_betas[j-1])/2;

      lower_bound_beta_proposal= current_betas[j]-floor(beta_temp_difference1) +1;
    }
  

  
    if(j== (k-1)){
      upper_bound_beta_proposal=n;
      }
  
  else{  
    double beta_temp_difference2= (current_betas[j+1] -current_betas[j])/2;
    upper_bound_beta_proposal= current_betas[j]+floor(beta_temp_difference2)-1;
      }


  double t1=current_betas[j]-lower_bound_beta_proposal;
  double t2=upper_bound_beta_proposal-current_betas[j];
 
  
  if(t1>t2){
    Kappa=t1;
  }
  else if (t1<t2){
    Kappa=t2;
  }
  
  Z1=0;
  if(current_betas[j]>=lower_bound_beta_proposal){
    
      for (int i=lower_bound_beta_proposal;i<=current_betas[j];i++) {
        
        Z1=Z1+1+i-current_betas[j]+Kappa;
      }
    }
  Z2=0;
    if(upper_bound_beta_proposal >= (current_betas[j]+1) ){
      
      for (int i=(current_betas[j]+1);i<=upper_bound_beta_proposal;i++){
        
        Z2=Z2+1-i+current_betas[j]+Kappa;
      }
    }
    Z=Z1+Z2 ;
    
    
    
    if(current_betas[j]>=lower_bound_beta_proposal){
      
      for (int i=lower_bound_beta_proposal;i<=current_betas[j];i++) {
        
        probmat(index,0)=i;
        probmat(index,1)=(1+i-current_betas[j]+Kappa)/Z ;
        index=index+1;
        
      }
    }
    
    if(upper_bound_beta_proposal >= (current_betas[j]+1) ){
      
      for (int i=(current_betas[j]+1);i<=upper_bound_beta_proposal;i++){
       
        probmat(index,0)=i;
        probmat(index,1)=(1-i+current_betas[j]+Kappa)/Z ;
        index=index+1;
        
      }
    }
    
  }
  
  //Rcpp::NumericVector candidates=probmat(_,0);
  //Rcpp::NumericVector probabilities(probmat(_,1));
  
  //NumericVector sp=RcppArmadillo::sample(candidates,n-k+1,FALSE,probabilities) [0];

    
  return(probmat);
}



/*** R
beta_proposal_cpp(n=39,k=2,current_betas=c(15,25))
*/

