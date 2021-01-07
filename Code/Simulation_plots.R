###############################
# Author:
# Marco A. Aquino-López
# Code:
# Plot results from multiple simulation
# 
###############################
rm(list = ls()) 	# clean R environment
library(stringr)
library(ggplot2)
library(magrittr)
library(multipanelfigure)
library(quantreg)
setwd('~/OwnCloud-NicoleKS/Plum vs CRS/Sampling and percentages/')
source('~/OwnCloud-NicoleKS/Plum vs CRS/Sampling and percentages/CRS.R')

if (FALSE){
  acc_pre <- function(id,crv){
    fls   <- list.files(paste0("./Plum_runs/",id))
    fls   <- fls[str_detect(fls, "_ages.txt", negate = FALSE)]
    dts   <- read.table(paste0("./Plum_runs/",id,"/",fls),header = T,sep = '\t')
    #Aqui se calculan los promedios de errores. 
    lista <- matrix(c(dts$depth,abs(dts$mean - crv(dts$depth)),dts$max -dts$min),ncol=3  )
    
    colnames(lista) <- c("Depth", "Accuracy","precision")
    write.csv(lista,paste0("./Plum_runs/",id,"/accuracy_precision.csv"),row.names = F)
  }
}

#Generate data base
fls   <- list.files(paste0("./Plum_runs/"))
df    <- data.frame(NULL)
nms   <- c()
simid <- c()
dtp   <- 28
for (i in fls){
  splt      <- unlist(strsplit(i,'_'))
  if (splt[1]=="Sim01"){Simu=sim1}else{
    if (splt[1]=="Sim02"){Simu=sim2}else{
      if (splt[1]=="Sim03"){Simu=sim3}
    }
  } ; print(i)
  # get info about the simulation
  # plum acc and pre
  file_accPlum <- paste0("./Plum_runs/",i,"/accuracy_precision.csv")
  
  if(file.exists(file_accPlum)){
    dts       <- read.table(file_accPlum,header = T,sep = ',')
  }else{
    acc_pre(i,Simu)
    dts       <- read.table(file_accPlum,header = T,sep = ',')
  }
  dts       <- dts[-1,]
  
  # CRS acc and pre
  file_accCRS <- paste0("./Plum_runs/",i,"/CRSaccuracy_precision.csv")
  #if(file.exists(paste0("./Plum_runs/",i,"/",i,".csv")) | file.exists(file_accCRS) ){
  if(file.exists(file_accCRS)){
    crs       <- read.table(file_accCRS,header = T,sep = ',')
  }else{
    acc_preCRS(i,Simu)
    crs       <- read.table(file_accCRS,header = T,sep = ',')
  }
  #
  
  crs$NAccuracy        <- crs$Accuracy/crs$Precision
  crs$Precision        <- 4 * crs$Precision #CRS provides a standard deviation
  dts$NAccuracy        <- 4 * dts$Accuracy/dts$precision
  #dts$precision       <- dts$precision/4
  dts$info  <- as.numeric(splt[2])
  if (c(crs$Depth[1]!=0 )  ){
    # this one does means
    tmp       <- c(colMeans(dts[crs$Depth,c(5,2:4)]), colMeans(crs[,2:4]) )
    # this one does single depths
    #tmp       <- c(as.numeric(dts[dtp,2:4]),approx(crs$Depth,4*crs$Accuracy/crs$Precision,dtp,rule=2)$y,approx(crs$Depth,crs$Precision,dtp,rule=2)$y)
    df        <- rbind(df, tmp )
    nms       <- c(nms,i)
    simid     <- c(simid,splt[1])
  }
  #}
}

colnames(df) <- c("Information_percentage", "Accuracy", "Precision", "NormAccuracy" ,"CRS_Accuracy","CRS_Precision","CRS_NormAccuracy")
df$Names <-nms
df$Simulation <-simid
rownames(df)<- nms

## Plots
#pdf("../Fig/Acc_prec.pdf", width=8.5, height=9.5)
accplot <- ggplot(df, aes(x=Information_percentage)) + 
  geom_quantile(aes(y = Accuracy),size=.5,alpha=.5,color="blue",method = "rqss") +
  geom_point(aes(y = Accuracy),size=.7,alpha=.1,color='blue') +
  geom_quantile(aes(y = CRS_Accuracy),size=.5,alpha=.5,color="red",method = "rqss") +
  geom_point(aes(y = CRS_Accuracy),size=.7,alpha=.1,color='red') +
  xlim(10, 100) + ylim(0, 100) + 
  labs(title = "A) Offset", x = "", y = "yr", color = "% Inf")

