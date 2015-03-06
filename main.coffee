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

    margin = {top: 0, right: 0, bottom: 0, left: 0}
    @width = 480 - margin.left - margin.right
    @height = 480 - margin.top - margin.bottom
    @boreDia = 50

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

    #margin = {top: 20, right: 20, bottom: 20, left: 20}
    #width = 480 - margin.left - margin.right
    #height = 480 - margin.top - margin.bottom
    
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
            
    val: (val) -> @thermoDisp.value(val)


new Mars
new Crust
thermo = new Thermo
thermo.val 888.8
