#!vanilla

pi = Math.PI

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

        gradient = @obj.append("defs").append("radialGradient")
            .attr("id", "gradient")
            .attr("cx", "75%")
            .attr("cy", "25%");

        gradient.append("stop")
            .attr("offset", "5%")
            .attr("stop-color", "#aaa")

        gradient.append("stop")
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
            .style("fill", "url(#gradient)")
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


new Mars