# accplot

preplot <-  ggplot(df, aes(Information_percentage)) + 
  geom_quantile(aes(y = Precision),color="blue",alpha=.4,method = "rqss")+
  geom_point(aes(y = Precision),size=.5,alpha=.1,color="blue") +
  geom_quantile(aes(y = CRS_Precision),color="red",alpha=.4,method = "rqss")+
  geom_point(aes(y = CRS_Precision),size=.5,alpha=.1,color="red") +  
  labs(title ="B) Length 95% interval" , x = "", y ="yr")  + xlim(10, 100) + ylim(0, 100) 

# preplot

naccplot <- ggplot(df, aes(Information_percentage)) + 
  geom_quantile(aes(y = NormAccuracy),size=.5,alpha=.5,color="blue",method = "rqss") +
  geom_point(aes(y = NormAccuracy),size=.7,alpha=.1,color='blue') +
  geom_quantile(aes(y = CRS_NormAccuracy),size=.5,alpha=.5,color="red",method = "rqss") +
  geom_point(aes(y = CRS_NormAccuracy),size=.7,alpha=.1,color='red') +
  xlim(10, 100) + ylim(0, 5) + 
  labs(title = "C) Normalized Offset", x = "% of information", y = "", color = "% Inf")

# naccplot

#dev.off()
figure1 <- multi_panel_figure(columns = 1, rows = 3, panel_label_type = "none")

pdf("~/github/Paper_Simulations/Manuscript/Figures/AccPrec.pdf", width=8, height=10)
# figure1 %<>%
#   fill_panel(accplot, column = 1, row = 1) %<>%
#   fill_panel(preplot , column = 1, row = 2) %<>%
#   fill_panel(naccplot , column = 1, row = 3)
# figure1
dev.off()

pdf("~/github/Paper_Simulations/Manuscript/Figures/AccPrec.pdf", width=8, height=10)
multiplot(accplot,preplot,naccplot,cols=1)
dev.
#################################
# ver si hay algun patron en el sampling
################
# all colors 


pdf("../Fig/models.pdf")
ggplot(df, aes(x=NormAccuracy,y = Precision)) +  
  geom_point(aes(colour = Information_percentage),size=.7,alpha=.2) +
  geom_density2d(aes(colour = Information_percentage ),col='red' ,alpha=.3) +
  scale_colour_gradientn(colours=rainbow(5)) + 
  labs(title = "Plum", x = "Normalized Offset", y = "Length 95% interval (yr)", color = "% Inf") +
  xlim(0, 10) + ylim(0, 100)+ geom_vline(xintercept = c(1,2),alpha=.45,color='green' )

ggplot(df, aes(x=NormAccuracy,y = Precision)) +  
  scale_colour_gradientn(colours=rainbow(5)) + 
  geom_point(aes(x=CRS_NormAccuracy,y = CRS_Precision,colour = Information_percentage),size=.7,alpha=.2) +
  geom_density2d(aes(x=CRS_NormAccuracy,y = CRS_Precision,colour = Information_percentage ) ,color='red',alpha=.3) +
  scale_colour_gradientn(colours=rainbow(5)) + 
  labs(title = "CRS", x = "Normalized Offset", y = "Length 95% interval (yr)", color = "% Inf") +
  xlim(0, 10) + ylim(0, 100)+ geom_vline(xintercept = c(1,2),alpha=.45,color='green' )


ggplot(df) +  
  geom_point(aes(x=NormAccuracy,y = Precision),size=.7,alpha=.1,color='blue') +
  geom_density2d(aes(x=NormAccuracy,y = Precision,colour = Information_percentage ),col='blue' ) +
  geom_point(aes(x=CRS_NormAccuracy,y = CRS_Precision),size=.7,alpha=.1,color='red') +
  geom_density2d(aes(x=CRS_NormAccuracy,y = CRS_Precision,colour = Information_percentage ) ,color='red') +
  labs(title = "CRS", x = "Normalized Offset", y = "Length 95% interval (yr)", color = "% Inf") +
  geom_vline(xintercept = c(1,2),alpha=.45,color='green' ) + 
  xlim(0, 10) + ylim(0, 100)
