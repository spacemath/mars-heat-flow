#!vanilla

# import
Fig = $blab.Fig
d3Object = $blab.d3Object
        
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
            .each(pulse)

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
  
mars = new Mars

$("#stop-heat").on "click", =>
    mars.stop()
