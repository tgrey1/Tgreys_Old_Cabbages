<Cabbage>
;
; ShapedUp.csd by Kevin Welsh (tgrey)
; version 1.2 - May.31 2020 (maintenance release)
;
; !!!PLEASE NOTE!!!  This is an outdated instrument minimally updated to run in cabbage2.
; If you are using cabbage1, use the older version 1.0!  Functionally they are identical.
; A newer better version of this is in the works!
;
;  This is a flexible waveshaping distortion with 3 gain stages, and extensive pre and post filtering.
;  It is capable of mangling a sound well past the bounds of recognizability.
;
;  Distortion wave shape is selectable between some premade shapes, which are tweakable in real
;  time via popup sliders (customize button).  Complete breakpoint editing will hopefully arrive
;  in a future version after new additions to cabbage.
;
;  Custom wave shapes can be added in three steps, documentation is included inline.  Search
;  for "STEP 1", "STEP 2", and "STEP 3".  Tables are generated using ftgentmp and should be
;  size 1024.
;
;  Filtering has four points, with two each pre and post distortion, with selectable filter modes. 
;  More modes may be added in future versions.  Depth controls recursive passes through the same
;  filter, with 0 disabling the filter.  Changing depth causes a reinit, so it may cause clicks.  Be
;  careful with resonant filters and recursive depth, signals can get loud quickly.
;
;  IMPORTANT NOTE!  LPF mode on Rezzy is very unstable.  It will give a popup warning when
;  activated.  Please use it cautiously, both due to potential sonic explosions, or potential
;  crashing and lost data.
;
;  3 gain stages allow for -90 to +90db compensate for possibly steep filters and distortion.  Gain
;  does not affect dry signal or bypassed signal.  Pregain is applied before pre-filtering for input
;  level adjustment.  Gain is applied after filtering to compensating for the filters.  Postgain is
;  applied after post filters, to adjust the final output level.
;
;  Dry/Wet ranges from -1 to 1, with -1 being all dry, 0 being a 50:50 mix, and 1 being all wet.
;
;  Stereo balance is a non-destructive panning, meaning panning full left will move the right
;  channel to the left preserving all data.
;
#define GREEN_CB colour:0(0, 25, 0, 255), colour:1(0,255,0,255), fontcolour(160, 160, 160, 255), shape("circle"),
#define RED_CB colour:0(25, 0, 0, 255), colour:1(255,0,0,255), fontcolour(160, 160, 160, 255), shape("circle"),
#define CLIP_CB colour:0(25, 0, 0, 255), colour:1(255,0,0,255), fontcolour(160, 160, 160, 255), active(0), shape("square"),
#define GAIN_KNOB colour(255, 0, 0, 160), trackercolour(0, 255, 0, 255), fontcolour(160, 160, 160, 255),
#define DW_KNOB colour(0, 95, 255, 255), trackercolour(0, 255, 0, 255), fontcolour(160, 160, 160, 255),
#define PAN_KNOB colour(125, 125, 125, 255), trackercolour(0, 255, 0, 255), fontcolour(160, 160, 160, 255),
#define EFF_KNOB colour(0,255,0,160), trackercolour(0, 255, 0, 255), fontcolour(160, 160, 160, 255),
#define FILT_KNOB colour(255, 255, 0, 160), trackercolour(0, 255, 0, 255), fontcolour(160, 160, 160, 255),
#define TEXT colour(0,0,0,0), fontcolour(160, 160, 160, 255),
#define BUTTON fontcolour:1(255, 255, 255, 255), fontcolour:0(160, 160, 160, 255), colour:0(30, 30, 30, 255), colour:1(60,60,60,255),
#define TEST_BUTTON colour:0(30, 30, 30, 255), colour:1(60,60,60,255), fontcolour:0(160, 160, 160, 255), fontcolour:1(0,255,0,255),
#define COMBO colour(30,30,30,255), fontcolour(160, 160, 160, 255),
#define NUMBOX colour(30,30,30,255)
#define WARN_HEAD fontcolour(155, 0, 0), colour(60,60, 60, 255)
#define WARN_TEXT fontcolour(155, 155, 155), colour(60,60, 60, 255)
#define DIS_PLANT colour(55,55,55,55), fontcolour(50, 50, 50, 255), line(1), text("Disabled")
#define PLANT colour(40,40,40,255), line(1)
#define ROOT colour(20,20,20,255)
;#define GRAPH tablecolour(green)
#define GRAPH tablecolour(0,255,0,60)

; STEP 1: add shape name at the **end** of SHAPE_MENU.  The order here must also match the order set in step 2.
#define SHAPE_MENU items("Sine [8 partials]", "Line [1 seg]", "Pyramid [2 seg]", "Triangle [3 seg]", "Square [3 Seg]", "Saw [3 Seg]", "Reverse Saw [3 Seg]")

