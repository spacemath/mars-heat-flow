class $blab.Fig

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

class $blab.d3Object

    constructor: (id) ->
        @element = d3.select "##{id}"
        @element.selectAll("svg").remove()
        @obj = @element.append "svg"
        @initAxes()

    append: (obj) -> @obj.append obj
    
    initAxes: ->

