###############################
# Authors:
# Marco A. Aquino-López 
# JASC
# Code:
# Runs the Expert-CRS and plots results
###############################
rm(list = ls())  # Clean desktiop
### Libraries

library(stringr)
library(ggplot2)
library(magrittr)
library(multipanelfigure)
library(quantreg)

#set working directory

wd      <- "~/OwnCloud-NicoleKS/Plum vs CRS/Sampling and percentages/Plum_runs/"
core    <- list.files(wd)

#Define multiplot function

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

######## This runs all the model for all the simulations

# for (kore in core){
# 
# print(kore)
# 
# pb = read.csv(paste0("~/OwnCloud-NicoleKS/Plum vs CRS/Sampling and percentages/Plum_runs/",kore,'/',kore,'.csv'))
# 
# header <- c("depth_min","depth_max","density","Pb210ex","Pb210ex_er","Cs137","Cs137_er","Am241","Am241_er")
# newcore <- c(pb$Depth-pb$Thickness,pb$Depth,pb$Density,pb$X210Pb-pb$X226Ra,pb$X210Pb_sd+pb$X226Ra_sd,rep(NA,length(pb$ID)),rep(NA,length(pb$ID)),rep(NA,length(pb$ID)),rep(NA,length(pb$ID)) )
# newcore <- matrix(newcore,ncol = 9)
# colnames(newcore) <- header
# write.table(newcore,file = paste0(getwd(),"/Cores/First_core/First_core.txt"),sep = '\t',row.names = FALSE,col.names = TRUE)
# 
# test<- try(serac::serac("First_core",coring_yr=2020,model=c("CIC","CRS","CFCS"),plotphoto = F,plotpdf = F,plot_Pb = F,plot_Am = F))
# #serac::serac("First_core",coring_yr=2020,model=c("CIC","CRS","CFCS"),plotphoto = F,plotpdf = F,plot_Pb = F,plot_Am = F)
# 
# if (typeof(test[1]) == "list" ){
#   CFCS  <- read.table(paste0(getwd(),"/Cores/First_core/First_core_CFCS_interpolation.txt"),header = T)
#   CRS_serac <- read.table(paste0(getwd(),"/Cores/First_core/First_core_CRS.txt"),header = T)
#   CIC   <- read.table(paste0(getwd(),"/Cores/First_core/First_core_CIC.txt"),header = T)
#   ####
#   write.table(CFCS,paste0("~/OwnCloud-NicoleKS/Plum vs CRS/Sampling and percentages/Plum_runs/",kore,'/',"CFCS_interpolation.txt"),col.names = T,row.names = F,append = F)
#   write.table(CRS_serac,paste0("~/OwnCloud-NicoleKS/Plum vs CRS/Sampling and percentages/Plum_runs/",kore,'/',"CRS_serac.txt"),col.names = T,row.names = F,append = F)
#   write.table(CIC,paste0("~/OwnCloud-NicoleKS/Plum vs CRS/Sampling and percentages/Plum_runs/",kore,'/',"CIC_interpolation.txt"),col.names = T,row.names = F,append = F)
# 
# }else{
#   write.table(matrix(rep(0,6),ncol = 6),paste0("~/OwnCloud-NicoleKS/Plum vs CRS/Sampling and percentages/Plum_runs/",kore,'/',"CFCS_interpolation.txt"),col.names = T,row.names = F,append = F)
#   write.table(matrix(rep(0,6),ncol = 6),paste0("~/OwnCloud-NicoleKS/Plum vs CRS/Sampling and percentages/Plum_runs/",kore,'/',"CRS_serac.txt"),col.names = T,row.names = F,append = F)
#   write.table(matrix(rep(0,6),ncol = 6),paste0("~/OwnCloud-NicoleKS/Plum vs CRS/Sampling and percentages/Plum_runs/",kore,'/',"CIC_interpolation.txt"),col.names = T,row.names = F,append = F)
# }
# print(kore)
# 
# }

####### This will create the file with offsets and sds

x  <- 0:30
f1 <- x**2/4 + x/2
f2 <- 12*x - 0.2*x**2
f3 <- 8*x + 25*sin(x/pi)