#define HPF_MENU text("Bypass", "Low Shelf", "ButterHP", "Atone",  "Peak", "ButterBP", "ButterBR", "Moog", "Reson", "Resonr", "Resonz", "Rezzy")
#define LPF_MENU  text("Bypass", "High Shelf", "ButterLP", "Tone", "Peak", "ButterBP", "ButterBR", "LPF18", "Moog", "Reson", "Resonr", "Resonz", "Rezzy[!]")

form size(380, 542), caption("ShapedUp"), pluginID("tshp"), $ROOT

groupbox bounds(10, 218, 360, 190), $DIS_PLANT
groupbox bounds(10, 94, 178, 120), $DIS_PLANT
groupbox bounds(193, 94, 178, 120), $DIS_PLANT
groupbox bounds(10, 412, 178, 120), $DIS_PLANT
groupbox bounds(193, 412, 178, 120), $DIS_PLANT

groupbox bounds(10, 10, 360, 80), text("In / Out"), plant("io"), $PLANT {
  button bounds(80, 2, 60, 15), channel("test"), text("Test", "Testing..."), latched(1), value(0), visible(0), identchannel("test-c"), $TEST_BUTTON

  label bounds(10, 5, 30, 10), text("OL"), align("left"), $TEXT
  checkbox bounds(25, 5, 10, 10), channel("in-clip"), value(0), identchannel("in-clip-c"), $CLIP_CB
  label bounds(325, 5, 30, 10), text("OL"), align("left"), $TEXT
  checkbox bounds(340, 5, 10, 10), channel("clip"), value(0), identchannel("clip-c"), $CLIP_CB

  checkbox bounds(10, 25, 90, 25), channel("bypass"), shape("circle"), text("---"), identchannel("bypass-c"), $GREEN_CB
  checkbox bounds(10, 52, 90, 25), channel("mono"), shape("circle"), text("---"), identchannel("mono-c"), $RED_CB

  rslider bounds(104, 25, 50, 50), channel("pregain"), range(-90, 90, 0, 1, 0.01), text("PreGain"), $GAIN_KNOB
  rslider bounds(147, 25, 50, 50), channel("gain"), range(-90, 90, 0, 1, 0.01), text("Gain"), $GAIN_KNOB
  rslider bounds(190, 25, 50, 50), channel("postgain"), range(-90, 90, 0, 1, 0.01), text("PostGain"), $GAIN_KNOB

  rslider bounds(246, 25, 50, 50), channel("drywet"), range(-1, 1, 1, 1, 0.01), text("Dry/Wet"), $DW_KNOB
  rslider bounds(304, 25, 50, 50), channel("balance"), range(-1, 1, 0, 1, 0.01), text("Balance"),  $PAN_KNOB
}

groupbox bounds(10, 218, 360, 190), text("Distort"), plant("distort"),  identchannel("distort-c"), $PLANT {
  rslider bounds(10, 25, 100, 100), channel("dist"), range(0, 1, .5, 1, 0.01), text("Distortion"), identchannel("dist-c"), $EFF_KNOB
  combobox bounds(10, 130, 100, 25), channel("shape"), $SHAPE_MENU, value(1), $COMBO
  gentable bounds(120, 25, 230, 160), tablenumber(1), amprange(-1, 1, 1), identchannel("graph1"), zoom(-1), visible(1), active(0), $GRAPH
  button bounds(10, 160, 107, 25), channel("pop-button"), latched(0), text("Customize"), value(0), $BUTTON
}

groupbox bounds(10, 94, 178, 120), text("Pre-HPF"), plant("pre-hpf"), identchannel("pre-hpf-c"), $PLANT {
  rslider bounds(10, 22, 50, 50), channel("prehpffreq"), range(10, 15000, 10, .5, 0.01), text("Freq"), identchannel("prehpff_c"), visible(0), $FILT_KNOB
  rslider bounds(110, 22, 50, 50), channel("prehpfg"), range(-10, 10, 0, 1, 0.01), text("Gain"), identchannel("prehpfg_c"), visible(0), $FILT_KNOB
  rslider bounds(60, 22, 50, 50), channel("prehpfq"), range(0.0, 1, 0.5, 1, 0.01), text("Q/Res"), identchannel("prehpfq_c"), visible(0), $FILT_KNOB
  combobox bounds(5, 80, 100, 30), channel("prehpfmode"), channeltype("number"), value(1), $HPF_MENU, $COMBO, identchannel("mytest")
  rslider bounds(110, 70, 50, 50), channel("prehpfdepth"), range(0, 8, 1, 1, 1), text("Depth"), identchannel("prehpfdepth_c"), visible(0), $FILT_KNOB
}

