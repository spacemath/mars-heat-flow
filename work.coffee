# Need comment here.

fig1 = figure
    xlabel: "x"
    ylabel: "y=erfinv(x)"
    yaxis: {min:-4, max:4}
    height: 220
    colors: ["green"]
    series:
        shadowSize: 0
        lines: {lineWidth: 1, show:true}
        points: {show: false}

erfinv = (u) -> #;
    c = [1.758, -2.257, 0.1661]
    s = (u<=0)-(u>0) # sign
    t = sqrt( -log(0.5*(1+s*u)) )
    (c[0] + c[1]*t + c[2]*t*t)*s

x = linspace -1, 1, 1000 #;
y = erfinv x #;
plot x, y, fig: fig1

