#!vanilla

$blab.noGitHubRibbon = true;

# import
Fig = $blab.Fig

# figures
$("#idea-img").attr 'src', '730932main_pia16079-full_full.jpg'
$("#exp-img").attr 'src', '730932main_pia16079-full_full.jpg'
$("#data-img").attr 'src', '730932main_pia16079-full_full.jpg'
$("#analysis-img").attr 'src', '730932main_pia16079-full_full.jpg'

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
