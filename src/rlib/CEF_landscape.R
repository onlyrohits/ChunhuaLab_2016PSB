library(ggplot2)
library(methods)
library(plyr)
library(igraph)
rm(list=ls())
source("./util.R")
groups = c('inclusion','exclusion')#c("exclusion","inclusion")

source.file =list()
i=0
for (group in groups){
  i=i+1
  source.file[i] <-c(paste("../../result/",group,"/allData_table",sep = ""))
}
allFreq.in<-read.table(source.file[[1]],sep='\t',header = T,row.names=NULL)#table with each col represents a variable
allFreq.ex<-read.table(source.file[[2]],sep='\t',header = T,row.names=NULL)#table with each col represents a variable
allFreq.pub<-read.table('../../result/pubmed/allData_table',sep='\t',header = T,row.names=NULL)#table with each col represents a variable

id2.in<-allFreq.in[,2]
id2.ex<-allFreq.ex[,2]
features.in<-allFreq.in[,3]
features.ex<-allFreq.ex[,3]
rate.in <- allFreq.in[,4]
rate.ex <- allFreq.ex[,4]

#output cde ranking list for all diseases
out.table1 <- c(paste('../../result/Comparison_in_ex/Table1_Top_CEFs_for_mental_disorders',sep=''))
out.table2<-'../../result/Comparison_in_ex/Table2_Disease_have_most_CEFs'
out.table3<-'../../result/Comparison_in_ex/Table3_Top_Semantic_Types'
out.pdf <- c(paste('../../result/Comparison_in_ex/CEF_analysis.pdf',sep=''))
pdf(out.pdf)
a<-adply(sort(table(features.ex),decreasing=T),1)
colnames(a)<-c('CEF','Ex_count')
b<-adply(sort(table(features.in),decreasing=T),1)
names(b)<-c('CEF','In_count')
ranking.df<-merge(a,b,by='CEF',all=T)
ranking.df[is.na(ranking.df)] <- 0
print(colMeans(ranking.df[,2:3]))
#table1
write.table(ranking.df,out.table1,quote=F,sep='\t',col.names=T,row.names=F)#top20
#plot1
plot(row.names(ranking.df),ranking.df[,2],main='CEF distribution between different mental disorders',xlab='CEF Index',ylab='Disease Count',type='h',col='chocolate1')
points(ranking.df[,3],col='palegreen3',type='l')
legend(950, 85, c("Exclusion",'Inclusion'), col = c('chocolate1','palegreen3'),text.col = "black",lty = c(1, 1),cex=1.3,bg = "gray90")
#plot2
num.featuresInDisease.ex<-sort(table(id2.ex),decreasing=T)
plot(sort(num.featuresInDisease.ex,decreasing = T),pch=1,lwd=2,lty=3,type='b',xlab='Disease Index',ylab='CEF Count',main='The counts of CEFs of each condition',col="chocolate1")
x.names <- names(sort(num.featuresInDisease.ex,decreasing = T))
abline(h=mean(num.featuresInDisease.ex),lty=3)
num.featuresInDisease.in<-sort(table(id2.in),decreasing=T)
points(sort(num.featuresInDisease.in,decreasing = T),lty=4,lwd=2,pch=22,type='b',col="palegreen3")
x.names <- names(sort(num.featuresInDisease.in,decreasing = T))
abline(h=mean(num.featuresInDisease.in),lty=4)
legend(58, 230, c("Exclusion",'Inclusion'), col = c('chocolate1','palegreen3'),text.col = "black",pch=c(1,22),lwd=c(3,3),lty = c(3, 4),cex=1.3,bg = "gray90")
#table2
d1<-as.data.frame.table(num.featuresInDisease.ex)
d2<-as.data.frame.table(num.featuresInDisease.in)
colnames(d2)<-c('id','Freq')
colnames(d1)<-c('id','Freq')
d<-merge(d1,d2,by='id')
colnames(d)<-c('Disease Name','Exclusion Count','Inclusion Count')
write.table(d[order(d[,2],d[,3],decreasing=T),],out.table2,quote=F,sep='\t',col.names=T,row.names=F)
#plot3
p1 <- hist(num.featuresInDisease.ex,breaks=seq(min(num.featuresInDisease.in,num.featuresInDisease.ex),max(num.featuresInDisease.in,num.featuresInDisease.ex),l=20),plot=F)                     # centered at 4
p2 <- hist(num.featuresInDisease.in,breaks=seq(min(num.featuresInDisease.in,num.featuresInDisease.ex),max(num.featuresInDisease.in,num.featuresInDisease.ex),l=20),plot=F)                     # centered at 6
plot( p2, col=rgb(124,205,124,150,max=255),main='Distribution of Disease Count in CEF',xlab='CEF Count',ylab='Disease Count')  # second,palegreen3,in
plot( p1, col=rgb(255,127,36,150,max=255),add=T)  # first histogram,chocolate1,ex
legend(150, 20, c("Exclusion",'Inclusion'), col = c('chocolate1','palegreen3'),text.col = "black",lwd=c(3,3),lty = c(1, 1),bg = "gray90")