dev.off()


figure2 <- multi_panel_figure(columns = 1, rows = 2, panel_label_type = "none")

Plummap <- ggplot(df, aes(x=NormAccuracy,y = Precision)) +  
  geom_point(aes(colour = Information_percentage),size=.7,alpha=.2) +
  geom_density2d(aes(colour = Information_percentage ),col='red' ,alpha=.3) +
  scale_colour_gradientn(colours=rainbow(5)) + 
  labs(title = "A) Plum", x = "", y = "Length 95% interval (yr)", color = "% Inf") +
  xlim(0, 10) + ylim(0, 100)+ geom_vline(xintercept = c(1,2),alpha=.45,color='green' )

CRSmap <- ggplot(df, aes(x=NormAccuracy,y = Precision)) +  
  scale_colour_gradientn(colours=rainbow(5)) + 
  geom_point(aes(x=CRS_NormAccuracy,y = CRS_Precision,colour = Information_percentage),size=.7,alpha=.2) +
  geom_density2d(aes(x=CRS_NormAccuracy,y = CRS_Precision,colour = Information_percentage ) ,color='red',alpha=.3) +
  scale_colour_gradientn(colours=rainbow(5)) + 
  labs(title = "B) CRS", x = "Normalized Offset (sd)", y = "Length 95% interval (yr)", color = "% Inf") +
  xlim(0, 10) + ylim(0, 100)+ geom_vline(xintercept = c(1,2),alpha=.45,color='green' )

pdf("../Fig/Maps.pdf", width=8.5, height=9.5)
figure2 %<>%
  fill_panel(Plummap, column = 1, row = 1) %<>%
  fill_panel(CRSmap , column = 1, row = 2)
figure2
dev.off()

# Percentages 
## Plum no more than 2 sd
sum(df$NormAccuracy<2)/length(df$Precision)
sum(df$NormAccuracy<2)

sum(df$NormAccuracy<1)/length(df$Precision)
sum(df$NormAccuracy<1)



df$Names[which(df$CRS_NormAccuracy<2)]

## CRS no more than 2 sd
sum(df$CRS_NormAccuracy<2)/length(df$CRS_Precision)
sum(df$CRS_NormAccuracy<2)
sum(df$CRS_Precision>100)
sum(df$CRS_NormAccuracy<1)/length(df$CRS_Precision)
sum(df$CRS_NormAccuracy<1)
sum(df$CRS_Precision>100)

sum(df$NormAccuracy>2)
sum(simu3$NormAccuracy>2)



sum(simu3$NormAccuracy>2)/sum(simu3$NormAccuracy>0)
sum(simu1$NormAccuracy>2)/sum(simu1$NormAccuracy>0)
sum(simu2$NormAccuracy>2)/sum(simu2$NormAccuracy>0)


# By simulation
pdf("../Fig/by_info.pdf")
ggplot(df) +  
  geom_point(aes(x=NormAccuracy,y = Precision,colour= Simulation ),size=.7,alpha=.2) +
  #geom_density2d(aes(x=Accuracy,y = Precision,colour = Simulation ) ) +
  labs(title = "CRS", x = "Normalized Offset", y = "Length 95% interval (yr)", color = "% Inf") +
  xlim(0, 10) + ylim(0, 100)+ geom_vline(xintercept = c(1,2),alpha=.45,color='green' )

ggplot(df) +  
  geom_point(aes(x=CRS_NormAccuracy,y = CRS_Precision,colour= Simulation ),size=.7,alpha=.2) +
  #geom_density2d(aes(x=CRS_Accuracy,y = CRS_Precision,colour = Simulation ) ) +
  labs(title = "CRS", x = "Normalized Offset", y = "Length 95% interval (yr)", color = "% Inf") +
  xlim(0, 10) + ylim(0, 100)+ geom_vline(xintercept = c(1,2),alpha=.45,color='green' )


#divited by information %

