x = c(32, 13, 31, 133, 14, 46, 2)
xnames = c("Age not modelled", "CF:CS", "CIC", "CRS", "Multiple", "Not reported", "Other")

freq = 100 * x/sum(x)

spacing = .1
width = 1

bar.left = spacing+seq(0, length(x), by=width+spacing)

op = par(mar=c(2,3,1,1), mgp=c(1.5, .7, 0), bty="l", las=1, xaxs="r", yaxs="i", xaxt="n", cex.axis=.7, cex=.7)

plot(0, type="n", xlim=range(0, bar.left+1), xlab="", ylim=c(0, 1.1*max(freq)), ylab="Relative frequencies (%)")

rect(bar.left, 0, bar.left+width, freq, col=4, border=4)
text(bar.left+.5, freq+1, x, cex=.7)
op = par(xaxt="s")
axis(1, bar.left+.5, xnames, tick=F, line=-.5, cex.axis=.7)
par(op)
