#!vanilla

pi = Math.PI

#$("#test").attr 'src', 'test.png'

$("#idea").attr 'src', 'Mars_pathfinder_panorama_large.jpg'
$("#data").attr 'src', 'Antwrp_gsfc_nasa_gov_apod_ap040510.jpg'
$("#analysis").attr 'src', 'Eagle_crater_on_the_Mars_PIA05163.jpg'


class Fig

    @margin = {top: 20, right: 20, bottom: 20, left: 20}
    @width = 480 - @margin.left - @margin.right
    @height = 480 - @margin.top - @margin.bottom

    @boreDia = 50

    # depth <-> pixels
    @d2px = d3.scale.linear()
        .domain([0, 5])
        .range([0, @width])
    @px2d = @d2px.invert

    # temperature <-> pixels
    @T2px = d3.scale.linear()
        .domain([200, 300])
        .range([@height, 0])
    @px2T = @T2px.invert

    # depth <-> temperature
    @d2T = d3.scale.linear()
        .domain([0, 5])
        .range([200, 300])
    @T2d = @d2T.invert

$blab.Fig = Fig


class d3Object

    constructor: (id) ->
        @element = d3.select "##{id}"
        @element.selectAll("svg").remove()
        @obj = @element.append "svg"
        @initAxes()

    append: (obj) -> @obj.append obj
    
    initAxes: ->

class Mars extends d3Object

    constructor: () ->
        super "mars"
        
        @obj.attr("width", Fig.width + Fig.margin.left + Fig.margin.right)
        @obj.attr("height", Fig.height + Fig.margin.top + Fig.margin.bottom)

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
            circle = @obj.select("#mars-heat")
            repeat = ->
                circle = circle
                    .transition()
                    .duration(1000)
                    .attr("opacity", 0)
                    .attr("r", 10)
                    .transition()
                    .duration(20)
                    .attr("opacity", 1)
                    .attr("r", 10)
                    .transition()
                    .duration(10000)
                    .attr("opacity", 0)
                    .attr("r", 250)
                    .ease('linear')
                    .each("end", repeat)
            repeat()

        @obj.append("circle")
            .attr("id", "mars-heat")
            .attr("cx", Fig.width / 2)
            .attr("cy", Fig.height / 2)
            .style("fill", "url(#rad-gradient)")
            #.each(pulse)

        @projection = d3.geo.orthographic()
            .scale(120)
            .translate([Fig.width / 2, Fig.height / 2])
            .clipAngle(90 + 1e-6)
            .precision(.3)
            .rotate([0, -45, 0])

        path = d3.geo.path()
            .projection(@projection)

        graticule = d3.geo.graticule()

        @obj.append("path")
            .datum({type: "Sphere"})
            .attr("class", "sphere")
            .attr("d", path);
    
        @obj.append("path")
            .datum(graticule)
            .attr("class", "graticule")
            .attr("stroke-color", "red")
            .attr("d", path);

    stop: () ->
        d3.select("#mars-heat")
            .transition()
            .duration(0)
    
        

class Crust extends d3Object

    constructor: () ->
        super "crust"

        @obj.attr("width", Fig.width + Fig.margin.left + Fig.margin.right)
        @obj.attr("height", Fig.height + Fig.margin.top + Fig.margin.bottom)

        @width = Fig.width
        @height = Fig.height*0.4
        @y = Fig.height/2

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
            .attr('y', @y)
            .attr("width", @width)
            .attr("height", @height)
            .style("fill", "url(#lin-gradient)");

        bore = @obj.append("rect")
            .attr('y', @y + @height/2 - Fig.boreDia/2)
            .attr("width", @width)
            .attr("height", Fig.boreDia)
            .style("fill", 'grey');


class Thermo extends d3Object

    constructor: ->
        
        super "thermo"

        @obj.attr("width", Fig.width + Fig.margin.left + Fig.margin.right)
        @obj.attr("height", Fig.height + Fig.margin.top + Fig.margin.bottom)

        console.log "???", crust.y, crust.height/2, Fig.boreDia
        @y = crust.y + crust.height/2 - Fig.boreDia/2
        
        @thermoDisp = iopctrl.segdisplay()
            .width(80)
            .digitCount(4)
            .negative(false)
            .decimals(1)

        @lift = @obj.append('g')
            .attr("id", "lift")

        @lift.append("rect")
            .attr('x', 0)
            .attr('y', 0)
            .attr("width", 100)
            .attr("height", Fig.boreDia)
            .style("fill", "green")
            .style("opacity", 0.5);

        @lift.append("g")
            .attr("class", "digital-display")
            .attr("transform", "translate(10, 10)")
            .call(@thermoDisp)


        d3.select("#thermo-label").style("top", "#{@y-25}px")
        d3.select("#thermo-units").style("top", "#{@y+Fig.boreDia+5}px")
        
       
        @depth 0

            
    val: (u) -> @thermoDisp.value(u)

    depth: (u) ->
        @lift.attr("transform", "translate(#{Fig.d2px(u)-50}, #{@y})")
        d3.select("#thermo-label").style("left", "#{Fig.d2px(u)+10-50}px")
        d3.select("#thermo-units").style("left", "#{Fig.d2px(u)+10-50}px")


