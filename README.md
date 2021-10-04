# clipper
slice and save samples, record and play cv for monome crow and norns. 

## sample player instructions

### key/encoder controls
access instructions for key/encoder controls within the script by pressing k1+e3

* all screens
  * e1: next/prev screen
  * e2: next/prev control
* screen 1: select/play sample 
  * k2: select sample to slice up
  * e3: incr/decr playhead
  * k3: start/stop playhead
* screen 2: play mode
  * k2/k3: delete/add cutter
  * e3: change play mode
* screen 3: adjust cut ends
  * k2/k3: delete/add cutter
  * k1 + e2: select cutter
  * k1 + e3: adjust cutter
  * k1 + e1: fine adjust cutter
  * e3: select cutter end
* screen 4: move cutter
  * k2/k3: delete/add cutter
  * k1 + e2: select cutter
  * k1 + e3: adjust cutter
  * k1 + e1: fine adjust cutter
* screen 5: adjust rate
  * k2/k3: delete/add cutter
  * k1 + e2: select rate
  * e3: adjust all cutter rates
  * k1 + e1: fine adjust rate
  * k1 + e3: adjust selected cutter rate
* screen 6: adjust level
  * k2/k3: delete/add cutter
  * e3: adjust level
* screen 7: autogenerate cutters
  * e3: autogenerate clips by level (up to 20)
  * k1 + e3: autogenerate clips with even spacing (up to 20)

### recording clips
clips may be recorded from the PARAMETERS>EDIT menu. what gets recorded depends on the `play mode` setting:
* *stop*: record the entire sample 
* *full loop*: record the entire sample 
* *all cuts*: record all sample areas set by cutters
* *sel cut*: record the sample area set by the selected cutter

*important note*: if *play mode* is set to `all cuts`, all *rate* settings must either be positive or negative. 

## cv player/recorder instructions

the cv player code is deeply indebted to the `cvdelay` script built into @whimsicalraps [bowering](https://github.com/whimsicalraps/bowering) crow script loader

### main features
* record up to 20 seconds of cv into crow input 1. 
* crow outputs 1-4 replay the recorded cv with delay set by 4 delay taps. 
* set length of the cv from 10ms-20000ms (0.01s-20s)
* turn cv recording on and off (turning it off loops the last cv recorded)

### key/encoder controls
* all screens
  * e1: next/prev screen
  * e2: next/prev control
* screen 1: cv delay
  * k2/k3: next/prev delay tap
  * e3: increase/decrese delay time of selected tap by 10ms
  * k1+e3: increase/decrese delay time of selected tap by 100ms
* screen 2: cv player/ recorder controls
  * k2/k3: next/prev control
  * e3: increase/decrese value of selected parameter
  * k1+ e3 (loop length only): increase/decrese value of loop length by +/- 100 ms
* screen 3: reset loop
  * k2: resets the loop playhead to its starting point 

### todo
* display recorded cv in the norns ui
* setup of cutters for cv recorder (mirroring features in the sample player)
* fix bugs and error messages

## requirements
norns
crow (for cv recorder page)

## credits
many thanks to @schollz and @catfact for their excellent coding advice.
