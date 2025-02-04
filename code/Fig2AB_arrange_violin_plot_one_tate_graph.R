args<-commandArgs()

file<-args[6] #input table
target<-args[7] #column numbers of alpha diversitys(ASV,shannon,...)
cols<-args[8]  #column of targets features(Cancer)
size<-as.numeric(args[9]) #picuture size (0.8)
outfile<-args[10] #name of output pdf

library("vioplot")
library("dplyr")

targets<-as.numeric(unlist(strsplit(target,",")))
column<-as.numeric(unlist(strsplit(cols,",")))
print(targets)
pdf(outfile)
par(mfrow=c(1,1))
df<-read.table(file,sep="\t",header=T)


for (i in column){
  for (j in targets){
      df_small<-df[,c(i,j)]

      df_small<-subset(df_small,df_small[,1]!="-")
      df_small<-droplevels(df_small)
      p_t_test<-""
      if(length(names(table(df_small[,1])))==2){
	   if(table(df_small[,1])[1]==1 || table(df_small[,1])[2]==1){ 		
	   	p_t_test<-"not enough data for t.test"			     
	   } else {
	   	p_t_test<-signif(t.test(df_small[,2]~df_small[,1])$p.value,digits=3) 
	   }
       } else if(length(names(table(df_small[,1])))==1){
	 p_t_test<-"All value is same"
       } else {
       	 p_t_test<-kruskal.test(df_small[,2]~df_small[,1])$p.value
       }
       df1<-data.frame(Cancer=df_small[,1],val=df_small[,2])
       df1 %>% group_by(Cancer) %>% count(Cancer) %>% mutate(Cancer_num =paste(!!!rlang::syms(c("Cancer","n")),sep="-"))->df2
       inner_join(df1,df2,by="Cancer") ->df3
       df3 %>% group_by(Cancer_num) %>% summarise(Median=median(val)) %>% arrange(Median)  %>% select(Cancer_num) ->order
       x1<-factor(df3$Cancer_num,levels=as.vector(unlist(order)))

       vioplot(df3$val~x1,main=names(df_small)[1],,cex.axis=size,las=3,xlab="",ylab=names(df_small)[2])
   }
}
dev.off()


