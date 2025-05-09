
pb = read.csv(paste0("./Code/Plum_runs/TEHUAII/TEHUAII-S.csv"))

header <- c("depth_min","depth_max","density","Pb210ex","Pb210ex_er","Cs137","Cs137_er","Am241","Am241_er")
newcore <- c(pb$Depth-pb$Thinkness,pb$Depth,pb$Density,pb$X120Pb-pb$X226Ra,pb$u.210Pb.+pb$X226Ra_sd,rep(NA,length(pb$ID)),rep(NA,length(pb$ID)),rep(NA,length(pb$ID)),rep(NA,length(pb$ID)) )
newcore <- matrix(newcore,nrow = length(pb$Depth))
colnames(newcore) <- header
write.table(newcore,file = paste0(getwd(),"/Cores/First_core/First_core.txt"),sep = '\t',row.names = FALSE,col.names = TRUE)

test<- try(serac::serac("First_core",coring_yr=2020,model=c("CIC","CRS","CFCS"),plotphoto = F,plotpdf = F,plot_Pb = F,plot_Am = F))
#serac::serac("First_core",coring_yr=2020,model=c("CIC","CRS","CFCS"),plotphoto = F,plotpdf = F,plot_Pb = F,plot_Am = F)


CFCS = read.table(paste0("./Code/Plum_runs/TEHUAII/TEHUAII_CFCS.txt"),sep = " ",header = T)
# menos 2020
Models = read.csv("./Code/Plum_runs/TEHUAII/TEHUAII-Models.csv")
Plum = read.table("./Code/Plum_runs/TEHUAII/TEHUAII_19_ages.txt",sep = "\t",header = T)
# -55

plot(Plum$depth,Plum$mean+55,col=rgb(0,0,1,.5),type = 'l',xlab="depth (cm)",ylab = "age (yr)",main = "TEHUAII",
     ylim = c(0,230))
d <- Plum$depth
pol = cbind( c(d, rev(d) ), c(Plum$min+55, rev(Plum$max+55) ) )
lines(d,Plum$mean+55,col=rgb(0,0,1,.5))
polygon(pol, col=rgb(0,0,1,.5), border=rgb(0,0,1,.5))

#plot CFCS model
d <- CFCS$depth_avg_mm
pol = cbind( c(d, rev(d) ), c(2020-CFCS$MinAD, rev(2020-CFCS$MaxAD) ) )
lines(d,CFCS$BestAD,col=rgb(0,1,.6,.5))
polygon(pol, col=rgb(0,1,.6,.5), border=rgb(0,1,.6,.5))
#plot CIC model
d <-  c(0,Models$Depth)
age <- c(0,Models$CIC)
er <- 2*c(0,Models$CICsd)
pol = cbind( c(d, rev(d) ), c(age-er, rev(age+er) ) )
lines(d,age,col=rgb(1,0,0,.5))
polygon(pol, col=rgb(1,0,0,.5), border=rgb(1,0,0,.5))
#plot CRS model
d <-  c(0,Models$Depth[1:14])
age <- c(0,Models$CRS[1:14])
er <- 2*c(0,Models$CRSsd[1:14])
pol = cbind( c(d, rev(d) ), c(age-er, rev(age+er) ) )
lines(d,age,col=rgb(1,0,0,.5))
polygon(pol, col=rgb(1,0,0,.5), border=rgb(.5,.5,0,.5))

legend(0,240,legend = c('Plum',"CRS"),
       col=c(rgb(0,0,1,.5),rgb(1,0,0,.5) ),
       bty = "n",pch=c(15,15) )


legend(0,240,legend = c('Plum',"CIC","CRS","CF:CS"),
       col=c(rgb(0,0,1,.5),rgb(1,0,0,.5),rgb(.5,.5,0,.5),rgb(0,1,.6,.5) ),
       bty = "n",pch=c(15,15,15,15) )