groupbox bounds(193, 94, 178, 120), text("Pre-LPF"), plant("pre-lpf"), identchannel("pre-lpf-c"), $PLANT {
  rslider bounds(10, 22, 50, 50), channel("prelpffreq"), range(10, 15000, 15000, .5, 0.01), text("Freq"), identchannel("prelpff_c"), visible(0), $FILT_KNOB
  rslider bounds(110, 22, 50, 50), channel("prelpfg"), range(-10, 10, 0, 1, 0.01), text("Gain"), identchannel("prelpfg_c"), visible(0), $FILT_KNOB
  rslider bounds(110, 22, 50, 50), channel("prelpfd"), range(0, 1, 0, 1, 0.01), text("Distort"), identchannel("prelpfd_c"), visible(0), $FILT_KNOB
  rslider bounds(60, 22, 50, 50), channel("prelpfq"), range(0.0, 1, 0.5, 1, 0.01), text("Q/Res"), identchannel("prelpfq_c"), visible(0), $FILT_KNOB
  combobox bounds(5, 80, 100, 30), channel("prelpfmode"), channeltype("number"), value(1), $LPF_MENU, $COMBO
  rslider bounds(110, 70, 50, 50), channel("prelpfdepth"), range(0, 8, 1, 1, 1), text("Depth"), identchannel("prelpfdepth_c"), visible(0), $FILT_KNOB
}

groupbox bounds(10, 412, 178, 120), text("Post-HPF"), plant("post-hpf"), identchannel("post-hpf-c"), $PLANT {
  rslider bounds(10, 22, 50, 50), channel("posthpffreq"), range(10, 15000, 10, .5, 0.01), text("Freq"), identchannel("posthpff_c"), visible(0), $FILT_KNOB
  rslider bounds(110, 22, 50, 50), channel("posthpfg"), range(-10, 10, 0, 1, 0.01), text("Gain"), identchannel("posthpfg_c"), visible(0), $FILT_KNOB
  rslider bounds(60, 22, 50, 50), channel("posthpfq"), range(0.0, 1, 0.5, 1, 0.01), text("Q/Res"), identchannel("posthpfq_c"), visible(0), $FILT_KNOB
  combobox bounds(5, 80, 100, 30), channel("posthpfmode"), channeltype("number"), value(1), $HPF_MENU, $COMBO
  rslider bounds(110, 70, 50, 50), channel("posthpfdepth"), range(0, 8, 1, 1, 1), text("Depth"), identchannel("posthpfdepth_c"), visible(0), $FILT_KNOB
}

groupbox bounds(193, 412, 178, 120), text("Post-LPF"), plant("post-lpf"), identchannel("post-lpf-c"), $PLANT {
  rslider bounds(10, 22, 50, 50), channel("postlpffreq"), range(10, 15000, 15000, .5, 0.01), text("Freq"), identchannel("postlpff_c"), visible(0), $FILT_KNOB
  rslider bounds(110, 22, 50, 50), channel("postlpfg"), range(-10, 10, 0, 1, 0.01), text("Gain"), identchannel("postlpfg_c"), visible(0), $FILT_KNOB
  rslider bounds(110, 22, 50, 50), channel("postlpfd"), range(0, 1, 0, 1, 0.01), text("Distort"), identchannel("postlpfd_c"), visible(0), $FILT_KNOB
  rslider bounds(60, 22, 50, 50), channel("postlpfq"), range(0.0, 1, 0.5, 1, 0.01), text("Q/Res"), identchannel("postlpfq_c"), visible(0), $FILT_KNOB
  combobox bounds(5, 80, 100, 30), channel("postlpfmode"), channeltype("number"), value(1), $LPF_MENU, $COMBO
  rslider bounds(110, 70, 50, 50), channel("postlpfdepth"), range(0, 8, 1, 1, 1), text("Depth"), identchannel("postlpfdepth_c"), visible(0), $FILT_KNOB
}