ggplot(df) +  
  geom_point(aes(x=NormAccuracy,y = Precision,colour ="blue"),size=.7,alpha=.2) +
  geom_point(aes(x=CRS_NormAccuracy,y = CRS_Precision,colour="red"),size=.7,alpha=.2) +
  labs(title = "", x = "Normalized Offset", y = "Length 95% interval (yr)",col="") +
  facet_wrap(vars(Information_percentage)) + scale_color_manual(labels = c("Plum", "CRS"), values = c("blue", "red"))  +
  xlim(0, 10) + ylim(0, 50)+theme(legend.position = c(0.9, 0.1),legend.direction="vertical")




simu1 <- df[which(df$Simulation=="Sim01"),]
ggplot(simu1) +  
  geom_point(aes(x=NormAccuracy,y = Precision,colour='blue'),size=.7,alpha=.3) +
  geom_point(aes(x=CRS_NormAccuracy,y = CRS_Precision,colour='red'),size=.7,alpha=.3) +
  labs(title = "Simulation 1", x = "Normalized Offset", y = "Length 95% interval (yr)",col="") +
  facet_wrap(vars(Information_percentage)) + scale_color_manual(labels = c("Plum", "CRS"), values = c("blue", "red"))  +
  xlim(0, 10) + ylim(0, 150)+theme(legend.position = c(0.9, 0.1),legend.direction="vertical")+
  geom_vline(xintercept = c(1,2),alpha=.45,color='green' )




simu2 <- df[which(df$Simulation=="Sim02"),]
ggplot(simu2) +  
  geom_point(aes(x=NormAccuracy,y = Precision,colour='blue'),size=.7,alpha=.3) +
  geom_point(aes(x=CRS_NormAccuracy,y = CRS_Precision,colour='red'),size=.7,alpha=.3) +
  labs(title = "Simulation 2", x = "Normalized Offset", y = "Length 95% interval (yr)",col="") +
  facet_wrap(vars(Information_percentage)) + scale_color_manual(labels = c("Plum", "CRS"), values = c("blue", "red"))  +
  xlim(0, 10) + ylim(0, 150)+theme(legend.position = c(0.9, 0.1),legend.direction="vertical")+
  geom_vline(xintercept = c(1,2),alpha=.45,color='green' )




simu3 <- df[which(df$Simulation=="Sim03"),]
ggplot(simu3) +  
  geom_point(aes(x=NormAccuracy,y = Precision,colour='blue'),size=.7,alpha=.3) +
  geom_point(aes(x=CRS_NormAccuracy,y = CRS_Precision,colour='red'),size=.7,alpha=.3) +
  labs(title = "Simulation 3", x = "Normalized Offset", y = "Length 95% interval (yr)",col="") +
  facet_wrap(vars(Information_percentage)) + scale_color_manual(labels = c("Plum", "CRS"), values = c("blue", "red"))  +
  xlim(0, 10) + ylim(0, 150)+theme(legend.position = c(0.9, 0.1),legend.direction="vertical")+
  geom_vline(xintercept = c(1,2),alpha=.45,color='green' )

dev.off()



preplot <-  ggplot(simu2, aes(Information_percentage)) + 
  geom_quantile(aes(y = Precision),color="blue",alpha=.4,method = "rqss")+
  geom_point(aes(y = Precision),size=.5,alpha=.1,color="blue") +
  geom_quantile(aes(y = CRS_Precision),color="red",alpha=.4,method = "rqss")+
  geom_point(aes(y = CRS_Precision),size=.5,alpha=.1,color="red") +  
  labs( x = "% of information", y = "Length 95% interval (yr)")  + xlim(0, 100) + ylim(0, 100) 


preplot



# Complete the data base.
# 
# library(prob)
# fls <- list.files(paste0(getwd(),"/Plum_runs/") )
# 
# for (i in c("Sim01","Sim02","Sim03")){
#   for (p in seq(.10,.9,by=.05)){
#     for (n in 1:100){
#       foldertocheck = paste(i,100*p,formatC(n,width = 3,flag="0"),sep="_")
#       if (!isin(fls,foldertocheck)){
#         print(foldertocheck)
#       }
#     }
#   }
# }
# 
# 


#####################################
#####################################
#####################################

oldpar <- par()

par(mfrow=c(2, 3))

#Generate data base
fls   <- list.files(paste0("./Plum_runs/"))
df    <- data.frame(NULL)
nms   <- c()
simid <- c()
dtp   <- 28

xlabel= '' # use for plum only

