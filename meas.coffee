#!vanilla

# import
Fig = $blab.Fig
d3Object = $blab.d3Object

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

crust = new Crust
thermo = new Thermo
control = new Control

# export
$blab.thermo = thermo
$blab.control = control

