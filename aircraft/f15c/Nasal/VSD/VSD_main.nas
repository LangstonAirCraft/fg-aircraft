# F-15 VSD - based on Enrique Laso (Flying toaster) F-20 HUD main module

#angular definitions
#up angle 1.73 deg
#left/right angle 5.5 deg
#down angle 10.2 deg
#total size 11x11.93 deg
#texture square 256x256
#bottom left 0,0
#viewport size  236x256
#center at 118,219
#pixels per deg = 21.458507963

var prop_v = props.globals.getNode("/fdm/jsbsim/velocities/v-fps");
var prop_w = props.globals.getNode("/fdm/jsbsim/velocities/w-fps");
var prop_speed = props.globals.getNode("/fdm/jsbsim/velocities/vt-fps");
#var groundspeed = props.globals.getNode("velocities/ground-speed-kt",1);
                                        

var VSDcanvas= canvas.new({
                           "name": "F-15 VSD",
                           "size": [1024,1024], 
                           "view": [256,256],                       
                           "mipmapping": 1     
                          });                          
                          
VSDcanvas.addPlacement({"node": "VSDImage"});
VSDcanvas.setColorBackground(0.0039215686274509803921568627451,0.17647058823529411764705882352941,0, 1.00);

# Create a group for the parsed elements
var VSDsvg = VSDcanvas.createGroup();
 
# Parse an SVG file and add the parsed elements to the given group
print("Parse SVG ",canvas.parsesvg(VSDsvg, "Nasal/VSD/VSD.svg"));
#VSDsvg.setTranslation (-20.0, 37.0);
print("VSD INIT");
 
var window1 = VSDsvg.getElementById("window-1");
window1.setFont("condensed.txf").setFontSize(12, 1.2);
var window2 = VSDsvg.getElementById("window-2");
window2.setFont("condensed.txf").setFontSize(12, 1.2);
var window3 = VSDsvg.getElementById("window-3");
window3.setFont("condensed.txf").setFontSize(12, 1.2);

var window4 = VSDsvg.getElementById("window-4");
window4.setFont("condensed.txf").setFontSize(12, 1.2);
var acue = VSDsvg.getElementById("ACUE");
acue.setFont("condensed.txf").setFontSize(12, 1.2);
acue.setText ("A");
acue.setVisible(0);
var ecue = VSDsvg.getElementById("ECUE");
ecue.setFont("condensed.txf").setFontSize(12, 1.2);
ecue.setText ("E");
ecue.setVisible(0);
var morhcue = VSDsvg.getElementById("MORHCUE");
morhcue.setFont("condensed.txf").setFontSize(12, 1.2);
morhcue.setText ("mh");
morhcue.setVisible(0);

#        var tgt = VSDsvg.getElementById("target_friendly_"~target_idx);
#        var tgt = VSDsvg.getElementById("target_friendly_0");
var max_symbols = 10;
var tgt_symbols =  setsize([], max_symbols);
for (var i = 0; i < max_symbols; i += 1)
{
    var name = "target_friendly_"~i;
    var tgt = VSDsvg.getElementById(name);
    if (tgt != nil)
    {
        tgt_symbols[i] = tgt;
        tgt.setVisible(0);
    }
}

var horizon_line = VSDsvg.getElementById("horizon_line");
var nofire_cross =  VSDsvg.getElementById("nofire_cross");
var target_circle = VSDsvg.getElementById("target_circle");
var updateVSD = func ()
{  
    var 	pitch = getprop("orientation/pitch-deg");
    var 	roll = getprop("orientation/roll-deg");
    var 	roll = getprop("orientation/roll-deg");
    var alt = getprop("position/altitude-ft");
    var  roll_rad = -roll*3.14159/180.0;
    var heading = getprop("orientation/heading-deg");
    var pitch_offset = 12;
    var pitch_factor = 1.98;


    horizon_line.setTranslation (0.0, pitch * pitch_factor+pitch_offset);                                           
#horizon_line.setCenter (118,830 - pitch * pitch_factor-pitch_offset);
    horizon_line.setRotation (roll_rad);

    if (getprop("sim/model/f15/instrumentation/radar-awg-9/hud/target-display"))
    {   
#       window3.setText (sprintf("%s: %3.1f", getprop("sim/model/f15/instrumentation/radar-awg-9/hud/target"), getprop("sim/model/f15/instrumentation/radar-awg-9/hud/distance")));
        nofire_cross.setVisible(1);
        target_circle.setVisible(1);
    }
    else
    {
#       window3.setText ("");
        nofire_cross.setVisible(0);
        target_circle.setVisible(0);
    }
    
    window1.setText ("     VS BST   MEM  LSG/000");

    var target_idx=0;
    window4.setText (sprintf("%3d", getprop("instrumentation/radar/radar2-range")));
    var w3_22="";
    var w3_7 = sprintf("T%4d",getprop("fdm/jsbsim/velocities/vc-kts"));
    var w2 = "";
    var designated = 0;
    foreach( u; awg_9.tgts_list ) 
    {
        var callsign = "XX";
        if(u.get_display() and u.airbone)
        {
            if (u.Callsign != nil)
                callsign = u.Callsign.getValue();
            var model = "XX";
            if (u.ModelType != "")
                model = u.ModelType;
            if (target_idx < max_symbols)
            {
                tgt = tgt_symbols[target_idx];
                if (tgt != nil)
                {
#                    if (u.airbone and !designated)
                    if (target_idx == 0)
                    {
                        designated = 1;
                        w2 = sprintf("%-4d", u.get_closure_rate());
                        w3_22 = sprintf("%3d-%2d %.5s %.4s",u.get_bearing(), u.get_range(), callsign, model);
                    }
                    tgt.setVisible(u.get_display());
                    var xc = u.get_deviation(heading);
                    var yc = -u.get_total_elevation(pitch);
                    tgt.setVisible(1);
                    tgt.setTranslation (xc, yc);
#tgt.setCenter (118,830 - pitch * pitch_factor-pitch_offset);
#tgt.setRotation (roll_rad);
                }
            }
            target_idx = target_idx+1;
        }
    }
    window2.setText(w2);
    window3.setText(sprintf("G%3.0f %3s-%4s%s %s %s",
                            getprop("velocities/groundspeed-kt"),
                            "","","",
                            w3_7 , 
                            w3_22));
    for(var nv = target_idx; nv < max_symbols;nv += 1)
    {
        tgt = tgt_symbols[nv];
        if (tgt != nil)
        {
            tgt.setVisible(0);
        }
    }
}
