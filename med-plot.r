d = read.csv('times.csv')

# duration in minutes
d$duration = abs( d$t1 - d$t2 ) / 60

# clip outliers/errors
d = d[d$duration<60,]
d = d[d$duration>1,]

# set the time of the trip (average)
d$meantime = ((d$t1+d$t2)/2) -5*3600
# shift everything to the left
d$meantime  = d$meantime - 4*3600
# time of day in hours
d$daytime = (d$meantime %% (24*3600)) / 3600 + 4

#do a quick statistical test to see if there is a difference of means
d$pre = d$meantime<1510462800
t.test(duration~pre,data=d)
ks.test(d[d$pre,'duration'],d[!d$pre,'duration'])
# separate into two distinct periods
#d = d[d$pre,]
unique_days_in_d = length(unique(d$meantime - d$meantime %% (24*3600)))

# plot the points
par(
	family = 'Ubuntu Mono',
	mar = c(3.1,5,3,0.5)
)
plot( 
	x = d$daytime, 
	y = d$duration, 
	pch = '.', 
	ylim = c(3,33),
	xlim = c(4,28),
	axes = FALSE,
	xlab = '',
	ylab = 'Jarvis <-> Bathurst (minutes)',
	main = 'Streetcar travel times pre/post overlaid'
)
axis(
	side = 1, # X
	at = c(4,8.5,12,17.5,24,24+4),
	labels = c('4am','8:30am','Noon','5:30pm','Midnight','4am')
)
axis(
	side = 2, # Y
	at = c(5,10,15,20,25,30)
)
# grid
abline(h=c(30,25,20,15,10,5),col=rgb(0,0,0,0.1))
abline(v=c(8.5,12,17.5,24),col=rgb(0,0,0,0.1))

# kernel parameters
bandwidth = 0.5 # standard deviation (gaussian kernel bandwidth)

# sort by duration
d = d[order(d$duration),]

# points to iterate over
times = seq(4,28,0.1)
p05 = p25 = p50 = p75 = p95 = rep(0,length(times))

# get an hourly local median
for(ti in 1:length(times)){
	# calculate distances from this time
	d$dist = abs( times[ti] - d$daytime )
	d$w = exp( -( d$dist^2 / (2*bandwidth)^2 ) )
	d$cum_w = cumsum(d$w) / sum(d$w)
	# p05
	di = which( abs(d$cum_w-0.05) == min(abs(d$cum_w-0.05)) )
	p05[ti] = mean(d[di,'duration'])
	# p25
	di = which( abs(d$cum_w-0.25) == min(abs(d$cum_w-0.25)) )
	p25[ti] = mean(d[di,'duration'])
	# median (Q2)
	di = which( abs(d$cum_w-0.5) == min(abs(d$cum_w-0.5)) )
	p50[ti] = mean(d[di,'duration'])
	# p75
	di = which( abs(d$cum_w-0.75) == min(abs(d$cum_w-0.75)) )
	p75[ti] = mean(d[di,'duration'])
	# p90
	di = which( abs(d$cum_w-0.95) == min(abs(d$cum_w-0.95)) )
	p95[ti] = mean(d[di,'duration'])
}
# plot percentile boundaries
# 0.05 - 0.95
polygon( 
    x=c(times,rev(times)),
    y=c(p05,rev(p95)),
    col=rgb(1,0,0,0.3),
    border=rgb(1,0,0,0.25)
)
# 0.25 - 0.75
polygon( 
  x=c(times,rev(times)),
  y=c(p25,rev(p75)),
  col=rgb(0,0.5,1,0.3),
  border=rgb(0,0,1,0.25)
)
lines( x=times, y=p50, col='darkblue', lty=1, lwd=1 )