#!vanilla

$blab.noGitHubRibbon = true;

# import
Fig = $blab.Fig

# figures
$("#idea-img").attr 'src', 'insight.png'
$("#exp-img").attr 'src', 'insight.png'
$("#data-img").attr 'src', 'insight.png'
$("#analysis-img").attr 'src', 'insight.png'

class Simulation

    constructor: ->
        @r = 0.5 # low-pass bandwidth
        @T = 220 # instrument temp at t=0.
        
    start: () ->
        setTimeout (=> @animate() ), 200
        
    snapshot: () ->
        @T = (1-@r)*@T + @r*Fig.d2T($blab.control.d)
        $blab.thermo.val @T

    animate: () ->
        @timer = setInterval (=> @snapshot()), 1000
        
    stop: ->
        clearInterval @timer
        @timer = null

sim = new Simulation
sim.start()
