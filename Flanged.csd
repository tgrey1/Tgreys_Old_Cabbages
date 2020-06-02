<Cabbage>
;
; Flanged.csd by Kevin Welsh (tgrey)
; version 1.0 - Oct.30 2015
;
; Stereo flanger with customizable wave shapes, delay offset,
; adjustable LFO phase, option to sync LFO to host tempo/meter/
; playback start, and  a real time display of the LFO's
; position in the wave shape, with phase location, and min/max
; delay times.
;
; Depth controls maximum amount of delay when LFO is at it's,
; peak.  This scales to 25ms (this is easily changed with
; MAX_DELAY definition).  Offset shifts delay time by up to 25ms,
; meaning with max depth and max offset, a total of 50ms is
; applied when LFO is at peak.  Max offset is also easily adjusted
; from a define statement.
;
; LFO mode can be set in seconds, beats at a tempo, taps per
; beats at a tempo, measures at tempo, or taps per measure at
; tempo.  Tempo and meter can be from a DAW/host, or can be
; set internal.  LFO rate adjusts according to this mode.
;
; Phase sets the starting point in the waveform for when the 
; resync button is pushed or if "Sync to Play" is enabled,
; playback has started on the host.
;
; LFO wave shape is selectable between some premade shapes, which
; are tweakable in real time via popup sliders (customize button).
; Complete breakpoint editing will hopefully arrive in a future
; version after new additions to cabbage.
;
; Custom wave shapes can be added in three steps, documentation
; is included inline.  Search for "STEP 1", "STEP 2", and
; "STEP 3".  Tables are generated using ftgentmp and should be
; size 1024.
;
; "Stereo In"/"Mono L+R" switches wheter input is left as stereo
; or collapsed to L+R.
;
;  "Stereo Del"/"Mono Del" changes whether the left and right
; channels delay times are inversed (stereo), or are the same
; (mono).
;
; Gain applies to both wet and dry audio (but not bypassed
; audio!) and can range from -90 to +30 dB.
;
; "Dry/Wet" ranges from -1 to 1, with -1 being all dry, 0
; being a 50:50 mix, and 1 being all wet.
;
; "Balance" is a non-destructive panning, meaning panning
; full left will move the right channel to the left
; preserving all data.
;
; "Bypass" passes all audio exactly as it came, with the
; exception of any clipping applied to the input
;
#define GREEN_CB colour:0(0, 25, 0, 255), colour:1(0,255,0,255), fontcolour(160, 160, 160, 255), shape("circle"),
#define RED_CB colour:0(25, 0, 0, 255), colour:1(255,0,0,255), fontcolour(160, 160, 160, 255), shape("circle"),
#define CLIP_CB colour:0(25, 0, 0, 255), colour:1(255,0,0,255), fontcolour(160, 160, 160, 255), active(0), shape("square"),
#define SCRUB_CB colour:0(25, 0, 0, 255), colour:1(0,255,0,255), fontcolour(160, 160, 160, 255), active(0), shape("square"),
#define GAIN_KNOB colour(255, 0, 0, 160), trackercolour(0, 255, 0, 255), fontcolour(160, 160, 160, 255),
#define DW_KNOB colour(0, 95, 255, 255), trackercolour(0, 255, 0, 255), fontcolour(160, 160, 160, 255),
#define PAN_KNOB colour(125, 125, 125, 255), trackercolour(0, 255, 0, 255), fontcolour(160, 160, 160, 255),
#define EFF_KNOB colour(0,255,0,160), trackercolour(0, 255, 0, 255), fontcolour(160, 160, 160, 255),
#define FILT_KNOB colour(255, 255, 0, 160), trackercolour(0, 255, 0, 255), fontcolour(160, 160, 160, 255),
#define TEXT colour(0,0,0,0), fontcolour(160, 160, 160, 255),
#define BUTTON fontcolour:1(255, 255, 255, 255), fontcolour:0(160, 160, 160, 255), colour:0(30, 30, 30, 255), colour:1(60,60,60,255),
#define TEST_BUTTON colour:0(30, 30, 30, 255), colour:1(60,60,60,255), fontcolour:0(160, 160, 160, 255), fontcolour:1(0,255,0,255),
#define COMBO colour(30,30,30,255), fontcolour(160, 160, 160, 255),
#define NUMBOX colour(30,30,30,255), fontcolour(160, 160, 160, 255)
#define WARN_HEAD fontcolour(155, 0, 0), colour(60,60, 60, 255)
#define WARN_TEXT fontcolour(155, 155, 155), colour(60,60, 60, 255)
#define DIS_PLANT colour(55,55,55,55), fontcolour(50, 50, 50, 255), line(1), text("Disabled")
#define PLANT colour(40,40,40,255), fontcolour(160, 160, 160, 255), line(1)
#define ROOT colour(20,20,20,255)
#define GRAPH tablecolour(green), zoom(-1)
#define G_TEXT colour(255,255,255,0), fontcolour(0,255,0,105), align("right")

