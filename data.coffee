 # Enter depth(d) and temperature (T) below.
 # Press [Shift] + [Enter] to update.
 # Click [Save] to keep/share your work.

data = [] #; initialize

 #         d   T
data[0] = [1, 230]
data[1] = [2, 240]
data[2] = [3, 250]
data[3] = [4, 260]
data[4] = [5, 270]

 # plot on right
fig = figure
    xlabel: "depth (m)"
    ylabel: "temperature (deg. K)"
    height: 200
    series:
        shadowSize: 0
        points: {show: true}
plot data.T[0], data.T[1], fig:fig

 # plot below
$blab.data = data #;

