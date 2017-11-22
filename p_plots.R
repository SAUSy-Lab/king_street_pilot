# plotting the plotty plots

library(ggplot2)
library(anytime)
library(scales)
library(ggthemes)
library(chron)


df <- read.csv("times12.csv")

df$duration <- abs(df$t1 - df$t2) / 60

df <- subset(df, df$duration < 120)
df <- subset(df, df$duration > 3)

df$t1d <- anytime(df$t1)
df$t2d <- anytime(df$t2)

df$t1dt <- as.numeric(as.character(strftime(df$t1d, "%H"))) + as.numeric(as.character(strftime(df$t1d, "%M"))) / 60
df$t2dt <- as.numeric(strftime(df$t2d, "%H")) + as.numeric(strftime(df$t2d, "%M")) / 60

df$t1dd <- strftime(df$t1d, "%Y-%m-%d")
df$t2dd <- strftime(df$t2d, "%Y-%m-%d")

df$dir <- 'east_to_west'
df$dir[df$t1 < df$t2] <- 'west_to_east'

df$pp <- "pre"
df$pp[df$t1dd > anytime(1510462800)] <- 'post'


# 1510376400

dfw2e <- subset(df,df$dir == 'west_to_east')
dfe2w <- subset(df,df$dir == 'east_to_west')



# day plot - tuesday 
ll <- as.POSIXct("2017/11/13 00:00:00")
lh <- as.POSIXct("2017/11/13 24:00:00")
tseq <- seq(ll, lh, by = "hour")
p = ggplot() + geom_point(aes(dfw2e$t1d,dfw2e$duration), size = 0.2, color = "blue") + geom_smooth(aes(dfw2e$t1d,dfw2e$duration)) + ylim(5,40) + xlab("departure time") + ylab("duration") + ggtitle("eastbound: Bathurst to Jarvis") + theme_light() +
  scale_x_datetime(limits = c(ll,lh), breaks = tseq) + theme(axis.text.x = element_text(angle = 45,vjust = 1, hjust = 1))

ll <- as.POSIXct("2017/11/6 00:00:00")
lh <- as.POSIXct("2017/11/6 24:00:00")
tseq <- seq(ll, lh, by = "hour")
ggplot() + geom_point(aes(dfw2e$t1d,dfw2e$duration), size = 0.2, color = "red") + geom_smooth(aes(dfw2e$t1d,dfw2e$duration)) + ylim(5,40) + xlab("departure time") + ylab("duration") + ggtitle("eastbound: Bathurst to Jarvis") + theme_light() +
  scale_x_datetime(limits = c(ll,lh), breaks = tseq) + theme(axis.text.x = element_text(angle = 45,vjust = 1, hjust = 1))





# combine plots and sep by pp Bathurst to Jarvis

pre_mean <- aggregate(dfw2e$duration, by=list(Category=dfw2e$pp), FUN=mean)[2,2]
post_mean <- aggregate(dfw2e$duration, by=list(Category=dfw2e$pp), FUN=mean)[1,2]
pre_median <- aggregate(dfw2e$duration, by=list(Category=dfw2e$pp), FUN=median)[2,2]
post_median <- aggregate(dfw2e$duration, by=list(Category=dfw2e$pp), FUN=median)[1,2]

dfw2e_pre <- subset(dfw2e, dfw2e$pp == "pre")
dfw2e_post <- subset(dfw2e, dfw2e$pp == "post")
p = ggplot() + geom_point(aes(dfw2e_pre$t1dt,dfw2e_pre$duration), size = 0.1, color = "black", alpha = 0.3)  + ylim(7,40) + xlab("departure time") + ylab("duration") + ggtitle("eastbound: Bathurst to Jarvis") + theme_light() +
  
  geom_point(aes(dfw2e_post$t1dt,dfw2e_post$duration), size = 0.1, color = "red", alpha = 0.3)  + ylim(7,40) + xlim(0, 24) + xlab("departure time") + ylab("duration") + ggtitle("eastbound: Bathurst to Jarvis") + theme_light() +

  
  #geom_hline(yintercept = pre_median, color = "black",linetype = 1) +
  #geom_hline(yintercept = post_median, color = "red", linetype = 1) +
  #geom_hline(yintercept = pre_mean, color = "black",linetype = 2) +
  #geom_hline(yintercept = post_mean, color = "red", linetype = 2) +
  