modelMeans = NULL
cont.malos = 0
for (kore in core){
  if (strsplit(kore,"_")[[1]][1] == "Sim01"){
    f = f1
  }else{
    if(strsplit(kore,"_")[[1]][1] == "Sim02"){
      f = f2
  }else{
    f = f3
  } }

  CFCS = read.table(paste0("~/OwnCloud-NicoleKS/Plum vs CRS/Sampling and percentages/Plum_runs/",kore,'/',"CFCS_interpolation.txt"),header = T)
  CRS_serac = read.table(paste0("~/OwnCloud-NicoleKS/Plum vs CRS/Sampling and percentages/Plum_runs/",kore,'/',"CRS_serac.txt"),header = T)
  CIC  = read.table(paste0("~/OwnCloud-NicoleKS/Plum vs CRS/Sampling and percentages/Plum_runs/",kore,'/',"CIC_interpolation.txt"), header = T)

  if ( !is.null(CFCS$depth_avg_mm) ){
  #Se asume un intervalo del 95%
  models  = matrix( abs(-approx(CFCS$depth_avg_mm,CFCS$BestAD,x,na.rm = TRUE)$y  + 2020   - f) )# CFCS model
  models  = cbind(models,(approx(CFCS$depth_avg_mm,CFCS$MaxAD,x,na.rm = TRUE)$y-approx(CFCS$depth_avg_mm,CFCS$MinAD,x,na.rm = TRUE)$y) / 4)
  models  = cbind(models,abs( -approx(CIC$depth_avg_mm,CIC$BestAD,x,na.rm = TRUE)$y  + 2020  -f) ) # CIC model
  models  = cbind(models,(approx(CIC$depth_avg_mm,CIC$MaxAD,x,na.rm = TRUE)$y-approx(CIC$depth_avg_mm,CIC$MinAD,x,na.rm = TRUE)$y) / 4 )
  models  = cbind(models,abs( -approx(CRS_serac$depth_avg_mm,CRS_serac$BestAD,x,na.rm = TRUE)$y  + 2020 - f) )# CRS model
  models  = cbind(models,(approx(CRS_serac$depth_avg_mm,CRS_serac$MaxAD,x,na.rm = TRUE)$y-approx(CRS_serac$depth_avg_mm,CRS_serac$MinAD,x,na.rm = TRUE)$y) / 4 )
  models  = models[-1,]
  colnames(models) <- c("CFCS", "CFCS_sd","CIC","CIC_sd","CRS_serac","CRS_serac_sd")
  write.table(models,paste0("~/OwnCloud-NicoleKS/Plum vs CRS/Sampling and percentages/Plum_runs/",kore,'/',"serac_errors_sd.txt"),col.names = T,row.names = F,append = F)

  modelMeans = rbind(modelMeans, c(kore,colMeans(models,na.rm = T)  ) )
  }else{
    print(kore); cont.malos = cont.malos + 1
  }
}

write.table(modelMeans,paste0("~/github/Paper_Simulations/Code/","serac_errors_sd.txt"),col.names = T,row.names = F,append = F)
# write.table(df,paste0("~/github/Paper_Simulations/Code/","Plum_errors_sd.txt"),col.names = T,row.names = F,append = F)

###### This create the Plots

#Read files
serac <- read.table("~/github/Paper_Simulations/Code/serac_errors_sd.txt",sep=" ",header=T)
E_CRS <- read.table("~/github/Paper_Simulations/Code/E_CRS.txt",sep=" ",header=T)
Plum  <- read.table("~/github/Paper_Simulations/Code/Plum_errors_sd.txt",sep=" ",header=T)

per_temp = NULL
for (i in E_CRS$X){
  per_temp = c(per_temp,	as.numeric(substr(i,7,8)) )
  #print(as.numeric(substr(i,7,8) ))
}
E_CRS$Information_percentage = per_temp 

per_temp = NULL
for (i in serac$X){
  per_temp = c(per_temp,	as.numeric(substr(i,7,8)) )
  #print(as.numeric(substr(i,7,8) ))
}
serac$Information_percentage = per_temp 

#Create plots using ggplot

accplot <- ggplot(serac, aes(x=Information_percentage)) + 
  geom_quantile(aes(y = CFCS),size=1.,alpha=.5,color="gold4",method = "rqss") +
  geom_point(aes(y = CFCS ),size=.7,alpha=.01,color='gold4') +
  ##
  geom_quantile(aes(y = CIC ),size=1.,alpha=.5,color="green",method = "rqss") +
  geom_point(aes(y = CIC),size=.7,alpha=.01,color='green') +
  ##
  geom_quantile(aes( y = CRS_serac ),size=1.,alpha=.5,color="blue",method = "rqss") +
  geom_point(aes( y = CRS_serac ),size=.7,alpha=.01,color='blue') +
  xlim(10, 100) + ylim(0, 100) +
  ##
  geom_quantile(data=E_CRS,aes(y = offset ),size=1.,alpha=.5,color="royalblue4",method = "rqss") +
  geom_point(data=E_CRS,aes(y = offset),size=.7,alpha=.01,color='royalblue4') +
  ##
  geom_quantile(data=Plum,aes(y = CRS_Accuracy ),size=1.,alpha=.5,color="deepskyblue",method = "rqss") +
  geom_point(data=Plum,aes(y = CRS_Accuracy),size=.7,alpha=.01,color='deepskyblue') +
  ##
  geom_quantile(data=Plum,aes(y = Accuracy ),size=1.,alpha=.5,color="darkmagenta",method = "rqss") +
  geom_point(data=Plum,aes(y = Accuracy ),size=.7,alpha=.01,color='darkmagenta') +
  ##
  xlim(10, 100) + ylim(0, 100) + 
  labs(title = "A) Offset", x = "", y = "yr", color = "% Inf")

