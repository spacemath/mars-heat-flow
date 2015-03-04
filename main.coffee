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
        
        pulse = =>
            circle = @obj.select("circle")
            repeat = ->
                circle = circle.transition()
                    .duration(2000)
                    .attr("stroke-width", 20)
                    .attr("r", 10)
                    .transition()
                    .duration(2000)
                    .attr('stroke-width', 0.5)
                    .attr("r", 200)
                    .ease('sine')
                    .each("end", repeat)
            repeat()
            
        @heat = @obj.append('circle')
            .attr("cx", width/2)
            .attr("cy", height/2)
            .style('fill', 'transparent')
            .style('stroke', 'red')
            .style('stroke-width','1')
            .attr('r', 10)
            .each(pulse)

new Mars