groupbox bounds(0, 0, 375, 290), text("ShapedUp Controls"), plant("Custom Controls"), popup(1), identchannel("cc-popup"), $PLANT {
  vslider bounds(10, 25, 40, 185), channel("val1"), range(-1, 1, 0, 1, .01), identchannel("val1-c"), textbox(1), text("---"), trackercolour(0, 255, 0, 255)
  vslider bounds(55, 25, 40, 185), channel("val2"), range(-1, 1, 0, 1, .01), identchannel("val2-c"), textbox(1), text("---"), trackercolour(0, 255, 0, 255)
  vslider bounds(100, 25, 40, 185), channel("val3"), range(-1, 1, 0, 1, .01), identchannel("val3-c"), textbox(1), text("---"), trackercolour(0, 255, 0, 255)
  vslider bounds(145, 25, 40, 185), channel("val4"), range(-1, 1, 0, 1, .01), identchannel("val4-c"), textbox(1), text("---"), trackercolour(0, 255, 0, 255)
  vslider bounds(190, 25, 40, 185), channel("val5"), range(-1, 1, 0, 1, .01), identchannel("val5-c"), textbox(1), text("---"), trackercolour(0, 255, 0, 255)
  vslider bounds(235, 25, 40, 185), channel("val6"), range(-1, 1, 0, 1, .01), identchannel("val6-c"), textbox(1), text("---"), trackercolour(0, 255, 0, 255)
  vslider bounds(280, 25, 40, 185), channel("val7"), range(-1, 1, 0, 1, .01), identchannel("val7-c"), textbox(1), text("---"), trackercolour(0, 255, 0, 255)
  vslider bounds(325, 25, 40, 185), channel("val8"), range(-1, 1, 0, 1, .01), identchannel("val8-c"), textbox(1), text("---"), trackercolour(0, 255, 0, 255)

  checkbox bounds(10, 215, 85, 20), channel("normalize"), value(1), text("Normalize"), identchannel("normalize-c"), $GREEN_CB
  rslider bounds(-5, 235, 50, 50), channel("prescale"), range(1, 10, 1, 1, .01), identchannel("scale-c"), text("Scale"), $EFF_KNOB
  rslider bounds(45, 235, 50, 50), channel("min"), range(-1, 1, -1, 1, .01), text("Min"), $EFF_KNOB
  rslider bounds(95, 235, 50, 50), channel("max"), range(-1, 1, 1, 1, .01), text("Max"), $EFF_KNOB
  rslider bounds(145, 235, 50, 50), channel("postscale"), range(1, 10, 1, 1, .01), text("Scale"), $EFF_KNOB

  ; waiting for new cabbage features
  ; checkbox bounds(105, 160, 140, 20), channel("breakpoints"), value(0), identchannel("breakpoints-c"), text("Manual Breakpoints"), $GREEN_CB, active(0)
  button bounds(290, 220, 80, 20), channel("reset"), latched(0), text("Reset"), value(0), $BUTTON
}

; renamed this warning identchannel name so it can't popup anymore
groupbox bounds(0, 0, 350, 110), plant("Warning"), popup(1), identchannel("rezzy-popup-dis"), show(0), $PLANT {
  label bounds(0, 20, 350, 90), text(""), align("centre"),  fontcolour(155, 0, 0), colour(60,60, 60, 255)
  label bounds(0, 20, 350, 30), text("Warning!"), align("centre"),  fontcolour(155, 0, 0), colour(60,60, 60, 255)
  label bounds(0, 50, 350, 20), text("Rezzy in LPF mode is *VERY*"), align("centre"),  fontcolour(155, 155, 155), colour(60,60, 60, 255)
  label bounds(0, 70, 350, 20), text("unstable.  Be careful."), align("centre"),  fontcolour(155, 155, 155), colour(60,60, 60, 255)
}

  ; label bounds(0, 412, 220, 15), text("---"), align("left"),  colour(155, 0, 0), fontcolour(255, 255, 255, 255), identchannel("debug"), visible(0)

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

#define PORT_TIME #.01#

#define DRYWET(d'w'dw) #($d*min((-1*$dw)+1,1))+($w*min(($dw+1),1))#
#define PANL(s'p) #($s*abs(($p-1)*.5 ))#
#define PANR(s'p) #($s*abs(($p+1)*.5))#
#define BALL(sl'sr'b) #$PANL($sl'$b)+($sr*max(0,($b*-.5)))#
#define BALR(sl'sr'b) #$PANR($sr'$b)+($sl*max(0,($b*.5)))#
#define BYPASS(sd'sw'bp) #($sd*$bp)+($sw*(1-$bp))#

; These are modes for multifilt UDO
#define F_BYPASS #0#
#define F_LSHELF #1#
#define F_HSHELF #2#
#define F_PEAK #3#
#define F_BUTTHP #4#
#define F_BUTTLP #5#
#define F_BUTTBP #6#
#define F_BUTTBR #7#
#define F_TONE #8#
#define F_ATONE #9#
#define F_MOOG #10#
#define F_REZZYHP #11#
#define F_REZZYLP #12#
#define F_LPF18 #13#
#define F_RESON #14#
#define F_RESONR #15#
#define F_RESONZ #16#

; these are used to convert combobox values to multifilt values
; they should match the order of HPF_MENU and LPF_MENU, remember 0 isn't used!
gihpfval[] fillarray $F_BYPASS, $F_BYPASS, $F_LSHELF, $F_BUTTHP, $F_ATONE, $F_PEAK, $F_BUTTBP, $F_BUTTBR, $F_MOOG, $F_RESON, $F_RESONR, $F_RESONZ, $F_REZZYHP
gilpfval[] fillarray $F_BYPASS, $F_BYPASS, $F_HSHELF, $F_BUTTLP, $F_TONE, $F_PEAK, $F_BUTTBP, $F_BUTTBR, $F_LPF18, $F_MOOG, $F_RESON, $F_RESONR, $F_RESONZ, $F_REZZYLP

