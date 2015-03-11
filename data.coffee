 # Enter depth(d) and temperature (T) below.
 # Press [Shift] + [Enter] to update.
 # Click [Save] to keep/share your work.

data = [] #; initialize (ignore this)

 #         d   T
data[0] = [1, 230]
data[1] = [2, 240]
data[2] = [3, 250]
data[3] = [4, 260]
data[4] = [5, 270]

 # (You can remove data, for example, by
 # deleting the line beginning data[4].
 # Similarly, you can add a line beginning
 # data[5]. But, the data MUST be numbered
 # sequentially: data[0], data[1], etc.)

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
$blab.plot.update data #;
