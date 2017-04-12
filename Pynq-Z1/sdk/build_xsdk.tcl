# This script called from xsdk -batch will generate a SDK workspace here 
#   Additionally, will build a hw project and bsp

sdk setws .

# Creating the hardware definition folders
if {![file exists "hw_def_iop"]} {
    sdk createhw -name hw_def_iop -hwspec ./base.hdf
}
if {![file exists "hw_def_intf"]} {
    sdk createhw -name hw_def_intf -hwspec ./interface.hdf
}

# Building all the BSPs
if {![file exists "bsp_pmod_iop"]} {
    sdk createbsp -name bsp_pmod_iop -hwproject hw_def_iop -proc iop1_mb -os standalone
}
if {![file exists "bsp_arduino_iop"]} {
    sdk createbsp -name bsp_arduino_iop -hwproject hw_def_iop -proc iop3_mb -os standalone
}
if {![file exists "bsp_arduino_intf"]} {
    sdk createbsp -name bsp_arduino_intf -hwproject hw_def_intf -proc iop3_mb -os standalone
}


sdk build all

puts "To use SDK, from this folder execute"
puts "    xsdk -workspace ."

exit