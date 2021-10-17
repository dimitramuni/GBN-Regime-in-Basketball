## Based on work by Bendtsen M. (2017), https://link.springer.com/article/10.1007/s10618-017-0510-5
#This script consist of a helper function used in Collapse.R

#Function combines subsets
Combine_Regime_Child<-function(R,C,i,j){
  
  R_new<-R    #L26
   
  R_new[[i]]=rbind(R_new[[i]],R_new[[j]]) #L27
  
  R_new=R_new[-j] #L28 removing regime j from Rnew and reindexed automatically

  C_new<-C  #L30
  
  cat('\nL:16, C_new')
  print(C_new)
  #L31, regime j's children will be added to regime i's
  #If C_new[[j]] has a child (which is not NA) then append C_new[[j]]-1 with C_new[[i]]

  if(!is.na(C_new[[j]])){# check if C_new[[j]] has any child
    
    if(C_new[[i]]!=C_new[[j]]){
      
        C_new[[i]]<-c(C_new[[i]],C_new[[j]])
         } # here -1 is to account for reindexing
    
    }
  cat('\nL:25C_new ')
  print(C_new)
   
  
  iteration=(1:length(C_new)) #[-i]
  for (k in iteration) { #L32
    
    if(j %in% C_new[[k]]){  #L33
      index=which(C_new[[k]]==j) #finding index of j in C_new[k]
      C_new[[k]]<-C_new[[k]][-index] #deleting j from C_new[k] #L34
      cat('\nL32,C_new ')
      print(C_new)
      if(!(i %in% C_new[k])){
        C_new[[k]]<-c(C_new[[k]],i) #adding i as a child of C_new #L35
      }
      cat('\nL34C_new ')
      print(C_new)  
    } #L37
  }
   #storing reindexing element 
    reindexing_element<-C_new[[j]]
    cat('reindexing element', reindexing_element)
    C_new<-C_new[-j] #L38removing component j from C_nrew 
    #reindexing 
    #check in the each element of C_new list
    cat('Before final reindexing\n')
    print(C_new)
    
    if(j<=length(C_new)){
    for (re_id in 1:length(C_new)) {
      
      #checking if reindexing element in present in C_new[[re_id]]
      if(reindexing_element %in% C_new[[re_id]])
      {
       #finding occurence of reindexing element within C_new[[re_id]]
       inner_index=which(reindexing_element== C_new[[re_id]]) 
       #decreasing the value of by 1 to account for deleted C_new element
       C_new[[re_id]][inner_index]<- C_new[[re_id]][inner_index]-1
      }
      
    }
    }
    
#    if(j<=length(C_new)){
#    for (ind in j:length(C_new)) {
#      C_new[[ind]]<- C_new[[ind]]-1
      
#             }
#     }
    cat('\nL38C_new')
    print(C_new)
  RnewCnew= list(R_new,C_new) #L39
    
  

  
  return(RnewCnew)   
  
}


#as.integer(strsplit(names(Cn[1]),split = '')[[1]][2])