accplot

preplot <- ggplot(serac, aes(x=Information_percentage)) + 
  geom_quantile(aes(y = CFCS_sd),size=1.5,alpha=.5,color="gold4",method = "rqss") +
  geom_point(aes(y = CFCS_sd),size=.7,alpha=.01,color='gold4') +
  ##
  geom_quantile(aes(y = CIC_sd ),size=1.5,alpha=.5,color="green",method = "rqss") +
  geom_point(aes(y = CIC_sd ),size=.7,alpha=.01,color='green') +
  ##
  geom_quantile(aes(y = CRS_serac_sd ),size=1.5,alpha=.5,color="blue",method = "rqss") +
  geom_point(aes( y = CRS_serac_sd ),size=.7,alpha=.01,color='blue') +
  xlim(10, 100) + ylim(0, 100) +
  ##
  geom_quantile(data=E_CRS,aes(y = sd ),size=1.5,alpha=.5,color="royalblue4",method = "rqss") +
  geom_point(data=E_CRS,aes(y = sd),size=.7,alpha=.01,color='royalblue4') +
  ##
  geom_quantile(data=Plum,aes(y = CRS_Precision ),size=1.,alpha=.5,color="deepskyblue",method = "rqss") +
  geom_point(data=Plum,aes(y = CRS_Precision ),size=.7,alpha=.01,color='deepskyblue') +
  ##
  geom_quantile(data=Plum,aes(y = Precision ),size=1.5,alpha=.5,color="darkmagenta",method = "rqss") +
  geom_point(data=Plum,aes(y = Precision ),size=.7,alpha=.01,color='darkmagenta') +
  ##
  xlim(10, 100) + ylim(0, 100) +  
  labs(title ="B) Length 95% interval" , x = "", y ="yr")  + xlim(10, 100) + ylim(0, 100) 

preplot

naccplot <- ggplot(serac, aes(x=Information_percentage)) + 
  geom_quantile(aes(y = 4*CFCS/CFCS_sd),size=1,alpha=.5,color="gold4",method = "rqss") +
  geom_point(aes(y = 4*CFCS/CFCS_sd),size=.7,alpha=.01,color='gold4') +
  ##
  geom_quantile(aes(y = 4*CIC/CIC_sd ),size=1.,alpha=.5,color="green",method = "rqss") +
  geom_point(aes(y = 4*CIC/CIC_sd ),size=.7,alpha=.01,color='green') +
  ##
  geom_quantile(aes(y = 4*CRS_serac/CRS_serac_sd ),size=1.,alpha=.5,color="blue",method = "rqss") +
  geom_point(aes( y = 4*CRS_serac/CRS_serac_sd ),size=.7,alpha=.01,color='blue') +
  xlim(10, 100) + ylim(0, 100) +
  ##
  geom_quantile(data=E_CRS,aes(y = N_offset ),size=1.,alpha=.5,color="royalblue4",method = "rqss") +
  geom_point(data=E_CRS,aes(y = N_offset),size=.7,alpha=.01,color='royalblue4') +
  ##
  geom_quantile(data=Plum,aes(y = CRS_NormAccuracy ),size=1.,alpha=.5,color="deepskyblue",method = "rqss") +
  geom_point(data=Plum,aes(y = CRS_NormAccuracy ),size=.7,alpha=.01,color='deepskyblue') +
  ##
  geom_quantile(data=Plum,aes(y = NormAccuracy ),size=1.,alpha=.5,color="darkmagenta",method = "rqss") +
  geom_point(data=Plum,aes(y = NormAccuracy ),size=.7,alpha=.01,color='darkmagenta') +
  ##
  xlim(10, 100) + ylim(0, 5) + 
  labs(title = "C) Normalized Offset", x = "% of information", y = "", color = "% Inf")

naccplot



figure1 <- multi_panel_figure(columns = 1, rows = 3, panel_label_type = "none")

multiplot(accplot,preplot,naccplot,cols=1)