class Control extends d3Object

    constructor: ->
        
        super "control"

        @y = 100
        @d = 2.5
        
        @tape = @obj.append("g")
            .attr("class", "axis")
            .attr("transform", "translate(#{0}, #{@y-20})")
                .call(@xAxis) 

        @guide = @obj.append('line')
            .attr('x1', 0)
            .attr('x2', 0)
            .attr('y1', @y-20)
            .attr('y2', crust.y+40)
            .style("stroke", 'black')
            .style("stroke-width","1")
            .style("stroke-dasharray", ("3, 3"))

        m = @marker()
            .attr("cx", 0)
            .attr("cy", (@y+crust.y)/2-10)

        d3.select("#depth-label")
            .style("top", "25px")
            .style("left", "#{Fig.width/2-25}px")
        d3.select("#thermo-left").style("top", "#{(@y+crust.y)/2-20}px")
        d3.select("#thermo-right").style("top", "#{(@y+crust.y)/2-20}px")

        @dragMarker(m, Fig.d2px(@d))
        
    marker: () ->
        m = @obj.append('circle')
            .attr('r', 15)
            .style('fill', 'black')
            .style('stroke', 'black')
            .style('stroke-width','1')
            .call(
                d3.behavior
                .drag()
                .origin(=>
                    x:m.attr("cx")
                    #y:m.attr("cy")
                )
                #.on("drag", => @dragMarker(m, d3.mouse(@plotArea.node())))
                .on("drag", => @dragMarker(m, d3.event.x))
            )

    dragMarker: (marker, x) ->
        @d = Fig.px2d x
        @d = 0 if @d<0
        @d = 5 if @d>5    
        return if  ((@d>=5) or (@d<=0))
        marker.attr("cx", x)
        thermo.depth @d
        @guide.attr('x1', x)
        @guide.attr('x2', x)
        d3.select("#thermo-left").style("left", "#{x-105}px")
        d3.select("#thermo-right").style("left", "#{x+20}px")

    initAxes: ->
        @xAxis = d3.svg.axis()
            .scale(Fig.d2px)
            .orient("top")
            .ticks(10)

###
class Plot extends d3Object

    margin = {top: 20, right: 20, bottom: 20, left: 20}
    width = 480 - margin.left - margin.right
    height = 480 - margin.top - margin.bottom
    
    constructor: (@data) ->
        
        super "plot"

        @obj.attr('width', width + margin.left + margin.right)
            .attr('height', height/2 + margin.top + margin.bottom)

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

        plot.selectAll("line.verticalGrid")
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

        data = $blab.data # [[2, 240], [3, 250]]

        plot.selectAll("circle.marker")
            .data(data)
            .enter()
            .append("circle")
            .attr("class", "marker")
            .attr("cx", (d) -> Fig.d2px d[0])
            .attr("cy", (d) -> Fig.T2px d[1])
            .attr("r", "5")
            .attr("fill", "none")
            .attr("shape-rendering", "crispEdges")
            .attr("stroke", "black")
            .attr("stroke-width", "1px")

    initAxes: ->

        @xAxis = d3.svg.axis()
            .scale(Fig.d2px)
            .orient("bottom")

        @yAxis = d3.svg.axis()
            .scale(Fig.T2px)
            .orient("left")
###

class Simulation

    constructor: ->
        @a = 0.5
        @T = 200
        @angle = 0
        
    start: () ->
        setTimeout (=> @animate() ), 200
        
    snapshot: () ->
        @T = (1-@a)*@T + @a*Fig.d2T(control.d)
        thermo.val @T

    animate: () ->
        @timer = setInterval (=> @snapshot()), 1000
        

    stop: ->
        clearInterval @timer
        @timer = null

###
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

###

mars = new Mars
crust = new Crust
thermo = new Thermo
control = new Control
sim = new Simulation
sim.start()
#new Plot
#new Guide

$("#stop-heat").on "click", =>
    mars.stop()