; Shape values, these should match the order of combobox options
#define W_SINE #1#
#define W_LINE #2#
#define W_PYRAMID #3#
#define W_TRIANGLE #4#
#define W_SQUARE #5#
#define W_SAW #6#
#define W_RSAW #7#
; STEP 2: define custom shape numbers here. name it whatever you want, just make sure it matches the elseif in step 3.
; #define W_YOURSHAPE #8#

; Text arrays used for setsliders
#define T_ERR #fillarray("err", "err", "err", "err", "err", "err", "err", "err")#
#define T_SINE #fillarray("Harm1", "Harm2", "Harm3", "Harm4", "Harm5", "Harm6", "Harm7", "Harm8")#
#define T_1SEG #fillarray("--", "--", "--", "Val 1", "Val 2", "--", "--", "--")#
#define T_2SEG #fillarray("--", "--", "Val 1", "Seg 1", "Val 2", "Val 3", "--", "--")#
#define T_3SEG #fillarray("--", "Val 1", "Seg 1", "Val 2", "Seg 2", "Val 3", "Val 4", "--")#


gilastshape init 0

; opcode to clip to a certain level and report back if clipped
opcode quickclip,ak,aj
  asig, icliplev xin
  kclip rms asig

  #ifndef $CLIP_LEV
    #define CLIP_LEV #.99#
  #end

  if (icliplev<0) then
    icliplev=$CLIP_LEV
  endif

  if (kclip>=icliplev) then
    kclip=1
  else
    kclip=0
  endif

  asig limit asig, -1*icliplev, icliplev
  
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

; flexible recursive filter
opcode multifilt,aa,aakkkkp
  asigL, asigR, kmode, kfreq, kq, kgain, iloops xin

  if (iloops==0) then
    goto filt_skip
  endif
  
  if (kmode==$F_BUTTHP) then
    asigL butterhp asigL, kfreq
    asigR butterhp asigR, kfreq
  elseif (kmode==$F_BUTTLP) then
    asigL butterlp asigL, kfreq
    asigR butterlp asigR, kfreq
  elseif (kmode==$F_BUTTBP) then
    asigL butterbp asigL, kfreq, abs(kq-1)*(kfreq/2)
    asigR butterbp asigR, kfreq, abs(kq-1)*(kfreq/2)
  elseif (kmode==$F_BUTTBR) then
    asigL butterbr asigL, kfreq, abs(kq-1)*(kfreq/2)
    asigR butterbr asigR, kfreq, abs(kq-1)*(kfreq/2)
  elseif (kmode==$F_LSHELF) then
    asigL pareq asigL, kfreq, kgain, max(kq,.01), 1
    asigR pareq asigR, kfreq, kgain, max(kq,.01), 1
  elseif (kmode==$F_HSHELF) then
    asigL pareq asigL, kfreq, kgain, max(kq,.01), 2
    asigR pareq asigR, kfreq, kgain, max(kq,.01), 2
  elseif (kmode==$F_PEAK) then
    asigL pareq asigL, kfreq, kgain, max(kq,.01), 0
    asigR pareq asigR, kfreq, kgain, max(kq,.01), 0
  elseif (kmode==$F_REZZYHP) then
    asigL rezzy asigL, kfreq, (kq*99)+1, 1
    asigR rezzy asigR, kfreq, (kq*99)+1, 1
  elseif (kmode==$F_REZZYLP) then
    asigL rezzy asigL, kfreq, (kq*99)+1, 0
    asigR rezzy asigR, kfreq, (kq*99)+1, 0
  elseif (kmode==$F_MOOG) then
    asigL moogladder asigL, kfreq, kq
    asigR moogladder asigR, kfreq, kq
  elseif (kmode==$F_ATONE) then
    asigL atone asigL, kfreq
    asigR atone asigR, kfreq
  elseif (kmode==$F_TONE) then
    asigL tone asigL, kfreq
    asigR tone asigR, kfreq
  elseif (kmode==$F_LPF18) then
    asigL lpf18 asigL, kfreq, kq, kgain
    asigR lpf18 asigR, kfreq, kq, kgain
  elseif (kmode==$F_RESON) then
    asigL reson asigL, kfreq, abs(kq-1)*(kfreq/2), 1
    asigR reson asigR, kfreq, abs(kq-1)*(kfreq/2), 1
  elseif (kmode==$F_RESONR) then
    asigL resonr asigL, kfreq, abs(kq-1)*(kfreq/2), 1
    asigR resonr asigR, kfreq, abs(kq-1)*(kfreq/2), 1
  elseif (kmode==$F_RESONZ) then
    asigL resonz asigL, kfreq, abs(kq-1)*(kfreq/2), 1
    asigR resonz asigR, kfreq, abs(kq-1)*(kfreq/2), 1
  endif
    
  if (iloops<=1) then
    kgoto filt_skip
  else
    asigL, asigR multifilt asigL, asigR, kmode, kfreq, kq, kgain, iloops-1
  endif
  filt_skip:
  xout asigL, asigR
