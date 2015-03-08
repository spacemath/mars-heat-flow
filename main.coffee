#!vanilla

pi = Math.PI

$("#test").attr 'src', 'test.png'

class d3Object

    constructor: (id) ->
        @element = d3.select "##{id}"
        @element.selectAll("svg").remove()
        @obj = @element.append "svg"
        @initAxes()

    append: (obj) -> @obj.append obj
    
    initAxes: ->

class Mars extends d3Object

    margin = {top: 20, right: 20, bottom: 20, left: 20}
    width = 480 - margin.left - margin.right
    height = 480 - margin.top - margin.bottom
    
    constructor: () ->
        super "mars"
        
        @obj.attr("width", width + margin.left + margin.right)
        @obj.attr("height", height + margin.top + margin.bottom)

        radialGradient = @obj.append("defs").append("radialGradient")
            .attr("id", "rad-gradient")
            .attr("cx", "75%")
            .attr("cy", "25%");

        radialGradient.append("stop")
            .attr("offset", "5%")
            .attr("stop-color", "#aaa")

        radialGradient.append("stop")
            .attr("offset", "100%")
            .attr("stop-color", "#faa");

        pulse = =>
            circle = @obj.select("circle")
            repeat = ->
                circle = circle.transition()
                    .duration(20)
                    .attr("stroke-width", 5)
                    .attr("opacity", 1)
                    .attr("r", 10)
                    .transition()
                    .duration(5000)
                    .attr('stroke-width', 0.5)
                    .attr("opacity", 0)
                    .attr("r", 100)
                    .ease('linear')
                    .each("end", repeat)
            repeat()

        @obj.append("circle")
            .attr("cx", width / 2)
            .attr("cy", height / 2)
            .attr("r", 240)
            .style("fill", "url(#rad-gradient)")
            .each(pulse)

        projection = d3.geo.orthographic()
            .scale(60)
            .translate([width / 2, height / 2])
            .clipAngle(90 + 1e-6)
            .precision(.3);

        path = d3.geo.path()
            .projection(projection);

        graticule = d3.geo.graticule();

        @obj.append("path")
            .datum({type: "Sphere"})
            .attr("class", "sphere")
            .attr("d", path);
    
        @obj.append("path")
            .datum(graticule)
            .attr("class", "graticule")
            .attr("stroke-color", "red")
            .attr("d", path);


class Data

    @margin = {top: 0, right: 50, bottom: 0, left: 50}
    @width = 480
    @height = 480
    @boreDia = 50
    
    @d2px = d3.scale.linear() # depth to pixels 
        .domain([0, 5])
        .range([0, @width])

    @px2d = @d2px.invert # pixels to depth

    @T2px = d3.scale.linear() # depth to pixels 
        .domain([200, 300])
        .range([@height, 0])

    @px2T = @T2px.invert

    @px2d = @d2px.invert # pixels to depth

    @d2T = d3.scale.linear() # depth to temperature 
        .domain([0, 5])
        .range([200, 300])

    @T2d = @d2T.invert # temperature to depth

class Crust extends d3Object

    constructor: () ->
        super "crust"

        width = Data.width
        height = Data.height*0.4
        
        @obj.attr("width", width)
        @obj.attr("height", height)

        linearGradient = @obj.append("defs").append("linearGradient")
            .attr("id", "lin-gradient")
            .attr("x1", "0%")
            .attr("y1", "100%")
            .attr("x2", "100%")
            .attr("y2", "100%")
            .attr("spreadMethod", "pad");

        linearGradient.append("stop")
            .attr("offset", "0%")
            .attr("stop-color", "#ccc")
            .attr("stop-opacity", 1);

        linearGradient.append("stop")
            .attr("offset", "100%")
            .attr("stop-color", "#fcc")
            .attr("stop-opacity", 1);

        soil = @obj.append("rect")
            .attr('y', Data.height/2 - height/2)
            .attr("width", width)
            .attr("height", height)
            .style("fill", "url(#lin-gradient)");

        bore = @obj.append("rect")
            .attr('y', Data.height/2 - Data.boreDia/2)
            .attr("width", width)
            .attr("height", Data.boreDia)
            .style("fill", 'grey');


class Thermo extends d3Object

    constructor: ->
        
        super "thermo"

        y = Data.height/2 - Data.boreDia/2
        
        @thermoDisp = iopctrl.segdisplay()
            .width(80)
            .digitCount(4)
            .negative(false)
            .decimals(1)

        @lift = @obj.append('g')



        @lift.append("rect")
            .attr('x', 0)
            .attr('y', y)
            .attr("width", 100)
            .attr("height", Data.boreDia)
            .style("fill", "green")
            .style("opacity", 0.5);
        
        @lift.append("g")
            .attr("class", "digital-display")
            .attr("transform", "translate(10, #{y+10})")
            .call(@thermoDisp)
        
        @depth 0

        #@obj.append("text")
        #    .attr("text-anchor", "left")
        #    .attr("x", 50)
        #    .attr("y", 50)
        #    .text("GMS braking starts:")
        #    .attr("title","Global mitigation scheme (GMS) starts at this date.")
            
    val: (u) -> @thermoDisp.value(u)

    depth: (u) -> @lift.attr("transform", "translate(#{Data.d2px(u)}, 0)")


