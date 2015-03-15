class $blab.Fig

    @F = 0.030 # heat flux (W/m^2)
    @k = 0.020 # heat conductivity (W/mK)
    @a = @F/@k # slope of temperature plot

    @D = 5 # maximum depth (m)
    @T0 = 220 # temperature at d=0 (K)
    @TD = @T0 + @D*@a # temperature at d=D
    
    @margin = {top: 50, right: 50, bottom: 50, left: 50}
    @width = 450 - @margin.left - @margin.right
    @height = 450 - @margin.top - @margin.bottom

    @boreDia = 50

    # depth <-> pixels
    @d2px = d3.scale.linear()
        .domain([0, @D])
        .range([0, @width])
    @px2d = @d2px.invert

    # temperature <-> pixels
    @T2px = d3.scale.linear()
        .domain([215, 230])
        .range([@height, 0])
    @px2T = @T2px.invert

    # depth <-> temperature
    @d2T = d3.scale.linear()
        .domain([0, 5])
        .range([@T0, @TD])
    @T2d = @d2T.invert

class $blab.d3Object

    constructor: (id) ->
        @element = d3.select "##{id}"
        @element.selectAll("svg").remove()
        @obj = @element.append "svg"
        @initAxes()

    append: (obj) -> @obj.append obj
    
    initAxes: ->

