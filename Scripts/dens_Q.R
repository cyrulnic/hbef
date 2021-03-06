################################################################################
## This software is in the public domain, furnished "as is", without technical
## support, and with no warranty, express or implied, as to its usefulness for
## any purpose.
## 
## dens_Q.R
#
# This file contains the R script that computes the histogram plot and 
# the approximating Inverse Gamma density for the distribution Q|Q^f, see plot Fig.2 in the paper
#
# ``Hierarchical Bayes Ensemble Kalman Filtering''
# by Michael Tsyrulnikov and Alexander Rakitko
# submitted to Physica D.
#
# 
## Authors: Alexander Rakitko  (rakitko@gmail.com) and Michael Tsyrulnikov 
## 6 July 2015
################################################################################
library(mixAK)
library(MCMCpack)
source('functions.R')

parameters          <- create_parameters_universe_world()
universe            <- generate_universe(parameters)
world               <- generate_world(universe, parameters)
output_kf           <- filter_kf(world, universe, parameters, parameters_kf())
param_hbef          <- parameters_hbef()
param_hbef$mean_A   <- mean(output_kf$A)
param_hbef$mean_Q   <- mean(universe$Q)
output_hbef         <- filter_hbef(world, universe, parameters, parameters_hbef())

## ==== plotting densities =====
num_of_plots <- 3
bot_bound <- c(0.9,3.9,8)
up_bound <- c(1.1,4.1,10)

Q     <- universe$Q
Q_f   <- output_hbef$Q_f

for(j in (1:num_of_plots)){
  Q_mod   <- c()
  Q_f_mod <- c()
  ind1    <- which(Q_f>bot_bound[j])
  ind2    <- which(Q_f<up_bound[j])
  ind     <- intersect(ind1,ind2)
  Q_f_mod <- Q_f[ind]
  Q_mod   <- Q[ind]
  d       <- density(Q_mod, bw=0.1, from=0)
  arg     <- seq(0.1,100,by=0.1)
  val     <- c(1:length(arg))
  chi     <- param_hbef$chi
  
  for(i in (1:length(arg))){
    val[i]<-pscl::densigamma(arg[i],chi/2+1, mean(Q_f_mod)*chi/2)
  }
  
  d$y[1]<-0
  
  if (j==1) {
    d1<-d
    Q_mod_1<-Q_mod
    val1<-val
  }
  if (j==2) {
    d2<-d
    val2<-val
    Q_mod_2<-Q_mod
  }
  if (j==3) {
    d3<-d
    val3<-val
    Q_mod_3<-Q_mod
  }
}

pdf("dens_Q.pdf", width=7.48, height=5.47)

nf<-layout(matrix(c(1,2,3), ncol=1), c(19),c(4.3,3.8,5.8),TRUE)
par(mai=c(0,0.8,0.2,0.2))
# 1
plot(1,type="n",ylim=c(0,1.2),xlim=c(0,30),axes=FALSE,xlab='Q', ylab=expression(paste('p','(','Q',' | ','0.9',' < ','Q'^'f',' < ','1.1',')')))
axis(side=1,seq(0,50,5))
axis(side=2,seq(0,1.2,0.2),labels=c("",seq(0.2,1,0.2),""))
box()
abline(h = seq(0,1.2,0.2), v = seq(0,50,5), col = "gray80", lwd=0.25, lty = 2)
polygon(arg, val1, col=rgb(95/255,158/255,160/255,0.5), border="cadetblue4", lwd=1, lty=2)
polygon(d1, col=rgb(240/255,128/255,128/255,0.4), border="coral3", lwd=1, lty=1) 

leg.txt<-(c("Histogram","Inverse Gamma"))
leg.col<-c( "lightcoral","cadetblue")
legend("topright", inset=0,leg.txt,col=leg.col, lty=c(1,2), lwd=2, cex=1.3, pt.cex=1,bg="white")

par(mai=c(0,0.8,0,0.2))
# 2
plot(1,type="n",ylim=c(0,0.4),xlim=c(0,30),axes=FALSE,xlab='Q', ylab=expression(paste('p','(','Q',' | ','3.9',' < ','Q'^'f',' < ','4.1',')')))
axis(side=1,seq(0,50,5))
axis(side=2,seq(0,0.4,0.1),labels=c("",seq(0.1,0.4,0.1)))
box()
abline(h = seq(0,0.4,0.1), v = seq(0,50,5), col = "gray80", lwd=0.25, lty = 2)
polygon(arg, val2, col=rgb(95/255,158/255,160/255,0.5), border="cadetblue4", lwd=1, lty=2)
polygon(d2, col=rgb(240/255,128/255,128/255,0.4), border="coral3", lwd=1, lty=1) 