; STEP 1: add shape name at the **end** of SHAPE_MENU.  The order here must also match the order set in step 2.
#define SHAPE_MENU  text("Sine [8 partials]", "Line [1 seg]", "Pyramid [2 seg]", "Triangle [3 seg]", "Square [3 Seg]", "Saw [3 Seg]", "Reverse Saw [3 Seg]")

form size(380, 454), caption("Flanged"), pluginID("tfl1"), $ROOT

groupbox bounds(10, 94, 360, 350), $DIS_PLANT

groupbox bounds(10, 10, 360, 80), text("In/Out"), plant("io"), $PLANT {
  label bounds(10, 5, 120, 10), text("OL"), align("left"), $TEXT
  checkbox bounds(25, 5, 10, 10), channel("in-clip"), value(0), identchannel("in-clip-c"), $CLIP_CB
  label bounds(325, 5, 120, 10), text("OL"), align("left"), $TEXT
  checkbox bounds(340, 5, 10, 10), channel("clip"), value(0), identchannel("clip-c"), $CLIP_CB
  button bounds(70, 0, 60, 20), channel("test"), text("Test", "Testing..."), latched(1), value(0), visible(0). identchannel("test-c"), $TEST_BUTTON

  checkbox bounds(10, 25, 90, 25), channel("bypass"), text("---"), identchannel("bypass-c"), $GREEN_CB
  checkbox bounds(10, 52, 90, 25), channel("mono"), text("---"), identchannel("mono-c"), $RED_CB
  checkbox bounds(105, 52, 90, 25), channel("monoout"), text("---"), identchannel("monoout-c"), $RED_CB

  rslider bounds(208, 25, 50, 50), channel("gain"), range(-90, 30, 0, 2.5, 0.01), text("Gain dB"), identchannel("test2"), $GAIN_KNOB
  rslider bounds(256, 25, 50, 50), channel("drywet"), range(-1, 1, 0, 1, 0.01), text("Dry/Wet"), $DW_KNOB
  rslider bounds(304, 25, 50, 50), channel("balance"), range(-1, 1, 0, 1, 0.01), text("Balance"), $PAN_KNOB
}

