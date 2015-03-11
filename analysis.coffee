#!vanilla

Fig = $blab.Fig
d3Object = $blab.d3Object

class Plot extends d3Object

    margin = {top: 20, right: 20, bottom: 20, left: 20}
    width = 480 - margin.left - margin.right
    height = 480 - margin.top - margin.bottom
    #data0 = [[1, 1], [2, 2], [3, 3], [4, 4], [5, 5]]
    
    constructor: () ->
        
        super "plot"

        @obj.attr('width', width + margin.left + margin.right)
            .attr('height', height + margin.top + margin.bottom)

        @plot = @obj.append('g')
            .attr("transform", "translate( #{margin.left}, #{margin.top})")
            .attr('width', width)
            .attr('height', height)

        @plot.append("g")
            .attr("id","x-axis")
            .attr("class", "axis")
            .attr("transform", "translate(0, #{height})")
            .call(@xAxis)

        @plot.append("g")
            .attr("id","y-axis")
            .attr("class", "axis")
            .attr("transform", "translate(0, 0)")
            .call(@yAxis)

        @plot.selectAll("line.horizontalGrid")
            .data(Fig.T2px.ticks(4))
            .enter()
            .append("line")
            .attr("class", "horizontalGrid")
            .attr("x1", 0)
            .attr("x2", width)
            .attr("y1", (d) -> Fig.T2px d)
            .attr("y2", (d) -> Fig.T2px d)
            .attr("fill", "none")
            .attr("shape-rendering", "crispEdges")
            .attr("stroke", "black")
            .attr("stroke-width", "1px")

        @plot.selectAll("line.verticalGrid")
            .data(Fig.d2px.ticks(4))
            .enter()
            .append("line")
            .attr("class", "verticalGrid")
            .attr("y1", 0)
            .attr("y2", height)
            .attr("x1", (d) -> Fig.d2px d)
            .attr("x2", (d) -> Fig.d2px d)
            .attr("fill", "none")
            .attr("shape-rendering", "crispEdges")
            .attr("stroke", "black")
            .attr("stroke-width", "1px")

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

        @yAxis = d3.svg.axis()
            .scale(Fig.T2px)
            .orient("left")

class Guide extends d3Object

    r = 10 # circle radius
    margin = {top: 20, right: 20, bottom: 20, left: 20}
    width = 480 - margin.left - margin.right
    height = 480 - margin.top - margin.bottom
    
    constructor: ()->
        
        super "guide"

        # housekeeping
        @obj.on("click", null)  # Clear any previous event handlers.
        d3.behavior.drag().on("drag", null)  # Clear any previous event handlers.

        @obj.attr('width', width + margin.left + margin.right)
            .attr('height', height + margin.top + margin.bottom)

        @region = @obj.append('g')
            .attr("transform", "translate( #{margin.left}, #{margin.top})")
            .attr('width', width)
            .attr('height', height)

        # Initial marker positions
        @x1 = Fig.d2px 1.5
        @y1 = Fig.T2px 230 
        @x2 = Fig.d2px 4
        @y2 = Fig.T2px 270
        @xl = Fig.d2px 2
        @yl = Fig.T2px 250
        
        @circle1 = @region.append("circle")
            .attr("transform", "translate(#{@x1}, #{@y1})")
            .attr("r", r)
            .attr("xx", @x1)
            .attr("yy", @y1)
            .attr("class", "modelcircle")
            .call(
                d3.behavior
                .drag()
                .on("drag", => @moveCircle(@circle1, d3.event.x, d3.event.y))
            )

        @circle2 = @region.append("circle")
            .attr("transform", "translate(#{@x2}, #{@y2})")
            .attr("r", r)
            .attr("xx", @x2)
            .attr("yy", @y2)
            .attr("class", "modelcircle")
            .call(
                d3.behavior
                .drag()
                .on("drag", => @moveCircle(@circle2, d3.event.x, d3.event.y))
            )

        # line connecting circles
        @line12 = @region.append("line")
            .attr("x1", @x1)
            .attr("y1", @y1)
            .attr("x2", @x2)
            .attr("y2", @y2)
            .attr("class", "modelline")

        # vertical dashed line
        @lineX = @region.append("line")
            .attr("x1", 0)
            .attr("y1", margin.top)
            .attr("x2", 0)
            .attr("y2", height + margin.top)
            .attr("class","guideline")
            .attr("transform", "translate(#{@x1}, #{0})")
            .attr("xx", @xl)
            .attr("yy", 0)
            .attr("style","cursor:crosshair")
            .call(
                d3.behavior
                .drag()
                .on("drag", => @moveLine(@lineX, d3.event.x, -1))
            )

        # horizontal dashed line
        @lineY = @region.append("line")
            .attr("x1", margin.left)
            .attr("y1", 0)
            .attr("x2", width + margin.left)
            .attr("y2", 0)
            .attr("class","guideline")
            .attr("transform", "translate(#{0}, #{@y2})")
            .attr("xx", 0)
            .attr("yy", @yl)
            .attr("style","cursor:crosshair")
            .call(
                d3.behavior
                .drag()
                .on("drag", => @moveLine(@lineY, -1, d3.event.y))
            )
 
    initAxes: ->
   
    moveCircle: (circ, x, y) ->
        console.log "?????"
        @dragslide(circ, x, y)
        x1 = @circle1.attr("xx")
        y1 = @circle1.attr("yy")
        x2 = @circle2.attr("xx")
        y2 = @circle2.attr("yy")
        @line12.attr("x1",x1)
            .attr("y1",y1)
            .attr("x2",x2)
            .attr("y2",y2)
        slope = (Fig.px2T(y2)-Fig.px2T(y1))/(Fig.px2d(x2)-Fig.px2d(x1))
        inter = Fig.px2T(y1)-slope*Fig.px2d(x1)
        d3.select("#equation").html(model_text([inter, slope]))

    moveLine: (line, x, y) ->
        @dragslide(line, x, y)
        xx = @lineX.attr("xx")
        yy = @lineY.attr("yy")
        d3.select("#intersection")
            .html(lines_text([@x.invert(xx), @y.invert(yy)]))

    dragslide: (obj, x, y) ->
        xx = 0
        yy = 0
        if x>0
            xx = Math.max(margin.left, Math.min(width+margin.left, x))
        if y>0
            yy = Math.max(margin.top, Math.min(height+margin.top, y))
        obj.attr "transform", "translate(#{xx}, #{yy})"
        obj.attr("xx", xx)
        obj.attr("yy", yy)

    model_text = (p) ->
        a = (n) -> Math.round(100*p[n])/100
        s = (n) -> "<span style='color:green;font-size:14px'>#{a(n)}</span>"
        tr = (td1, td2) -> 
            "<tr><td style='text-align:right;'>#{td1}</td><td>#{td2}</td><tr/>"
        """
        <table class='func'>
        Model:
        #{tr "a = ", s(1)}
        #{tr "b = ", s(0)}
        </table>
        """    

    lines_text = (p) ->
        a = (n) -> Math.round(100*p[n])/100
        s = (n) -> "<span style='color:red;font-size:14px'>#{a(n)}</span>"
        tr = (td1, td2) -> 
            "<tr><td style='text-align:right;'>#{td1}</td><td>#{td2}</td><tr/>"
        """
        <table class='func'>
        Crosshair:
        #{tr "x = ", s(0)}
        #{tr "T = ", s(1)}
        </table>
        """    

#data = [[1, 230], [2, 240], [3, 250], [4, 260], [5, 290]]
$blab.plot = new Plot #data
#$blab.plot.update data
new Guide


