#!vanilla

# import
Fig = $blab.Fig

# figures
$("#idea").attr 'src', 'Mars_pathfinder_panorama_large.jpg'
$("#data").attr 'src', 'Antwrp_gsfc_nasa_gov_apod_ap040510.jpg'
$("#analysis").attr 'src', 'Eagle_crater_on_the_Mars_PIA05163.jpg'


class Simulation

    constructor: ->
        @a = 0.5
        @T = 200
        @angle = 0
        
    start: () ->
        setTimeout (=> @animate() ), 200
        
    snapshot: () ->
        @T = (1-@a)*@T + @a*Fig.d2T($blab.control.d)
        $blab.thermo.val @T

    animate: () ->
        @timer = setInterval (=> @snapshot()), 1000
        
    stop: ->
        clearInterval @timer
        @timer = null

sim = new Simulation
sim.start()