groupbox bounds(10, 94, 360, 350), text("Flange"), plant("flange"), identchannel("flange-c"), $PLANT {
  rslider bounds(0, 22, 75, 75), channel("depth"), range(0, 1, .1, .5, 0.0001), text("Depth"), $EFF_KNOB 
  rslider bounds(135, 22, 75, 75), channel("fb"), range(-100, 100, -50, 1, 0.01), text("Feedback %"), $EFF_KNOB 

  rslider bounds(32, 95, 75, 75), channel("freqhz"), range(.01, 5, .1, .5, 0.01), text("LFO Rate"), visible(1), identchannel("rate_h"), $EFF_KNOB 
  rslider bounds(32, 95, 75, 75), channel("freqb"), range(.25, 16, 1, 1, 0.25), text("LFO Rate"), visible(0), identchannel("rate_b"), $EFF_KNOB 
  rslider bounds(32, 95, 75, 75), channel("freqpb"), range(.25, 16, .25, 1, 0.25), text("LFO Rate"), visible(0), identchannel("rate_pb"), $EFF_KNOB 
  rslider bounds(32, 95, 75, 75), channel("freqpm"), range(.25, 16, .25, 1, 0.25), text("LFO Rate"), visible(0), identchannel("rate_pm"), $EFF_KNOB 
  rslider bounds(32, 95, 75, 75), channel("freqm"), range(.25, 16, 4, 1, 0.25), text("LFO Rate"), visible(0), identchannel("rate_m"), $EFF_KNOB 

  rslider bounds(100, 95, 75, 75), channel("phase"), range(0, 360, 0, 1, 0.01), text("Phase"), $EFF_KNOB 
  rslider bounds(65, 22, 75, 75), channel("offset"), range(0, 1, 0, .5, 0.0001), text("Offset"), $EFF_KNOB 
  
  label bounds(260, 30, 90, 15), text("LFO Mode:"), align("centre"), $TEXT
  combobox bounds(255, 50, 100, 30), channel("mode"), items("Hz", "Per Beat", "Beats", "Per Measure", "Measures"), value(1), $COMBO
  combobox bounds(255, 82, 100, 30), channel("tempomode"), items("Host DAW", "Internal"), identchannel("tempotest"), value(1), visible(0) $COMBO
  label bounds(200, 124, 90, 15), text("BPM:"), align("right"), identchannel("tempolabel"), visible(0), $TEXT
  label bounds(200, 148, 90, 15), text("METER:"), align("right"), identchannel("meterlabel"), visible(0), $TEXT
  nslider bounds(294, 121, 60, 20), channel("tempo"), range(40, 280, 60), identchannel("tempobox"), visible(0), $NUMBOX
  nslider bounds(294, 145, 60, 20), channel("meter"), range(1, 32, 4, 1, 1), identchannel("meterbox"), visible(0), $NUMBOX
  label bounds(280, 124, 90, 15), text("---"), align("centre"), identchannel("hosttempo"), visible(0), $TEXT
  label bounds(280, 148, 90, 15), text("---"), align("centre"), identchannel("hostmeter"), visible(0), $TEXT
  label bounds(20, 181, 80, 15), text("LFO Shape:"), align("centre"), $TEXT
  combobox bounds(10, 200, 100, 30), channel("shape"), channeltype("number"), $SHAPE_MENU, value(1), $COMBO
  button bounds(10, 235, 106, 30), channel("pop"), text("Customize", "Customize"), latched("0"), value(0), $BUTTON  
  button bounds(10, 280, 106, 30), channel("sync"), text("Resync", "Rysncing"), latched("0"), value(0), $BUTTON
  checkbox bounds(10, 317, 132, 20), channel("synclock"), shape("circle"), text("Sync to Play"), identchannel"syncl-c", $GREEN_CB

  gentable bounds(120, 175, 230, 160), tablenumber(1), amprange(-1, 1, 1), identchannel("graph1"), visible(1), active(0), $GRAPH  
  label bounds(296, 324, 52, 11), text("---"), identchannel("mind-c"), $G_TEXT,
  label bounds(296, 175, 52, 11), text("---"), identchannel("maxd-c"), $G_TEXT,
  checkbox bounds(125, 315, 15, 15), channel("sync"), value(0), identchannel("sync-c"), $CLIP_CB
  checkbox bounds(120, 254, 2, 2), channel("phaseled"), value(1), identchannel("phase-c"), $CLIP_CB
  checkbox bounds(120, 254, 2, 2), channel("scrub"), value(1), identchannel("scrub-c"), $SCRUB_CB
  checkbox bounds(120, 254, 2, 2), channel("scrub2"), value(1), identchannel("scrub2-c"), $SCRUB_CB
}

