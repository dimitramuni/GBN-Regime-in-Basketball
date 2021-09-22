## Mergining Regimes identified by nonzero delts in the data set
## Based on work  by Bendtsen M. (2017), https://link.springer.com/article/10.1007/s10618-017-0510-5
## See Appendix A.2
source('Collapse.R')
nonzero_delta_from_Identify<-Unique_Sorted_NonZero_Deltas

#Merge Function #L1
#Merge_Regimes<-function(dataset,nonzero_delta_from_Identify){

#splitting D into subsets #L2 and #L3
R<-split_index(dataset,nonzero_delta_from_Identify)

#Container to store Child Regime(s) of corresponding Parent Regime
C<-numeric(length =length(R))
#function to generate column names
f_ColumnName<-function(i){return(paste0('C',i))}
#using sapply to call the function above
C_ColumnName<-sapply(X=1:length(R),FUN=f_ColumnName)


#first regime has 2 as the child regime and last regime does not have any child regime
C=as.list(c(2:length(R),NA))
#assigning column names to vector positions of C
#names(C)<-C_ColumnName

#container for all possible structuers #L7
RC<-list(R,C)

#L8 Collapse(R,C,RC)

RC_new=Collapse_Regime_Child(R,C,RC)

#Finding R and C which maximise the posterior distribution #L9
#structure learning for each (R,C) pair
for (index in 1:len(RC_new[[1]]) ) {
  
  
  bn<-hc(RC_new[[1]][[index]],score = 'bde')
  bn_score=c(bn_score,score(bn, RC_new[[1]][[index]], type = "bde"))
}

#Finding out R and C; for which maximises posterior from equation#6
#L9
which.max(bn_score)