endop

; sets controls for filters
opcode multifiltvis,0,kS
  kmode, Sprefix xin
  
  if changed(kmode)==1 then
    ; show freq
    Sbuf sprintfk "visible(%d)", kmode==$F_BYPASS ? 0 : 1
    chnset Sbuf, sprintfk("%sf_c",Sprefix)
    chnset Sbuf, sprintfk("%sdepth_c",Sprefix)
    ; show q/res
    Sbuf sprintfk "visible(%d)", kmode==$F_LSHELF || kmode==$F_HSHELF || kmode==$F_PEAK || kmode==$F_BUTTBP || kmode==$F_BUTTBR || kmode==$F_REZZYLP || kmode==$F_REZZYHP || kmode==$F_MOOG || kmode==$F_LPF18 || kmode==$F_RESON || kmode==$F_RESONR || kmode==$F_RESONZ ? 1 : 0
    chnset Sbuf, sprintfk("%sq_c",Sprefix)
    ; show gain
    Sbuf sprintfk "visible(%d)", kmode==$F_LSHELF || kmode==$F_HSHELF || kmode==$F_PEAK ? 1 : 0
    chnset Sbuf, sprintfk("%sg_c",Sprefix)
    ; show distortion
    Sbuf sprintfk "visible(%d)", kmode==$F_LPF18 ? 1 : 0
    chnset Sbuf, sprintfk("%sd_c",Sprefix)
    chnset sprintfk("show(%d), pos(1, 1)", kmode==$F_REZZYLP ? 1 : 0), "rezzy-popup"
  endif
endop

; opcode to limit min and max of a table, and rescale it afterwards
opcode tablelimit,0,iiii
  ift, imin, imax, iscale xin
  ilen ftlen ift
  iidx init 0
  loop_start:
    ival table iidx, ift, 0
    ival limit ival, imin, imax
    ival limit ival*iscale, -1, 1
    tableiw ival, iidx, ift
  loop_lt iidx, 1, ilen, loop_start
endop

; initialize non-0 variables in case widgets don't reload properly
chnset 1, "drywet"
chnset .5, "dist"
chnset 1, "shape"
chnset 1, "val1"
chnset 1, "prescale"
chnset 1, "postscale"
chnset -1, "min"
chnset 1, "max"
chnset 1, "normalize"

; initialize Pre filter widgets
chnset 10, "prehpffreq"
chnset .5, "prehpfq"
chnset 1, "prehpfdepth"
chnset 15000, "prelpffreq"
chnset .5, "prelpfq"
chnset 1, "prelpfdepth"
chnset 1, "prehpfmode"
chnset 1, "prelpfmode"

; initialize Post filter widgets
chnset 10, "posthpffreq"
chnset .5, "posthpfq"
chnset 1, "posthpfdepth"
chnset 15000, "postlpffreq"
chnset .5, "postlpfq"
chnset 1, "postlpfdepth"
chnset 1, "postlpfmode"
chnset 1, "posthpfmode"

; instr 1 redraws waveforms based on pfields & channels, sets visible sliders for them, and updates graph
instr 1
  ishape=p4
  inorm = (chnget("normalize")*2)-1
  iscale chnget "prescale"
  ipostscale chnget "postscale"
  imin chnget "min"
  imax chnget "max"
  kshape init 0
  kreset=0
  if (ishape<0) then
    ishape=-ishape
    kreset=1
  endif

  if (ishape==$W_SINE) then
  ; custom sinusoid
    ift ftgentmp 1, 0, 1024, inorm*10, p5*iscale, p6*iscale, p7*iscale, p8*iscale, p9*iscale, p10*iscale, p11*iscale, p12*iscale    
  elseif (ishape==$W_LINE) then
  ; 1 segment
    ift ftgentmp 1, 0, 1024, inorm*7, p8*iscale, 1024, p9*iscale
  elseif (ishape==$W_PYRAMID) then
  ; 2 segments
    ival1 = p7*iscale
    iseg1 = (p8*512)+512
    ival2 = p9*iscale
    iseg2 = 1024-iseg1
    ival3 = p10*iscale
    ift ftgentmp 1, 0, 1024, inorm*7, ival1, iseg1, ival2, iseg2, ival3
  elseif (ishape==$W_TRIANGLE) || (ishape==$W_SQUARE) || (ishape==$W_SAW) || (ishape==$W_RSAW) then
  ; 3 segments
    ival1=p6*iscale
    iseg1=(p7*256)+256
    ival2=p8*iscale
    ival3=p10*iscale
    iseg3=(-p9*256)+256
    ival4=p11*iscale
    iseg2=1024-(iseg1+iseg3)
    ift ftgentmp 1, 0, 1024, inorm*7, ival1, iseg1, ival2, iseg2, ival3, iseg3, ival4
