#include <Rcpp.h>
using namespace Rcpp;

// [[Rcpp::export]]
double uniform_distributioncpp(NumericVector betas,int n, int k) {
  
  double U_log=0;
  //sorting the beta values in increasing order
  NumericVector betas_sorted=betas.sort(false); 

  for(int i=0;i<k;i++){
    
    if(i==0){
      U_log=U_log+ R::dunif(betas_sorted[i],0,betas_sorted[i+1],true);
    }
    
    else if(i==(k-1)){
      U_log=U_log+ R::dunif(betas_sorted[i],betas_sorted[i-1],n+1,true);
    }
    
    else{
      U_log=U_log+ R::dunif(betas_sorted[i],betas_sorted[i-1],betas_sorted[i+1],true) ;
    }
  }
  
  return U_log;
}