leg.txt<-(c("Histogram","Inverse Gamma"))
leg.col<-c( "lightcoral","cadetblue")
legend("topright", inset=0,leg.txt,col=leg.col, lty=c(1,2), lwd=2, cex=1.3, pt.cex=1, bg="white")

par(mai=c(0.8,0.8,0,0.2))

# 3
plot(1,type="n",ylim=c(0,0.25),xlim=c(0,30), axes=FALSE,xlab='Q', ylab=expression(paste('p','(','Q',' | ','8',' < ','Q'^'f',' < ','11',')')))
axis(side=1,seq(0,50,5))
axis(side=2,seq(0,0.25,0.05),labels=seq(0,0.25,0.05))
box()

abline(h = seq(0,0.25,0.05), v = seq(0,50,5), col = "gray80", lwd=0.25, lty = 2)
polygon(arg, val3, col=rgb(95/255,158/255,160/255,0.5), border="cadetblue4", lwd=1, lty=2)
polygon(d3, col=rgb(240/255,128/255,128/255,0.4), border="coral3", lwd=1, lty=1) 

leg.txt<-(c("Histogram","Inverse Gamma"))
leg.col<-c( "lightcoral","cadetblue")
legend("topright", inset=0,leg.txt,col=leg.col, lty=c(1,2), lwd=2, cex=1.3, pt.cex=1, bg="white")
dev.off()



pdf("dens_Q_bw.pdf", width=7.48, height=5.47)

nf<-layout(matrix(c(1,2,3), ncol=1), c(19),c(4.3,3.8,5.8),TRUE)
#layout.show(nf)
par(mai=c(0,0.8,0.2,0.2))
# 1
plot(1,type="n",ylim=c(0,1.2),xlim=c(0,30),axes=FALSE,xlab='Q', ylab=expression(paste('p','(','Q',' | ','0.9',' < ','Q'^'f',' < ','1.1',')')))
axis(side=1,seq(0,50,5))
axis(side=2,seq(0,1.2,0.2),labels=c("",seq(0.2,1,0.2),""))
box()
abline(h = seq(0,1.2,0.2), v = seq(0,50,5), col = "gray80", lwd=0.25, lty = 2)
lines(arg, val1, lty=2, lwd=2)
lines(d1,lty=1,lwd=2)

leg.txt<-(c("Histogram","Inverse Gamma"))
leg.col<-c( "lightcoral","cadetblue")
legend("topright", inset=0,leg.txt,lty=c(1,2), lwd=2, cex=1.3, pt.cex=1,bg="white")

par(mai=c(0,0.8,0,0.2))
# 2
plot(1,type="n",ylim=c(0,0.4),xlim=c(0,30),axes=FALSE,xlab='Q', ylab=expression(paste('p','(','Q',' | ','3.9',' < ','Q'^'f',' < ','4.1',')')))
axis(side=1,seq(0,50,5))
axis(side=2,seq(0,0.4,0.1),labels=c("",seq(0.1,0.4,0.1)))
box()
abline(h = seq(0,0.4,0.1), v = seq(0,50,5), col = "gray80", lwd=0.25, lty = 2)
lines(arg, val2, lty=2, lwd=2)
lines(d2,lty=1,lwd=2)

leg.txt<-(c("Histogram","Inverse Gamma"))
leg.col<-c( "lightcoral","cadetblue")
legend("topright", inset=0,leg.txt, lty=c(1,2), lwd=2, cex=1.3, pt.cex=1, bg="white")

par(mai=c(0.8,0.8,0,0.2))

# 3
plot(1,type="n",ylim=c(0,0.25),xlim=c(0,30), axes=FALSE,xlab='Q', ylab=expression(paste('p','(','Q',' | ','8',' < ','Q'^'f',' < ','11',')')))
axis(side=1,seq(0,50,5))
axis(side=2,seq(0,0.25,0.05),labels=seq(0,0.25,0.05))
box()

abline(h = seq(0,0.25,0.05), v = seq(0,50,5), col = "gray80", lwd=0.25, lty = 2)
lines(arg, val3, lty=2, lwd=2)
lines(d3,lty=1,lwd=2)

leg.txt<-(c("Histogram","Inverse Gamma"))
leg.col<-c( "lightcoral","cadetblue")
legend("topright", inset=0,leg.txt, lty=c(1,2), lwd=2, cex=1.3, pt.cex=1, bg="white")
dev.off()