; STEP 3: make sure elseif matches defined name set in step 2.
; STEP 3: add custom ftgentmp statement here loading over table 1. table length must be 1024 or things may break
; STEP 3: table should have min/max values of -1 and 1, values exceeding will be limited
;  elseif (ishape==$W_YOURSHAPE) then
;    ift ftgentmp 1, 0, 1024, 10, 1
  endif
    tablelimit 1, imin, imax, ipostscale
; set slider text and values for known tables shapes
if changed(ishape,kreset)==1 then
  if (ishape!=gilastshape) || (kreset==1) then
    chnset sprintfk("visible(%d)", ishape==$W_SINE ? 0 : 1), "breakpoints-c"
    chnset k(1), "distgain"
    chnset k(1), "prescale"
    chnset k(1), "postscale"
    chnset k(-1), "min"
    chnset k(1), "max"
    if (ishape==$W_SINE) then
      setsliders, $T_SINE, 1
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
chnset "tablenumber(1)", "graph1"
endif

endin

; instr 2 is the main processing instrument
instr 2
ktest chnget "test"

; read I/O widgets
kpregain chnget "pregain"
kgain chnget "gain"
kpostgain chnget "postgain"
kpregain ampdb kpregain
kgain ampdb kgain
kpostgain ampdb kpostgain
kmono chnget "mono"
kbypass chnget "bypass"
kdrywet chnget "drywet"
kbalance chnget "balance"

; read Distort widgets
kshape chnget "shape"
kdist chnget "dist"
kpop chnget "pop-button"

; read Customize widgets
kh1 chnget "val1"
kh2 chnget "val2"
kh3 chnget "val3"
kh4 chnget "val4"
kh5 chnget "val5"
kh6 chnget "val6"
kh7 chnget "val7"
kh8 chnget "val8"
kscale chnget "prescale"
kpostscale chnget "postscale"
kreset chnget "reset"
knorm chnget "normalize"
kmin chnget "min"
kmax chnget "max"
kbreak chnget "breakpoints"

; read Pre filter widgets
kprehpffreq chnget "prehpffreq"
kprehpfgain chnget "prehpfg"
kprehpfgain ampdb kprehpfgain
kprehpfq chnget "prehpfq"
kprehpfdepth chnget "prehpfdepth"
kprelpffreq chnget "prelpffreq"
kprelpfgain chnget "prelpfg"
kprelpfdist chnget "prelpfd"
kprelpfgain ampdb kprelpfgain
kprelpfq chnget "prelpfq"
kprelpfdepth chnget "prelpfdepth"
kprehpfmode chnget "prehpfmode"
kprelpfmode chnget "prelpfmode"

; read Post filter widgets
kposthpffreq chnget "posthpffreq"
kposthpfgain chnget "posthpfg"
kposthpfgain ampdb kposthpfgain
kposthpfq chnget "posthpfq"
kposthpfdepth chnget "posthpfdepth"
kpostlpffreq chnget "postlpffreq"
kpostlpfgain chnget "postlpfg"
kpostlpfdist chnget "postlpfd"
kpostlpfgain ampdb kpostlpfgain
kpostlpfq chnget "postlpfq"
kpostlpfdepth chnget "postlpfdepth"
kpostlpfmode chnget "postlpfmode"
kposthpfmode chnget "posthpfmode"

if changed(kmin)==1 && (kmin>kmax) then
  chnset kmin, "max"
elseif changed(kmax)==1 && (kmax<kmin) then
  chnset kmax, "min"
endif

; negative shape indicates reset
kshape = kreset==0 ? kshape : -1*kshape
if changed(kshape, kh1, kh2, kh3, kh4, kh5, kh6, kh7, kh8, knorm, kscale, kpostscale, kmin, kmax, kreset)==1 then
	event "i", 1, 0, .001, kshape, kh1, kh2, kh3, kh4, kh5, kh6, kh7, kh8
endif

; show customize popup if button is pushed
if changed(kpop)==1 then
	chnset sprintfk("show(%d)",kpop), "cc-popup"
endif

; waiting for new cabbage features for active graph
; set graph to active if manual breakpoints is on
;if changed(kbreak)==1 then
;  chnset sprintfk("active(%d)", kbreak==1 ? 1 : 0), "graph1"
;endif

; only show pre scaling when not normalizing
if changed(knorm)==1 then
  chnset sprintfk("visible(%d)",knorm==1 ? 0 : 1), "scale-c"
endif