groupbox bounds(0, 0, 375, 240), text("Flanged Controls"), plant("Custom Controls"), popup(1), identchannel("cc-popup"), $PLANT {
  vslider bounds(10, 25, 40, 185), channel("val1"), range(-1, 1, 1, 1, .01), identchannel("val1-c"), textbox(1), text("---"), trackercolour(0, 255, 0, 255)
  vslider bounds(55, 25, 40, 185), channel("val2"), range(-1, 1, 0, 1, .01), identchannel("val2-c"), textbox(1), text("---"), trackercolour(0, 255, 0, 255)
  vslider bounds(100, 25, 40, 185), channel("val3"), range(-1, 1, 0, 1, .01), identchannel("val3-c"), textbox(1), text("---"), trackercolour(0, 255, 0, 255)
  vslider bounds(145, 25, 40, 185), channel("val4"), range(-1, 1, 0, 1, .01), identchannel("val4-c"), textbox(1), text("---"), trackercolour(0, 255, 0, 255)
  vslider bounds(190, 25, 40, 185), channel("val5"), range(-1, 1, 0, 1, .01), identchannel("val5-c"), textbox(1), text("---"), trackercolour(0, 255, 0, 255)
  vslider bounds(235, 25, 40, 185), channel("val6"), range(-1, 1, 0, 1, .01), identchannel("val6-c"), textbox(1), text("---"), trackercolour(0, 255, 0, 255)
  vslider bounds(280, 25, 40, 185), channel("val7"), range(-1, 1, 0, 1, .01), identchannel("val7-c"), textbox(1), text("---"), trackercolour(0, 255, 0, 255)
  vslider bounds(325, 25, 40, 185), channel("val8"), range(-1, 1, 0, 1, .01), identchannel("val8-c"), textbox(1), text("---"), trackercolour(0, 255, 0, 255)

  ; waiting for new cabbage features
;  checkbox bounds(105, 210, 140, 20), channel("breakpoints"), value(0), identchannel("breakpoints-c"), text("Manual Breakpoints"), $GREEN_CB, active(0)
  button bounds(290, 210, 80, 20), channel("reset"), latched(0), text("Reset"), value(0), $BUTTON
}
  ; label bounds(0, 406, 350, 15), text("---"), align("left"),  colour(155, 0, 0), fontcolour(255, 255, 255, 255), identchannel("debug"), visible(0)

</Cabbage>
<CsoundSynthesizer>
<CsOptions>
-n -d
</CsOptions>
<CsInstruments>
sr = 44100
ksmps = 16
nchnls = 2
0dbfs=1

; #define DEBUG #1#
#ifdef IS_A_PLUGIN
  #ifdef DEBUG
   #undef DEBUG
  #endif
#endif

#define CLIP_LEV_DB #-.25#
#define CLIP_LEV #db($CLIP_LEV_DB)#

#define DRYWET(d'w'dw) #($d*abs(($dw*.5)-.5))+ ( $w*(($dw*.5)+.5))# 
#define BYPASS(sd'sw'bp) #($sd*$bp)+($sw*(1-$bp))#
#define PANL(s'p) #($s*abs(($p-1)*.5 ))#
#define PANR(s'p) #($s*abs(($p+1)*.5))#
#define BALL(sl'sr'b) #$PANL($sl'$b)+($sr*max(0,($b*-.5)))#
#define BALR(sl'sr'b) #$PANR($sr'$b)+($sl*max(0,($b*.5)))#

#define PORT_TIME #.005#
#define UI_TICKS #20#

; Max delay and offset times in ms
#define MAX_DELAY #25#
#define MAX_OFFSET #25#

; Default BPM only used when host provides no BPM, or invalid BPM based on defined min/max
#define DEFAULT_BPM #60#
#define MIN_BPM #40#
#define MAX_BPM #280#
#define DEFAULT_METER #4#
#define MIN_METER #1#
#define MAX_METER #32#

; Do not adjust these definitions unless you change the combobox order
#define TIME #1#
#define PERBEAT #2#
#define BEAT #3#
#define PERMEASURE #4#
#define MEASURE #5#
#define EXT #1#
#define INT #2#

; Shape values, these should match the order of combobox options
#define W_SINE #1#
#define W_LINE #2#
#define W_PYRAMID #3#
#define W_TRIANGLE #4#
#define W_SQUARE #5#
#define W_SAW #6#
#define W_RSAW #7#
; STEP 2: define custom shape numbers here. name it whatever you want, just make sure it matches the elseif in step 3.
;#define W_YOURSHAPE #8#

; Text arrays used for setsliders
#define T_ERR #fillarray("err", "err", "err", "err", "err", "err", "err", "err")#
#define T_SINE #fillarray("Harm1", "Harm2", "Harm3", "Harm4", "Harm5", "Harm6", "Harm7", "Harm8")#
#define T_1SEG #fillarray("--", "--", "--", "Val 1", "Val 2", "--", "--", "--")#
#define T_2SEG #fillarray("--", "--", "Val 1", "Seg 1", "Val 2", "Val 3", "--", "--")#
#define T_3SEG #fillarray("--", "Val 1", "Seg 1", "Val 2", "Seg 2", "Val 3", "Val 4", "--")#

