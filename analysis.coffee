#!vanilla

# imports
Fig = $blab.Fig
d3Object = $blab.d3Object

# convenience
w = Fig.width
W = Fig.width + Fig.margin.left + Fig.margin.right
h = Fig.height
H = Fig.height + Fig.margin.top + Fig.margin.bottom

class Plot extends d3Object

    constructor: ->
        
        super "plot"

        @obj.attr('width', W)
            .attr('height', H)

        @plot = @obj.append('g')
            .attr("transform", "translate( #{Fig.margin.left}, #{Fig.margin.top})")
            .attr('width', w)
            .attr('height', h)

        @plot.append("g")
            .attr("id","x-axis")
            .attr("class", "x axis")
            .attr("transform", "translate(0, #{h})")
            .call(@xAxis)

        @plot.append("g")
            .attr("id","y-axis")
            .attr("class", "y axis")
            .attr("transform", "translate(0, 0)")
            .call(@yAxis)

        @plot.selectAll("line.horizontalGrid")
            .data(Fig.T2px.ticks(4))
            .enter()
            .append("line")
            .attr("class", "horizontalGrid")
            .attr("x1", 0)
            .attr("x2", w)
            .attr("y1", (d) -> Fig.T2px d)
            .attr("y2", (d) -> Fig.T2px d)
            .attr("fill", "none")
            .attr("shape-rendering", "auto")
            .attr("stroke", "grey")
            .attr("stroke-width", "1px")
            .attr("opacity", 0.2)

        @plot.selectAll("line.verticalGrid")
            .data(Fig.d2px.ticks(4))
            .enter()
            .append("line")
            .attr("class", "verticalGrid")
            .attr("y1", 0)
            .attr("y2", h)
            .attr("x1", (d) -> Fig.d2px d)
            .attr("x2", (d) -> Fig.d2px d)
            .attr("fill", "none")
            .attr("shape-rendering", "auto")
            .attr("stroke", "grey")
            .attr("stroke-width", "1px")
            .attr("opacity", 0.2)

        @plot.append("text")
            .attr("class", "y label")
            .attr("text-anchor", "end")
            .attr("dy", -60)
            .attr("dx", -90)
            .attr("transform", "rotate(-90)")
            .text("Temperature (deg. K)")

        @plot.append("text")
            .attr("class", "x label")
            .attr("text-anchor", "end")
            .attr("dy", h+50)
            .attr("dx", 220)
            .text("Depth (m)")

    update: (data) ->

        circle = @plot.selectAll("circle.marker")
            .data(data)

        circle.exit().remove()

        circle.enter()
            .append("circle")
            .attr("class", "marker")
            .attr("r", "5")
            .attr("fill", "none")
            .attr("shape-rendering", "crispEdges")
            .attr("stroke", "black")
            .attr("stroke-width", "1px")

        circle
            .attr("cx", (d) -> Fig.d2px d[0])
            .attr("cy", (d) -> Fig.T2px d[1])

    initAxes: ->

        @xAxis = d3.svg.axis()
            .scale(Fig.d2px)
            .orient("bottom")
            .ticks(6)

        @yAxis = d3.svg.axis()
            .scale(Fig.T2px)
            .orient("left")

class Guide extends d3Object

    r = 10 # circle radius
    
    constructor: ()->
        
        super "guide"

        # housekeeping
        @obj.on("click", null)  # Clear any previous event handlers.
        d3.behavior.drag().on("drag", null)  # Clear any previous event handlers.

        @obj.attr('width', W)
            .attr('height', H)

        @region = @obj.append('g')
            .attr("transform", "translate( #{Fig.margin.left}, #{Fig.margin.top})")
            .attr('width', w)
            .attr('height', h)

        d1 = 1.5
        d2 = 4
        T1 = 220
        T2 = 228

        @m1 = @marker()
            .attr("cx", Fig.d2px d1)
            .attr("cy", Fig.T2px T1)

        @m2 = @marker()
            .attr("cx", Fig.d2px d2)
            .attr("cy", Fig.T2px T2)

        @line = @region.append("line")
            .attr("x1", @m1.attr("cx"))
            .attr("y1", @m1.attr("cy"))
            .attr("x2", @m2.attr("cx"))
            .attr("y2", @m2.attr("cy"))
            .attr("class", "modelline")

        slope = (T2-T1)/(d2-d1)
        inter = T1-slope*d1
        d3.select("#equation").html(model_text([inter, slope]))

    initAxes: ->

    marker: () ->

        m = @region.append('circle')
            .attr('r', r)
            .attr("class", "modelcircle")
            .call(
                d3.behavior
                .drag()
                .origin(=>
                    x:m.attr("cx")
                    y:m.attr("cy")
                )
                .on("drag", => @dragMarker(m, d3.event.x, d3.event.y))
            )
        
    dragMarker: (marker, x, y) ->

        x=0 if x<0
        x=w if x>w
        y=0 if y<0
        y=h if y>h

        marker.attr("cx", x)
        marker.attr("cy", y)

        x1 = @m1.attr("cx")
        y1 = @m1.attr("cy")
        x2 = @m2.attr("cx")
        y2 = @m2.attr("cy")
                
        @line.attr("x1", x1)
            .attr("y1", y1)
            .attr("x2", x2)
            .attr("y2", y2)

        T1 = Fig.px2T y1
        T2 = Fig.px2T y2
        d1 = Fig.px2d x1
        d2 = Fig.px2d x2

        slope = (T2-T1)/(d2-d1)
        inter = T1-slope*d1
        d3.select("#equation").html(model_text([inter, slope]))

    model_text = (p) ->
        """
        <table class='func'>
        <tr><td>Model: a =<td/><td>#{p[1].toFixed(2)} deg.K/m,<td/><td>b =<td/><td>#{p[0].toFixed(2)} deg.K<td/><tr/>
        </table>
        """

$blab.plot = new Plot
new Guide


