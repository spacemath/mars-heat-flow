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
        .range([0, @width-100])

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
            .attr("transform", "translate(100, 0)")

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
        
        #@obj.append("text")
        #    .attr("text-anchor", "left")
        #    .attr("x", 50)
        #    .attr("y", 50)
        #    .text("GMS braking starts:")
        #    .attr("title","Global mitigation scheme (GMS) starts at this date.")
            
    val: (u) -> @thermoDisp.value(Data.d2T u)

    depth: (u) -> @lift.attr("transform", "translate(#{Data.d2px(u)}, 0)")


class Control extends d3Object

    constructor: ->
        
        super "control"

        y = 100
        @d = 0
        
        @tape = @obj.append("g")
            .attr("class", "axis")
            .attr("transform", "translate(#{50}, #{y-20})")
                .call(@xAxis) 

        @marker()
            .attr("cx", 0)
            .attr("cy", 0)

    marker: () ->
        m = @tape.append('circle')
            .attr('r',10)
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
        thermo.val @d

    initAxes: ->
        @xAxis = d3.svg.axis()
            .scale(Data.d2px)
            .orient("top")
            .ticks(10)


class Simulation

    constructor: ->
        @a = 0.5
        @T = 0
        
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


new Mars
new Crust
thermo = new Thermo

thermo.depth 3
control = new Control
sim = new Simulation
sim.start()