; opcode to clip to a certain level and report back if clipped
opcode quickclip,ak,aj
  asig, icliplev xin

  #ifndef $CLIP_LEV
    #define CLIP_LEV #.99#
  #end
  
  if (icliplev<0) then
    icliplev=$CLIP_LEV
  endif
  
  ; pre limiting here helps catch clipping on extreme amps
  asig limit asig, -1.125*icliplev, icliplev*1.125  
  kclip rms asig
  
  if (kclip>=icliplev) then
    kclip=1
  else
    kclip=0
  endif

  xout asig, kclip
endop

; stereo version of quickclip calls mono version
opcode quickclip,aak,aaj
  asigL, asigR, icliplev xin
  asigL, kclipL quickclip asigL, icliplev
  asigR, kclipR quickclip asigR, icliplev
  kclip = kclipL==1 || kclipR==1 ? 1 : 0
  xout asigL, asigR, kclip
endop

; opcode to set slider text and vals all at once, vals defailts to 0, -99 hides silder
opcode setsliders,0,S[]OOOOOOOO
  Sarray[], iv1, iv2, iv3, iv4, iv5, iv6, iv7, iv8 xin

  chnset sprintfk("text(%s), visible(%d)", Sarray[0], iv1==-99 ? 0 : 1),"val1-c"
  chnset sprintfk("text(%s), visible(%d)", Sarray[1], iv2==-99 ? 0 : 1),"val2-c"
  chnset sprintfk("text(%s), visible(%d)", Sarray[2], iv3==-99 ? 0 : 1),"val3-c"
  chnset sprintfk("text(%s), visible(%d)", Sarray[3], iv4==-99 ? 0 : 1),"val4-c"
  chnset sprintfk("text(%s), visible(%d)", Sarray[4], iv5==-99 ? 0 : 1),"val5-c"
  chnset sprintfk("text(%s), visible(%d)", Sarray[5], iv6==-99 ? 0 : 1),"val6-c"
  chnset sprintfk("text(%s), visible(%d)", Sarray[6], iv7==-99 ? 0 : 1),"val7-c"
  chnset sprintfk("text(%s), visible(%d)", Sarray[7], iv8==-99 ? 0 : 1),"val8-c"
  chnset min(1,max(-1,iv1)), "val1"
  chnset min(1,max(-1,iv2)), "val2"
  chnset min(1,max(-1,iv3)), "val3"
  chnset min(1,max(-1,iv4)), "val4"
  chnset min(1,max(-1,iv5)), "val5"
  chnset min(1,max(-1,iv6)), "val6"
  chnset min(1,max(-1,iv7)), "val7"
  chnset min(1,max(-1,iv8)), "val8"
endop

gilastshape init 0

; initialize widgets to prevent problems
chnset 1, "mode"
chnset 1, "tempomode"
chnset .1, "depth"
chnset -50, "fb"
chnset .1, "freqhz"
chnset .25, "freqpb"
chnset 1, "freqb"
chnset .25, "freqpm"
chnset 4, "freqm"
chnset 1, "shape"
chnset $DEFAULT_BPM, "tempo"
chnset $DEFAULT_METER, "meter"
setsliders $T_SINE, 1

; instr 1 draws the wave shapes, sets sliders, and updates the graph
instr 1
  ishape=p4
  kshape init 0
  kreset=0
  if (ishape<0) then
    ishape=-ishape
    kreset=1
  endif
; testing this to cut more lag?  
if changed(ishape,kreset)==1 then
  if (ishape==$W_SINE) then
  ; custom sinusoid
    ift ftgentmp 1, 0, 1024, 10, p5, p6, p7, p8, p9, p10, p11, p12
  elseif (ishape==$W_LINE) then
  ; 1 segment
    ift ftgentmp 1, 0, 1024, -7, p8, 1024, p9
  elseif (ishape==$W_PYRAMID) then
  ; 2 segments
    ival1 = p7
    iseg1 = (p8*512)+512
    ival2 = p9
    iseg2 = 1025-iseg1
    ival3 = p10
    ift ftgentmp 1, 0, 1024, -7, ival1, iseg1, ival2, iseg2, ival3
  elseif (ishape==$W_TRIANGLE) || (ishape==$W_SQUARE) || (ishape==$W_SAW) || (ishape==$W_RSAW) then
  ; 3 segments
    ival1=p6
    iseg1=(p7*256)+256
    ival2=p8
    ival3=p10
    iseg3=(-p9*256)+256
    ival4=p11

    iseg2=1025-(iseg1+iseg3)
    ift ftgentmp 1, 0, 1024, -7, ival1, iseg1, ival2, iseg2, ival3, iseg3, ival4
