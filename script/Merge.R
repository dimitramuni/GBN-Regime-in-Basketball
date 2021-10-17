## Mergining Regimes identified by nonzero delts in the data set
## Based on work  by Bendtsen M. (2017), https://link.springer.com/article/10.1007/s10618-017-0510-5
## See Appendix A.2

source('Collapse.R')
require(textshape)
require(bnlearn)
require(Rlab)
Unique_Sorted_NonZero_Deltas<-c(500,2500,3100,4200)
nonzero_delta_from_Identify<-Unique_Sorted_NonZero_Deltas

#Merge Function #L1
#Merge_Regimes<-function(dataset,nonzero_delta_from_Identify){
dataset=asia
#splitting D into subsets #L2 and #L3
R<-split_index(dataset,nonzero_delta_from_Identify)

#Container to store Child Regime(s) of corresponding Parent Regime
#C<-numeric(length =length(R))
#function to generate column names
#f_ColumnName<-function(i){return(paste0('C',i))}
#using sapply to call the function above
#C_ColumnName<-sapply(X=1:length(R),FUN=f_ColumnName)


#first regime has 2 as the child regime and last regime does not have any child regime
C=as.list(c(2:length(R),NA))
#assigning column names to vector positions of C
#names(C)<-C_ColumnName

#container for all possible structuers #L7
RC<-list(R,C)

#L8 Collapse(R,C,RC)
Cn<<-list(C)
Rn<<-list(R)
Collapse_Regime_Child(R,C,RC)

delete_indicies=c()
for (i in 1:(length(Cn))) {
  
  if(1 %in% Cn[[i]][[1]]){delete_indicies=c(delete_indicies,i)}
  if(2 %in% Cn[[i]][[2]]){delete_indicies=c(delete_indicies,i)}

}
Cn<<-Cn[-c(unique(delete_indicies))]
Rn<<-Rn[-c(unique(delete_indicies)) ]
#Finding R and C which maximise the posterior distribution #L9
#structure learning for each (R,C) pair

structure_score=c()
for (structure_index in 1:length(Rn) ) {
  
  
  regime_score=c()
  for (regime_index in 1:length(Rn[[structure_index]])) {
    
    bn<-hc(Rn[[structure_index]][[regime_index]],score = 'bde')
    regime_score=c(regime_score,score(bn, Rn[[structure_index]][[regime_index]], type = "bde"))
    
  }
  
  structure_score=c(structure_score,sum(regime_score))
  
}

#Finding out R and C; for which maximises posterior from equation#6
#L9
which.max(structure_score)