for (i in fls){
  splt      <- unlist(strsplit(i,'_'))
  if (splt[1]=="Sim01"){Simu=sim1
    colo='blue'
    ylabel="Normalized Offset"
    mainlabel = "CRS \n Scenario 1"#"Plum" # Cambiar para plum y para CRS
    
  }else{
    if (splt[1]=="Sim02"){Simu=sim2
      colo = "red"
      ylabel=""
      mainlabel = "\n Scenario 2" # Cambiar para plum y para CRS
    }else{
      if (splt[1]=="Sim03"){Simu=sim3
      colo = "green"
      ylabel=""
      mainlabel = "\n Scenario 3" # Cambiar para plum y para CRS
      }
    }
  } ; print(i)
  file_accPlum <- paste0("./Plum_runs/",i,"/accuracy_precision.csv")
  if(file.exists(file_accPlum)){
    dts       <- read.table(file_accPlum,header = T,sep = ',')
  }else{
    acc_pre(i,Simu)
    dts       <- read.table(file_accPlum,header = T,sep = ',')
  }
  
  # CRS acc and pre
  file_accCRS <- paste0("./Plum_runs/",i,"/CRSaccuracy_precision.csv")
  if(file.exists(file_accCRS)){
    crs       <- read.table(file_accCRS,header = T,sep = ',')
  }else{
    acc_preCRS(i,Simu)
    crs       <- read.table(file_accCRS,header = T,sep = ',')
  }
  
  crs$NAccuracy        <- crs$Accuracy/crs$Precision
  crs$Precision        <- 4 * crs$Precision #CRS provides a standard deviation
  if(splt[3]=="001" & splt[2]=="10"){
    plot(crs$Depth,crs$NAccuracy,col=rainbow(19,end= .9,alpha = .01)[1],ylim = c(0,10),xlim=c(0,30),pch=16,ylab = ylabel, xlab=xlabel  , main = mainlabel)
  }else{
    points(crs$Depth,crs$NAccuracy,col=rainbow(19,end= .9,alpha = .01)[as.numeric(splt[2])/5-1]  ,pch=16 )

  }
}

## For Plum ##
xlabel= 'Depth (cm)' # use for plum only

for (i in fls){
  splt      <- unlist(strsplit(i,'_'))
  if (splt[1]=="Sim01"){Simu=sim1
  colo='blue'
  ylabel="Normalized Offset"
  mainlabel = "Plum"
  
  }else{
    if (splt[1]=="Sim02"){Simu=sim2
    colo = "red"
    ylabel=""
    mainlabel = "" # Cambiar para plum y para CRS
    }else{
      if (splt[1]=="Sim03"){Simu=sim3
      colo = "green"
      ylabel=""
      mainlabel = "" # Cambiar para plum y para CRS
      }
    }
  } ; print(i)
  # get info about the simulation
  # plum acc and pre
  file_accPlum <- paste0("./Plum_runs/",i,"/accuracy_precision.csv")
  
  if(file.exists(file_accPlum)){
    dts       <- read.table(file_accPlum,header = T,sep = ',')
  }else{
    acc_pre(i,Simu)
    dts       <- read.table(file_accPlum,header = T,sep = ',')
  }
  dts       <- dts[-1,]
  
  dts$NAccuracy        <- 4 * dts$Accuracy/dts$precision
  dts$info  <- as.numeric(splt[2])
  if (c(crs$Depth[1]!=0 )  ){
    tmp       <- c(colMeans(dts[crs$Depth,c(5,2:4)]), colMeans(crs[,2:4]) )
    df        <- rbind(df, tmp )
    nms       <- c(nms,i)
    simid     <- c(simid,splt[1])
  }
  #}
  
  if(splt[3]=="001" & splt[2]=="10"){
    plot(dts$Depth,dts$NAccuracy,col=rainbow(19,end= .9,alpha = .01)[1],ylim = c(0,10),xlim=c(0,30),pch=16,ylab = ylabel, xlab=xlabel  , main = mainlabel)
  }else{
    points(dts$Depth,dts$NAccuracy,col=rainbow(19,end= .9,alpha = .01)[as.numeric(splt[2])/5-1]  ,pch=16 )
  }
}




par(oldpar)


########################################
######## ejemplo individual ############
########################################
sim01 <- function(x){
 ( (x^2)/4 + x/2 )
}
oldpar <- par()
par(mar=c(4, 4, 2.5, 3.5) + 0.1)