; STEP 3: make sure elseif matches defined name set in step 2.
; STEP 3: add custom ftgentmp statement here loading over table 1. table length must be 1024 or things may break
; STEP 3: table should have min/max values of -1 and 1, values exceeding will be limited
;  elseif (ishape==$W_YOURSHAPE) then
;    ift ftgentmp 1, 0, 1024, 10, -1
  endif

  if (ishape!=gilastshape) || (kreset==1) then
    chnset sprintfk("visible(%d)", ishape==$W_SINE ? 0 : 1), "breakpoints-c"
    chnset k(1), "distgain"
    if (ishape==$W_SINE) then
      setsliders $T_SINE, 1
    elseif (ishape==$W_TRIANGLE) then
      setsliders $T_3SEG, -99, 0, 0, 1, 0, -1, 0, -99
    elseif (ishape==$W_SQUARE) then
      setsliders $T_3SEG, -99, 1, 1, 1, -1, -1, -1, -99
    elseif (ishape==$W_SAW) then
      setsliders $T_3SEG, -99, 0, 1, 1, -1, -1, 0, -99
    elseif (ishape==$W_RSAW) then
      setsliders $T_3SEG, -99, 0, 1, -1, -1 ,1, 0, -99
    elseif (ishape==$W_LINE) then
      setsliders $T_1SEG, -99, -99, -99, -1, 1, -99, -99, -99
    elseif (ishape==$W_PYRAMID) then
      setsliders $T_2SEG, -99, -99, -1, 0, 1, -1, -99, -99
    else
      setsliders $T_ERR, -99, -99, -99, -99, -99, -99, -99, -99
    endif
  gilastshape=ishape
  endif

endif
chnset "tablenumber(1)", "graph1"

endin

  
; instr 2 listens for gui changes and processes audio
instr 2
ktest chnget "test"
kbypass chnget "bypass"
kmono chnget "mono"
kmonoout chnget "monoout"
kgain = ampdb(chnget:k("gain"))
kdrywet chnget "drywet"
kbalance chnget "balance"

kdepth chnget "depth"
koffset = chnget:k("offset")*$MAX_OFFSET
kfreq chnget "freqhz"
kfb = chnget:k("fb")*.01
kshape chnget "shape"
ksync chnget "sync"
kpop chnget "pop"

; read Customize widgets
kh1 chnget "val1"
kh2 chnget "val2"
kh3 chnget "val3"
kh4 chnget "val4"
kh5 chnget "val5"
kh6 chnget "val6"
kh7 chnget "val7"
kh8 chnget "val8"
kreset chnget "reset"
kbreak chnget "breakpoints"

kmode chnget "mode"
ktempomode chnget "tempomode"

ksynclock chnget "synclock"

khostplay chnget "IS_PLAYING"

; Determine beat tempo based on tempomode
if (ktempomode==1) then
  kBPM chnget "HOST_BPM"
  kmeter chnget "TIME_SIG_NUM"
else
  kBPM chnget "tempo"
  kmeter chnget "meter"
endif


; Adjust for Min/Max
if (kBPM<$MIN_BPM) || (kBPM>$MAX_BPM) then
  kBPM=$DEFAULT_BPM
endif
if (kmeter<$MIN_METER) || (kmeter>$MAX_METER) then
  kmeter=$DEFAULT_METER
endif

; Beat time in seconds
kBtime=60/kBPM


if (kmode==$TIME) then
  krate chnget "freqhz"
elseif (kmode==$PERBEAT) then
  krate chnget "freqpb"
  krate = krate/kBtime
elseif (kmode==$BEAT) then
  krate chnget "freqb"
  krate = 1/(krate*kBtime)
elseif (kmode==$PERMEASURE) then
  krate chnget "freqpm"
  krate = krate/(kBtime*kmeter)
else ; $MEASURE
  krate chnget "freqm"
  krate = 1/(krate*kBtime*kmeter)
endif

if changed(kfb)==1 then
  chnset sprintfk("text(%4.2f)",krate),"debug"