geom_smooth(aes(dfw2e_pre$t1dt,dfw2e_pre$duration), color = "black") +
  geom_smooth(aes(dfw2e_post$t1dt,dfw2e_post$duration), color = "red") + xlim(0, 24) +
  scale_x_continuous(breaks = seq(0,24,by=1))
p


# combine plots and sep by pp Jarvis to Bathurst

pre_mean <- aggregate(dfe2w$duration, by=list(Category=dfe2w$pp), FUN=mean)[2,2]
post_mean <- aggregate(dfe2w$duration, by=list(Category=dfe2w$pp), FUN=mean)[1,2]
pre_median <- aggregate(dfe2w$duration, by=list(Category=dfe2w$pp), FUN=median)[2,2]
post_median <- aggregate(dfe2w$duration, by=list(Category=dfe2w$pp), FUN=median)[1,2]

dfw2e_pre <- subset(dfe2w, dfe2w$pp == "pre")
dfw2e_post <- subset(dfe2w, dfe2w$pp == "post")
p = ggplot() + geom_point(aes(dfw2e_pre$t1dt,dfw2e_pre$duration), size = 0.1, color = "black", alpha = 0.3)  + ylim(7,40) + xlab("departure time") + ylab("duration") + ggtitle("westbound: Jarvis to Bathurst") + theme_light() +
  
  geom_point(aes(dfw2e_post$t1dt,dfw2e_post$duration), size = 0.1, color = "red", alpha = 0.3)  + ylim(7,40) + xlim(0, 24) + xlab("departure time") + ylab("duration") + theme_light() +
  
  #geom_hline(yintercept = pre_median, color = "black",linetype = 1) +
  #geom_hline(yintercept = post_median, color = "red", linetype = 1) +
  #geom_hline(yintercept = pre_mean, color = "black",linetype = 2) +
  #geom_hline(yintercept = post_mean, color = "red", linetype = 2) +
  
  geom_smooth(aes(dfw2e_pre$t1dt,dfw2e_pre$duration, method="loess"), color = "black") +
  geom_smooth(aes(dfw2e_post$t1dt,dfw2e_post$duration, method="loess"), color = "red") + xlim(0, 24) +
  scale_x_continuous(breaks = seq(0,24,by=1))
p



# full plot bath to jarv

hl <- as.POSIXct("2017/11/12 00:00:00")

lims <- as.POSIXct(strptime(c("2017-10-19 00:00", "2017-11-21 00:00"), 
                            format = "%Y-%m-%d %H:%m"))

ggplot() + geom_point(aes(dfw2e$t1d,dfw2e$duration), size = 0.2) + ylim(5,40) + xlab("departure date") + ylab("duration") + ggtitle("eastbound: Bathurst to Jarvis") + theme_light() + 
geom_vline(xintercept = 1510462800, color = "red", linetype = 1) +
  scale_x_datetime(labels = date_format("%m/%d"), breaks = date_breaks("2 days"), limits = lims ) + theme(axis.text.x = element_text(angle = 45, hjust = 0.5, vjust = 0.5))


# full plot jarv to bath

hl <- as.POSIXct("2017/11/12 00:00:00")

lims <- as.POSIXct(strptime(c("2017-10-19 00:00", "2017-11-21 00:00"), 
                            format = "%Y-%m-%d %H:%m"))

ggplot() + geom_point(aes(dfe2w$t1d,dfe2w$duration), size = 0.2) + ylim(5,40) + xlab("departure date") + ylab("duration") + ggtitle("eastbound: Jarvis to Bathurst") + theme_light() + 
  geom_vline(xintercept = 1510462800, color = "red", linetype = 1) +
  scale_x_datetime(labels = date_format("%m/%d"), breaks = date_breaks("2 days"), limits = lims ) + theme(axis.text.x = element_text(angle = 45, hjust = 0.5, vjust = 0.5))



  #xlim(as.Date(c('2017-11-01','2017-11-20')))
