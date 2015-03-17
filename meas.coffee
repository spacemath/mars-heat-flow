#!vanilla

# import
Fig = $blab.Fig
d3Object = $blab.d3Object

# convenience
w = Fig.width
W = Fig.width + Fig.margin.left + Fig.margin.right
h = Fig.height
H = Fig.height + Fig.margin.top + Fig.margin.bottom

class Crust extends d3Object

    constructor: () ->

        super "crust"

        @obj.attr('width', W)
            .attr('height', H)

        @crust = @obj.append('g')
            .attr("transform", "translate( #{Fig.margin.left}, 0)")
            .attr('width', w)
            .attr('height', H)

        @soilHeight = H*0.4
        @y = H/2

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

        soil = @crust.append("rect")
            .attr('y', @y)
            .attr("width", w)
            .attr("height", @soilHeight)
            .style("fill", "url(#lin-gradient)");

        bore = @crust.append("rect")
            .attr('y', @y + @soilHeight/2 - Fig.boreDia/2)
            .attr("width", w)
            .attr("height", Fig.boreDia)
            .style("fill", 'grey');


class Thermo extends d3Object

    constructor: ->
        
        super "thermo"

        @obj.attr('width', W)
            .attr('height', H)

        @thermo = @obj.append('g')
            .attr("transform", "translate( #{Fig.margin.left}, 0)")
            .attr('width', w)
            .attr('height', h)

        @y = crust.y + crust.soilHeight/2 - Fig.boreDia/2
        
        @thermoDisp = iopctrl.segdisplay()
            .width(80)
            .digitCount(4)
            .negative(false)
            .decimals(1)

        @lift = @thermo.append('g')
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
        d3.select("#thermo-label").style("left", "#{Fig.d2px(u)+10}px")
        d3.select("#thermo-units").style("left", "#{Fig.d2px(u)+10}px")


class Control extends d3Object

    xlow = Fig.d2px 0
    xhigh = Fig.d2px 5
    
    constructor: ->
        
        super "control"

        @obj.attr('width', W)
            .attr('height', H)

        @control = @obj.append('g')
            .attr("transform", "translate( #{Fig.margin.left}, 0)")
            .attr('width', w)
            .attr('height', h)

        @y = 100
        @d = 2.5
        
        @tape = @control.append("g")
            .attr("class", "axis")
            .attr("transform", "translate(#{0}, #{@y-20})")
            .call(@xAxis) 

        @guide = @control.append('line')
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
            .style("left", "#{w/2+10}px")
        d3.select("#thermo-left").style("top", "#{(@y+crust.y)/2-20}px")
        d3.select("#thermo-right").style("top", "#{(@y+crust.y)/2-20}px")

        @dragMarker(m, Fig.d2px(@d))
        
    marker: () ->

        m = @control.append('circle')
            .attr('r', 15)
            .attr('class', 'control-circle')
            .style('fill', 'black')
            .style('stroke', 'black')
            .style('stroke-width','1')
            .call(
                d3.behavior
                .drag()
                .origin(=>x:m.attr("cx"))
                .on("drag", => @dragMarker(m, d3.event.x))
            )

    dragMarker: (marker, x) ->

        return if  ((x>xhigh) or (x<xlow))

        # quantize
        @d = Math.round(Fig.px2d(x)/0.3)*0.3 # metres
        xq = Fig.d2px @d # pixels

        # move
        marker.attr("cx", xq)
        @guide.attr('x1', xq)
        @guide.attr('x2', xq)
        d3.select("#thermo-left").style("left", "#{xq-60}px")
        d3.select("#thermo-right").style("left", "#{xq+74}px")

        # set thermometer depth
        thermo.depth @d

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