endif

; show custom popup is shape changes or button is pushed
if changed(kshape, kpop)==1 then
        chnset sprintfk("show(%d)",kpop), "cc-popup"
endif

; negative shape indicates reset
kshape = kreset==0 ? kshape : -1*kshape
if changed(kshape, kh1, kh2, kh3, kh4, kh5, kh6, kh7, kh8, kreset)==1 then
        event "i", 1, 0, .001, kshape, kh1, kh2, kh3, kh4, kh5, kh6, kh7, kh8
endif

; change bypass text
if changed(kbypass)==1 then
  if (kbypass==1) then
    Sbuf strcpyk "text(\"Bypassed\")"
    Sbuf2 strcpyk "visible(0)"
  else
    Sbuf strcpyk "text(\"Bypass\")"
    Sbuf2 strcpyk "visible(1)"
  endif
  chnset Sbuf, "bypass-c"
  chnset Sbuf2, "flange-c"
endif

; change mono/stereo text
if changed(kmono)==1 then
  if (kmono==1) then
    Sbuf strcpyk "text(\"Mono L+R\")"
  else
    Sbuf strcpyk "text(\"Stereo In\")"
  endif
  chnset Sbuf, "mono-c"
endif

; change mono/stereo out text
if changed(kmonoout)==1 then
  if (kmonoout==1) then
    Sbuf strcpyk "text(\"Mono Del\")"
  else
    Sbuf strcpyk "text(\"Stereo Del\")"
  endif
  chnset Sbuf, "monoout-c"
endif

; Change visible time controls based on mode and tempomode
if changed(kmode, ktempomode)==1 then
    chnset sprintfk("visible(%d)", kmode==$TIME ? 1 : 0), "rate_h"
    chnset sprintfk("visible(%d)", kmode==$TIME ? 1 : 0), "rate_h"
    chnset sprintfk("visible(%d)", kmode==$TIME ? 0 : 1), "tempotest"
    chnset sprintfk("visible(%d)", kmode==$TIME ? 0 : 1), "tempolabel"
    chnset sprintfk("visible(%d)", kmode==$MEASURE || kmode==$PERMEASURE ? 1 : 0), "meterlabel"

    chnset sprintfk("visible(%d)", kmode==$BEAT ? 1 : 0), "rate_b"
    chnset sprintfk("visible(%d)", kmode==$BEAT ? 1 : 0), "rate_b"

    chnset sprintfk("visible(%d)", kmode==$PERBEAT ? 1 : 0), "rate_pb"
    chnset sprintfk("visible(%d)", kmode==$PERBEAT ? 1 : 0), "rate_pb"

    chnset sprintfk("visible(%d)", kmode==$PERMEASURE ? 1 : 0), "rate_pm"
    chnset sprintfk("visible(%d)", kmode==$PERMEASURE ? 1 : 0), "rate_pm"

    chnset sprintfk("visible(%d)", kmode==$MEASURE ? 1 : 0), "rate_m"
    chnset sprintfk("visible(%d)", kmode==$MEASURE ? 1 : 0), "rate_m"

    chnset sprintfk("visible(%d)", kmode!=$TIME && ktempomode==$INT ? 1 : 0), "tempobox"
    chnset sprintfk("visible(%d)", (kmode==$MEASURE || kmode==$PERMEASURE) && ktempomode==$INT ? 1 : 0), "meterbox"
endif

; update host info when bpm or meter changes too
if changed(kmode, ktempomode, kBPM, kmeter)==1 then
    chnset sprintfk("visible(%d) text(%5.2f)", kmode!=$TIME && ktempomode==$EXT ? 1 : 0, kBPM), "hosttempo"
    chnset sprintfk("visible(%d) text(%d)", (kmode==$MEASURE || kmode==$PERMEASURE) && ktempomode==$EXT ? 1 : 0, kmeter), "hostmeter"
endif

; initialize feedback
afbL init 0
afbR init 0

; read inputs
ain1 inch 1
ain2 inch 2

#ifdef DEBUG
  if ktest==1 then
    ain1 oscil .75, 440
    ; ain1	diskin "fox.wav", 1, 0, 1
    ain2	= ain1
