###################################################
# Title  
# Description
# Marco A. Aquino-López
###################################################
rm(list = ls()) 	# clean R environment

# Load libraries
library(stringr)
library(ggplot2)
library(magrittr)
library(multipanelfigure)
library(quantreg)

#Read files
serac <- read.table("~/github/Paper_Simulations/Code/serac_errors_sd.txt",sep=" ",header=T)
E_CRS <- read.table("~/github/Paper_Simulations/Code/E_CRS.txt",sep=" ",header=T)
Plum <- read.table("~/github/Paper_Simulations/Code/Plum_errors_sd.txt",sep=" ",header=T)

per_temp = NULL
for (i in E_CRS$X){
	per_temp = c(per_temp,	as.numeric(substr(i,7,8)) )
	print(as.numeric(substr(i,7,8) ))
}
E_CRS$Information_percentage = per_temp 

per_temp = NULL
for (i in serac$X){
	per_temp = c(per_temp,	as.numeric(substr(i,7,8)) )
	print(as.numeric(substr(i,7,8) ))
}
serac$Information_percentage = per_temp 

#Create plots



## Plots
#pdf("../Fig/Acc_prec.pdf", width=8.5, height=9.5)
accplot <- ggplot(serac, aes(x=Information_percentage)) + 
  geom_quantile(aes(y = CFCS),size=.5,alpha=.5,color="purple",method = "rqss") +
  #geom_point(aes(y = CFCS),size=.7,alpha=.1,color='blue') +
  ##
  geom_quantile(aes(y = CIC ),size=.5,alpha=.5,color="green",method = "rqss") +
  #geom_point(aes(y = CIC),size=.7,alpha=.1,color='green') +
  ##
  geom_quantile(data=E_CRS,aes(y = offset ),size=.5,alpha=.5,color="chocolate",method = "rqss") +
  #geom_point(data=E_CRS,aes(y = offset),size=.7,alpha=.1,color='yellow') +
  ##
  geom_quantile(data=Plum,aes(y = Accuracy ),size=.8,alpha=.8,color="blue",method = "rqss") +
  ##
  geom_quantile(data=Plum,aes(y = CRS_Accuracy ),size=.8,alpha=.8,color="forestgreen",method = "rqss") +
  #geom_point(data=E_CRS,aes(y = offset),size=.7,alpha=.1,color='yellow') +
  ##
  geom_quantile(aes(y = CRS_serac ),size=.8,alpha=.8,color="red",method = "rqss") +
  #geom_point(aes(y = CRS_serac),size=.8,alpha=.1,color='red') +
  theme(legend.justification=c(0,0),legend.position=c(0.5,0.5)) + 
  labs(title = "A) Offset", x = "", y = "yr",colour = "hola")

 accplot


preplot <-  ggplot(serac, aes(Information_percentage)) + 
  geom_quantile(aes(y = CFCS_sd),size=.5,alpha=.5,color="purple",method = "rqss") +
  #geom_point(aes(y = CFCS),size=.7,alpha=.1,color='blue') +
  ##
  geom_quantile(aes(y = CIC_sd ),size=.5,alpha=.5,color="green",method = "rqss") +
  #geom_point(aes(y = CIC),size=.7,alpha=.1,color='green') +
  ##
  geom_quantile(data=E_CRS,aes(y = sd ),size=.5,alpha=.5,color="chocolate",method = "rqss") +
  #geom_point(data=E_CRS,aes(y = offset),size=.7,alpha=.1,color='yellow') +
  ##
  geom_quantile(data=Plum,aes(y = CRS_Precision ),size=.8,alpha=.8,color="forestgreen",method = "rqss") +
  ##
  geom_quantile(data=Plum,aes(y = Precision ),size=.8,alpha=.8,color="blue",method = "rqss") +
  #geom_point(data=E_CRS,aes(y = offset),size=.7,alpha=.1,color='yellow') +
  ##
  geom_quantile(aes(y = CRS_serac_sd ),size=.8,alpha=.8,color="red",method = "rqss") +
  #geom_point(aes(y = CRS_serac),size=.8,alpha=.1,color='red') +
  xlim(10, 100) + ylim(0, 63) + 
  labs(title = "B)Interval Length", x = "", y = "yr", color = "% Inf")


# preplot

naccplot <- ggplot(serac, aes(Information_percentage)) + 
  geom_quantile(aes(y = CFCS/CFCS_sd),size=.5,alpha=.5,color="purple",method = "rqss") +
  #geom_point(aes(y = CFCS),size=.7,alpha=.1,color='blue') +
  ##
  geom_quantile(aes(y = CIC/CIC_sd ),size=.5,alpha=.5,color="green",method = "rqss") +
  #geom_point(aes(y = CIC),size=.7,alpha=.1,color='green') +
  ##
  geom_quantile(data=E_CRS,aes(y = N_offset ),size=.5,alpha=.5,color="chocolate",method = "rqss") +
  #geom_point(data=E_CRS,aes(y = offset),size=.7,alpha=.1,color='yellow') +
  ##
  geom_quantile(data=Plum,aes(y = CRS_NormAccuracy ),size=.8,alpha=.8,color="forestgreen",method = "rqss") +
  ##
  geom_quantile(data=Plum,aes(y = NormAccuracy ),size=.8,alpha=.8,color="blue",method = "rqss") +
  #geom_point(data=E_CRS,aes(y = offset),size=.7,alpha=.1,color='yellow') +
  ##
   geom_quantile(aes(y = CRS_serac/CRS_serac_sd ),size=.8,alpha=.8,color="red",method = "rqss") +
  #geom_point(aes(y = CRS_serac),size=.8,alpha=.1,color='red') +
  xlim(10, 100) + ylim(0, 5) + 
  labs(title = "C) Normalized Offset", x = "% of information", y = "", color = "% Inf")

 naccplot


pdf("~/github/Paper_Simulations/Manuscript/Figures/AccPrec.pdf", width=9, height=12)
multiplot(accplot,preplot,naccplot,cols=1)
dev.off()

































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