; change bypass text and hide effect widgets
if changed(kbypass)==1 then
  if (kbypass==1) then
    Sbuf strcpyk "text(\"Bypassed\")"
    Sbuf2 strcpyk "visible(0)"

  else
    Sbuf strcpyk "text(\"Bypass\")"
    Sbuf2 strcpyk "visible(1)"
  endif
  chnset Sbuf, "bypass-c"
  chnset Sbuf2, "distort-c"
  chnset Sbuf2, "pre-hpf-c"
  chnset Sbuf2, "pre-lpf-c"
  chnset Sbuf2, "post-hpf-c"
  chnset Sbuf2, "post-lpf-c"
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

; convert modes from combobox to multifilt values
ktmp = gihpfval[kprehpfmode]
kprehpfmode = ktmp
ktmp = gilpfval[kprelpfmode]
kprelpfmode = ktmp
ktmp = gihpfval[kposthpfmode]
kposthpfmode = ktmp
ktmp = gilpfval[kpostlpfmode]
kpostlpfmode = ktmp

; set widgets visible based off mode
multifiltvis kprehpfmode, "prehpf"
multifiltvis kprelpfmode, "prelpf"
multifiltvis kposthpfmode, "posthpf"
multifiltvis kpostlpfmode, "postlpf"

; handle audio inputs
asrcL inch 1
asrcR inch 2

#ifdef $DEBUG
if (ktest==1) then
  asrcL oscil .75, 440
  ; asrcL diskin "fox.wav", 1, 0, 1
  asrcR = asrcL
  ;asrcL, asrcR diskin "stereotest.wav", 1, 0, 1
endif

; try a few times to set these
kinit init 0
if (kinit<=50) then
  Sbuf strcpyk "visible(1)"
  chnset Sbuf, "test-c"
  chnset Sbuf, "debug"
  kinit = kinit+1
endif
#endif

; mono input collapse snippet
if (kmono==1) then
  asrcL = (asrcL+asrcR)*.5
  asrcR = asrcL
endif

; check for and display input clipping
asrcL, asrcR, kclip quickclip asrcL, asrcR
if changed(kclip)==1 then
  chnset sprintfk("value(%d)", kclip==1 ? 1 : 0), "in-clip-c"
endif

asigL = asrcL*kpregain
asigR = asrcR*kpregain

; reinit idepth
if changed(kprehpfdepth)==1 then
  reinit prehpfinit
endif
prehpfinit:
idepth=i(kprehpfdepth)
; run filter
asigL, asigR multifilt asigL, asigR, kprehpfmode, kprehpffreq, kprehpfq, kprehpfgain, idepth

; set gain to dist value if LPF18
kprelpfgain=kprelpfmode==$F_LPF18 ? kprelpfdist : kprelpfgain
; reinit idepth
if changed(kprelpfdepth)==1 then
  reinit prelpfinit
endif
prelpfinit:
idepth=i(kprelpfdepth)
; run filter
asigL, asigR multifilt asigL, asigR, kprelpfmode, kprelpffreq, kprelpfq, kprelpfgain, idepth

asigL distort asigL*kgain, kdist, 1
asigR distort asigR*kgain, kdist, 1

; reinit idepth
if changed(kposthpfdepth)==1 then
  reinit posthpfinit
endif
posthpfinit:
idept3=i(kposthpfdepth)
; run filter
asigL, asigR multifilt asigL, asigR, kposthpfmode, kposthpffreq, kposthpfq, kposthpfgain, idepth

; set gain to dist value if LPF18
kpostlpfgain=kpostlpfmode==$F_LPF18 ? kpostlpfdist : kpostlpfgain
; reinit idepth
if changed(kpostlpfdepth)==1 then
  reinit postlpfinit
endif
postlpfinit:
idepth=i(kpostlpfdepth)
; run filter
asigL, asigR multifilt asigL, asigR, kpostlpfmode, kpostlpffreq, kpostlpfq, kpostlpfgain, idepth

; apply postgain
asigL = asigL*kpostgain 
asigR = asigR*kpostgain

asigL = $DRYWET(asrcL'asigL'kdrywet)
asigR = $DRYWET(asrcR'asigR'kdrywet)

atmpL = $BALL(asigL'asigR'kbalance)
atmpR = $BALR(asigL'asigR'kbalance)

; check for and display output clipping
asigL, asigR, kclip quickclip atmpL, atmpR
if changed(kclip)==1 then
  chnset sprintfk("value(%d)", kclip==1 ? 1 : 0), "clip-c"
endif

; smooth bypass swap to avoid clicks
kbypass port kbypass, $PORT_TIME
abypass interp kbypass
asigL = $BYPASS(asrcL'asigL'abypass)
asigR = $BYPASS(asrcR'asigR'abypass)

outs asigL, asigR
endin

; i3 is a hacky workaround to make damn sure the wave gets set up
instr 3
setsliders $T_SINE, 1
endin

</CsInstruments>  
<CsScore>
f1 0 1024 10 1
i2 0 z
i3 .1 .01
</CsScore>
</CsoundSynthesizer>