;    ain1, ain2 diskin "stereotest.wav", 1, 0, 1
  endif
  kinit init 0
  if (kinit<=50) then
    Sbuf strcpyk "visible(1)"
    chnset Sbuf, "test-c"
    chnset Sbuf, "debug"
    kinit = kinit+1
  endif
#endif

; mono collapse
if kmono==0 then
  asrcL   =       ain1
  asrcR   =       ain2
else
  asrcL   =       (ain1+ain2)*.5
  asrcR   =       asrcL
endif

; check for and display input clipping
asrcL, asrcR, kclip quickclip asrcL, asrcR
if changed(kclip)==1 then
  chnset sprintfk("value(%d)", kclip==1 ? 1 : 0), "in-clip-c"
endif

; resync when host plays
if changed(khostplay)==1 then
  ksync = ksynclock==1 && khostplay==1 ? 1 : ksync
endif

; reinit oscil if ksync==1
if changed(ksync)==1 then
  if(ksync==1) then
    reinit myreinit
  endif
endif

myreinit:
iphase = chnget("phase")/360
kphase = chnget:k("phase")/360

kdepth = kdepth*$MAX_DELAY*.5

; kosc is main lfo
kosc oscil 1, krate, 1, iphase
; kpnt is a time pointer for the UI
kpnt oscil 1, krate, 2, iphase
; limit for safety
kosc limit kosc, -1, 1

; update scrub and phase markers
if metro($UI_TICKS)==1 then
  ; adjust x/y vals for scrub marker
  kx = 119+(kpnt*230)
  ky = 254-(kosc*79)
  chnset sprintfk("bounds(%d,%d,2,2)",kx,ky),"scrub-c"
  chnset sprintfk("bounds(119,%d,2,2)",ky),"scrub2-c"
  if changed(kphase,kshape,kh1,kh2,kh3,kh4,kh5,kh6,kh7,kh8,kreset)==1 then
    kx table kphase, 2, 1
    ky table kphase, 1, 1
    kx = 119+(kx*230)
    ky = 254-(ky*79)
    chnset sprintfk("bounds(%d,%d,2,2)",kx,ky),"phase-c"
  endif
endif

kosc = kosc * kdepth
; I didn't like how this sounded, but turn it on if you want it
;kosc port kosc, $PORT_TIME
aosc interp kosc

adelL = aosc+kdepth+koffset
adelR = kmonoout==1 ? adelL : (-1*aosc)+kdepth+koffset

kmaxd = max(.0001,(kdepth+kdepth+koffset))
kmind = max(.0001,(-1*kdepth)+kdepth+koffset)

if changed(kmaxd,kmind)==1 then
  chnset sprintfk("text(%4.2fms)",kmaxd),"maxd-c"
  chnset sprintfk("text(%4.2fms)",kmind),"mind-c"
endif

asigL vdelay asrcL+(afbL*kfb), adelL, $MAX_DELAY+$MAX_OFFSET
asigR vdelay asrcR+(afbR*kfb), adelR, $MAX_DELAY+$MAX_OFFSET

; add in dry signal, but only half when panned
; not sure why i had added this? removed for now...
;asigL = (asigL+(asrcL*abs(kbalance*.5)))
;asigR = (asigR+(asrcR*abs(kbalance*.5)))

; copy to feedback buffer
afbL = asigL
afbR = asigR

; dry/wet balance snippet
asigL = $DRYWET(asrcL'asigL'kdrywet)
asigR = $DRYWET(asrcR'asigR'kdrywet)

; stereo balanced output snippet
aout1 = $BALL(asigL'asigR'kbalance)
aout2 = $BALR(asigL'asigR'kbalance)

; check for and display output clipping
aout1, aout2, kclip quickclip aout1*kgain, aout2*kgain
if changed(kclip)==1 then
  chnset sprintfk("value(%d)", kclip==1 ? 1 : 0), "clip-c"
endif

; smooth bypass swap to avoid clicks
kbypass port kbypass, $PORT_TIME
abypass interp kbypass
aout1 = $BYPASS(asrcL'aout1'abypass)
aout2 = $BYPASS(asrcR'aout2'abypass)

outs aout1, aout2

endin

</CsInstruments>  
<CsScore>
; default sine table to start
f1 0 1024 10 1
; line table for graphing scrub location
f2 0 1024 7 0 1024 1
i2 0 z
</CsScore>
</CsoundSynthesizer>