class Control extends d3Object

    constructor: ->
        
        super "control"

        y = 100
        @d = 0
        
        @tape = @obj.append("g")
            .attr("class", "axis")
            .attr("transform", "translate(#{0}, #{y-20})")
                .call(@xAxis) 

        @guide = @obj.append('line')
            .attr('x1', 0)
            .attr('x2', 0)
            .attr('y1', 0)
            .attr('y2', Data.height)
            .style("stroke", 'black')
            .style("stroke-width","1")

        @marker()
            .attr("cx", 0)
            .attr("cy", 25)

    marker: () ->
        m = @tape.append('circle')
            .attr('r', 15)
            .style('fill', 'black')
            .style('stroke', 'black')
            .style('stroke-width','1')
            .call(
                d3.behavior
                .drag()
                .origin(=>
                    x:m.attr("cx")
                    y:m.attr("cy")
                )
                #.on("drag", => @dragMarker(m, d3.mouse(@plotArea.node())))
                .on("drag", => @dragMarker(m, d3.event.x))
            )

    dragMarker: (marker, x) ->
        @d = Data.px2d x
        return if  ((@d>5) or (@d<0))
        marker.attr("cx", x)
        thermo.depth @d
        @guide.attr('x1', x)
        @guide.attr('x2', x)
        

    initAxes: ->
        @xAxis = d3.svg.axis()
            .scale(Data.d2px)
            .orient("top")
            .ticks(10)

class Plot extends d3Object

    margin = {top: 20, right: 20, bottom: 20, left: 20}
    width = 480 - margin.left - margin.right
    height = 480 - margin.top - margin.bottom
    
    constructor: (@data) ->
        
        super "plot"

        @obj.attr('width', width + margin.left + margin.right)
            .attr('height', height/2 + margin.top + margin.bottom)

        ###

        plot = @obj.append('g')
            .attr("transform", "translate( #{margin.left}, #{margin.top})")
            .attr('width', width)
            .attr('height', height)

        plot.append("g")
            .attr("id","x-axis")
            .attr("class", "axis")
            .attr("transform", "translate(0, #{height})")
            .call(@xAxis)

        plot.append("g")
            .attr("id","y-axis")
            .attr("class", "axis")
            .attr("transform", "translate(0, 0)")
            .call(@yAxis)

        plot.selectAll("line.horizontalGrid")
            .data(Data.T2px.ticks(4))
            .enter()
            .append("line")
            .attr("class", "horizontalGrid")
            .attr("x1", 0)
            .attr("x2", width)
            .attr("y1", (d) -> Data.T2px d)
            .attr("y2", (d) -> Data.T2px d)
            .attr("fill", "none")
            .attr("shape-rendering", "crispEdges")
            .attr("stroke", "black")
            .attr("stroke-width", "1px")

        plot.selectAll("line.verticalGrid")
            .data(Data.d2px.ticks(4))
            .enter()
            .append("line")
            .attr("class", "verticalGrid")
            .attr("y1", 0)
            .attr("y2", height)
            .attr("x1", (d) -> Data.d2px d)
            .attr("x2", (d) -> Data.d2px d)
            .attr("fill", "none")
            .attr("shape-rendering", "crispEdges")
            .attr("stroke", "black")
            .attr("stroke-width", "1px")

        data = [[2, 240], [3, 250]]

        plot.selectAll("circle.marker")
            .data(data)
            .enter()
            .append("circle")
            .attr("class", "marker")
            .attr("cx", (d) -> Data.d2px d[0])
            .attr("cy", (d) -> Data.T2px d[1])
            .attr("r", "5")
            .attr("fill", "none")
            .attr("shape-rendering", "crispEdges")
            .attr("stroke", "black")
            .attr("stroke-width", "1px")
        ###

    initAxes: ->

        @xAxis = d3.svg.axis()
            .scale(Data.d2px)
            .orient("bottom")

        @yAxis = d3.svg.axis()
            .scale(Data.T2px)
            .orient("left")

class Simulation

    constructor: ->
        @a = 0.5
        @T = 200
        
    start: () ->
        setTimeout (=> @animate() ), 200
        
    snapshot: () ->
        @T = (1-@a)*@T + @a*Data.d2T(control.d)
        thermo.val @T

    animate: () ->
        @timer = setInterval (=> @snapshot()), 1000

    stop: ->
        clearInterval @timer
        @timer = null

class Guide extends d3Object

    r = 10 # circle radius
    margin = {top: 20, right: 20, bottom: 20, left: 20}
    width = 480 - margin.left - margin.right
    height = 480 - margin.top - margin.bottom
    
    constructor: ()->
        
        super "guide"

        # housekeeping
        @obj.on("click", null)  # Clear any previous event handlers.
        #@obj.on("click", => @click())
        d3.behavior.drag().on("drag", null)  # Clear any previous event handlers.

        @obj.attr('width', width + margin.left + margin.right)
            .attr('height', height + margin.top + margin.bottom)

        @region = @obj.append('g')
            .attr("transform", "translate( #{margin.left}, #{margin.top})")
            .attr('width', width)
            .attr('height', height)

        # Initial marker positions
        @x1 = Data.d2px 1.5
        @y1 = Data.T2px 230 
        @x2 = Data.d2px 4
        @y2 = Data.T2px 270
        @xl = Data.d2px 2
        @yl = Data.T2px 250
        
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
        slope = (Data.px2T(y2)-Data.px2T(y1))/(Data.px2d(x2)-Data.px2d(x1))
        inter = Data.px2T(y1)-slope*Data.px2d(x1)
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

new Mars
new Crust
thermo = new Thermo
control = new Control
sim = new Simulation
sim.start()
new Plot
new Guide