#plot4,st
source.freq.ex <-c(paste("../../result/exclusion/allData_table",sep = ""))
source.st.ex <-c(paste("../../result/exclusion/allST_sep",sep = ""))
source.freq.in <-c(paste("../../result/inclusion/allData_table",sep = ""))
source.st.in <-c(paste("../../result/inclusion/allST_sep",sep = ""))
allFreq.ex <- read.table(source.freq.ex,sep = '\t',header = T, row.names=NULL)
allST.ex <- read.table(source.st.ex,sep='\t', row.names=NULL)
allFreq.in <- read.table(source.freq.in,sep = '\t',header = T, row.names=NULL)
allST.in <- read.table(source.st.in,sep='\t', row.names=NULL)
id1.ex<-allFreq.ex[,1]
DiseaseName.ex<-allFreq.ex[,2]
CDE.ex<-allFreq.ex[,3]
Freq.ex<-allFreq.ex[,4]
SemanticType.ex<-allFreq.ex[,5]
id1.in<-allFreq.in[,1]
DiseaseName.in<-allFreq.in[,2]
CDE.in<-allFreq.in[,3]
Freq.in<-allFreq.in[,4]
SemanticType.in<-allFreq.in[,5]
cde.in.ST.ex<-list()
for (st in allST.ex$V1){
  cde.candi <- CDE.ex[grepl(st, SemanticType.ex)] 
  cde.unique <- length(unique(cde.candi))#can be changed if want actuall cdes in ST
  cde.in.ST.ex[[st]] <- cde.unique
}
cde.in.ST.ex <- sort(unlist(cde.in.ST.ex,use.names= T),decreasing = T)

cde.in.ST.in<-list()
for (st in allST.in$V1){
  cde.candi <- CDE.in[grepl(st, SemanticType.in)] 
  cde.unique <- length(unique(cde.candi))#can be changed if want actuall cdes in ST
  cde.in.ST.in[[st]] <- cde.unique
}
cde.in.ST.in <- sort(unlist(cde.in.ST.in,use.names= T),decreasing = T)
#table3,top ST
c1<-as.data.frame(cde.in.ST.ex,row.names=NULL)
c2<-as.data.frame(cde.in.ST.in,row.names=NULL)
c1$st<-rownames(c1)
c2$st<-rownames(c2)
c<-merge(c1,c2,by='st')
c<-c[order(c[,2],c[,3],decreasing=T),]
colnames(c)<-c('Semantic Type','Exclusion Count','Inclusion Count')
write.table(c,out.table3,quote=F,sep='\t',col.names=T,row.names=F)
dat <- rbind(cde.in.ST.ex, cde.in.ST.in)
#bar<-barplot(dat, beside=TRUE, space=c(0, 0.1),las=2,col = c('chocolate1','palegreen3'),ylab='CEF Count',axes = FALSE, axisnames = FALSE,main="CEF distribution in UMLS semantic types")
#bar<-barplot(dat, beside=TRUE, space=c(0, 0.1),las=2,col = c('chocolate1','palegreen3'),ylab='CEF Count',axes = F, axisnames = F,main="CEF distribution in UMLS semantic types")#colored, not for black-white printer
bar<-barplot(dat,angle = 15+100*1:2,density = 20, beside=TRUE, space=c(0, 0.1),las=2,col = c('chocolate1','palegreen3'),ylab='CEF Count',axes = F, axisnames = F,main="CEF distribution in UMLS semantic types")#shaded
labels<-attributes(dat)$dimnames[[2]]
text(bar[1,]+.5, par("usr")[3], labels = labels, srt = 45, adj = 1,cex=0.5, xpd = TRUE)
legend(40, 300, c("Exclusion",'Inclusion'), col = c('chocolate1','palegreen3'),text.col = "black",lwd=c(3,3),lty = c(1, 1),bg = "gray90")
axis(2)

#overlap


inter<-intersect(features.ex,features.in)
diff.ex<-setdiff(features.ex,features.in)
diff.in<-setdiff(features.in,features.ex)

dev.off()