example1 <- "Sim01_95_005" # "Sim01_50_015" #"Sim01_95_002"
dts   <- read.table(paste0("./Plum_runs/",example1,"/",example1,".csv"),header = T,sep = ',')
crs   <- CRS(dts[,2],dts[,4],dts[,5],dts[,3],mean(dts[,7]),mean(dts[,8]))
plum   <- read.table(paste0("./Plum_runs/",example1,"/",example1,"_31_ages.txt"),header = T,sep = '\t')


plot(plum$depth,plum$max+70,type = 'l',xlab = "Depth (cm)",col=rgb(0,0,0,0),
     ylab = "Age (yr)", yaxt = "n",ylim = c(-50,300),xlim = c(0,30),lwd=2)
axis(side = 2,at= seq(0,300,50))

d <- crs$Depth
age <- crs$Ages + 70
er <- 2*crs$Errors
lines(crs$Depths,crs$Ages+70,col=rgb(1,0,0,.5),lwd=2)
pol = cbind( c(d, rev(d) ), c(age-er, rev(age+er) ) )
polygon(pol, col=rgb(1,0,0,.5), border=rgb(1,0,0,.5))

d <- plum$depth
lines(plum$depth,plum$mean+70,lwd=1.3,col=rgb(0,0,1,.3))
pol = cbind( c(d, rev(d) ), c(plum$min+70, rev(plum$max+70) ) )
polygon(pol, col=rgb(0,0,1,.3), border=rgb(0,0,1,.3))


# lines(plum$depth,plum$mean+70,lwd=2)
# lines(plum$depth,plum$min+70,lwd=2)
# lines(crs$Depths,crs$Ages+70,col='red',lwd=2)
# lines(crs$Depths,(crs$Ages-2*crs$Errors)+70,col='red',lwd=2)
# lines(crs$Depths,(crs$Ages+2*crs$Errors)+70,col='red',lwd=2)
curve(sim01,add = T,col='green', lwd=2)
legend(0,300,legend = c('Plum',"CI-CRS","True"),col=c(rgb(0,0,1,.3),rgb(1,0,0,.5),"green"),lty = c(1,1,1),bty = "n",pch=c(16,16,NA) )

par(new = TRUE)

plot(crs$Depths,abs(crs$Ages-sim1(crs$Depths))/crs$Errors,col=rgb(1,0,0,.5),
     pch=16,xlab = "",ylab = "",xaxt = "n", yaxt = "n",
     xlim = c(0,30),ylim=c(0,10))
axis(side = 4,at= seq(-10,10,2))
mtext("sd", side=4, line=1.8, col="black")
points(plum$depth[crs$Depths+1],
       4*abs(sim1(plum$depth[crs$Depths+1])-plum$mean[crs$Depths+1])/(plum$max[crs$Depths+1]-plum$min[crs$Depths+1]) ,
       pch=16,col=rgb(0,0,1,.3))
#points(plum$depth,4*abs(sim1(plum$depth)-plum$mean)/(plum$max-plum$min) ,pch=16)
abline(h=c(1,2),col='blue')
















#############################################
############# MULTIPLOT #####################
#############################################




multiplot <- function(..., plotlist=NULL, file, cols=1, layout=NULL) {
  library(grid)
  
  # Make a list from the ... arguments and plotlist
  plots <- c(list(...), plotlist)
  
  numPlots = length(plots)
  
  # If layout is NULL, then use 'cols' to determine layout
  if (is.null(layout)) {
    # Make the panel
    # ncol: Number of columns of plots
    # nrow: Number of rows needed, calculated from # of cols
    layout <- matrix(seq(1, cols * ceiling(numPlots/cols)),
                     ncol = cols, nrow = ceiling(numPlots/cols))
  }
  
  if (numPlots==1) {
    print(plots[[1]])
    
  } else {
    # Set up the page
    grid.newpage()
    pushViewport(viewport(layout = grid.layout(nrow(layout), ncol(layout))))
    
    # Make each plot, in the correct location
    for (i in 1:numPlots) {
      # Get the i,j matrix positions of the regions that contain this subplot
      matchidx <- as.data.frame(which(layout == i, arr.ind = TRUE))
      
      print(plots[[i]], vp = viewport(layout.pos.row = matchidx$row,
                                      layout.pos.col = matchidx$col))
    }
  }
}


