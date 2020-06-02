<Cabbage>
;
; Delayed.csd by Kevin Welsh (tgrey)
; version 2.0 - Oct.28 2015
;
; Stereo delay line with switchable time modes, ping pong,
; L/R link, L/R swap, time portamento, and extensive
; filtering options in the feedback section.  Feedback can
; extend up to 150% to make up for filtering.
;
; Time mode can be set in seconds, beats at a tempo, or taps
; per beats at a tempo.  Tempo can be from a DAW/host, or
; can be set internal.  Time in seconds can be set up to 6
; seconds.  Tempo can range from 40-280 BPM, with up to
; 4 beats for the "beat" mode, 16 for "per beat" mode.
;
; "Send" is amount of gain in dB applied to the signal entering
;  the delay line, it does not affect dry signal or bypassed
; signal.  Send can range from -90 to +30 dB.
;
; "Return" is amount of gain in dB applied to the signal after
; the filters.  This can be used to adjust the level up or down
; to compensate for steep filtering. Return can range from -90
; to +30 dB.
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
#define STATUS_CB colour:0(0, 25, 0, 255), colour:1(0,255,0,255), fontcolour(160, 160, 160, 255), active(0), shape("square"),
#define GAIN_KNOB colour(255, 0, 0, 160), trackercolour(0, 255, 0, 255), fontcolour(160, 160, 160, 255),
#define DW_KNOB colour(0, 95, 255, 255), trackercolour(0, 255, 0, 255), fontcolour(160, 160, 160, 255),
#define PAN_KNOB colour(125, 125, 125, 255), trackercolour(0, 255, 0, 255), fontcolour(160, 160, 160, 255),
#define EFF_KNOB colour(0,255,0,160), trackercolour(0, 255, 0, 255), fontcolour(160, 160, 160, 255),
#define FILT_KNOB colour(255, 255, 0, 160), trackercolour(0, 255, 0, 255), fontcolour(160, 160, 160, 255),
#define TEXT colour(0,0,0,0), fontcolour(160, 160, 160, 255),
#define BUTTON fontcolour:1(255, 255, 255, 255), fontcolour:0(160, 160, 160, 255), colour:0(30, 30, 30, 255), colour:1(60,60,60,255),
#define TEST_BUTTON colour:0(30, 30, 30, 255), colour:1(60,60,60,255), fontcolour:0(160, 160, 160, 255), fontcolour:1(0,255,0,255),
#define COMBO colour(30,30,30,255),
#define NUMBOX colour(30,30,30,255)
#define WARN_HEAD fontcolour(155, 0, 0), colour(60,60, 60, 255)
#define WARN_TEXT fontcolour(155, 155, 155), colour(60,60, 60, 255)
#define DIS_PLANT colour(55,55,55,55), fontcolour(50, 50, 50, 255), line(1), text("Disabled")
#define PLANT colour(40,40,40,255), line(1)
#define ROOT colour(20,20,20,255)
#define GRAPH tablecolour(green)

; These menus orders need to match the arrays used to convert the combobox values.
#define HPF_MENU text("Bypass", "Low Shelf", "ButterHP", "Atone",  "Peak", "ButterBP", "ButterBR", "Moog", "Reson", "Resonr", "Resonz", "Rezzy")
#define LPF_MENU  text("Bypass", "High Shelf", "ButterLP", "Tone", "Peak", "ButterBP", "ButterBR", "LPF18", "Moog", "Reson", "Resonr", "Resonz", "Rezzy[!]")

form size(380, 396), caption("Delayed"), pluginID("tdl2"), $ROOT

groupbox bounds(10, 94, 360, 173), $DIS_PLANT
groupbox bounds(10, 271, 178, 120), $DIS_PLANT
groupbox bounds(193, 271, 178, 120), $DIS_PLANT

groupbox bounds(10, 10, 360, 80), text("In / Out"), plant("io"), $PLANT {
  button bounds(100, 2, 50, 15), channel("testR"), text("Test R","ON"), latched("0"), value(0), visible(0), identchannel("testr-c"), $TEST_BUTTON
  button bounds(46, 2, 50, 15), channel("testL"), text("Test L","ON"), latched("0"), value(0), visible(0), identchannel("testl-c"), $TEST_BUTTON
  button bounds(230, 2, 60, 15), channel("testSt"), text("Test St","TESTING"), latched("0"), value(0), visible(0), identchannel("tests-c"), $TEST_BUTTON

  label bounds(10, 5, 120, 10), text("OL"), align("left"), $TEXT
  checkbox bounds(25, 5, 10, 10), channel("in-clip"), value(0), identchannel("in-clip-c"), $CLIP_CB
  label bounds(325, 5, 120, 10), text("OL"), align("left"), $TEXT
  checkbox bounds(340, 5, 10, 10), channel("clip"), value(0), identchannel("clip-c"), $CLIP_CB

  checkbox bounds(10, 25, 90, 25), channel("bypass"), shape("circle"), text("---"), identchannel("bypass-c"), $GREEN_CB
  checkbox bounds(10, 52, 90, 25), channel("mono"), shape("circle"), text("---"), identchannel("mono-c"), $RED_CB
  rslider bounds(130, 25, 50, 50), channel("send"), range(-90, 30, 0, 2.5, 0.01), text("Send dB"), $GAIN_KNOB

  rslider bounds(188, 25, 50, 50), channel("return"), range(-90, 30, 0, 2.5, 0.01), text("Rturn dB"), $GAIN_KNOB
  rslider bounds(246, 25, 50, 50), channel("drywet"), range(-1, 1, 0, 1, 0.01), text("Dry/Wet"), $DW_KNOB
  rslider bounds(304, 25, 50, 50), channel("balance"), range(-1, 1, 0, 1, 0.01), text("Balance"), $PAN_KNOB
}

groupbox bounds(10, 94, 360, 173), text("Delay"), plant("delay"), identchannel("delay-c"), $PLANT {
  label bounds(5, 5, 120, 10), text("TAP"), align("left"), $TEXT
  checkbox bounds(25, 5, 10, 10), channel("tapl"), value(0), identchannel("tapl-c"), $STATUS_CB
  label bounds(320, 5, 120, 10), text("TAP"), align("left"), $TEXT
  checkbox bounds(340, 5, 10, 10), channel("tapr"), value(0), identchannel("tapr-c"), $STATUS_CB

  rslider bounds(4, 25, 80, 80), channel("delayTL"), range(.001, 6, 0.5, .5, 0.001), text("Delay L"), popuptext("Time in seconds"), identchannel("TimeL"), visible(0), $EFF_KNOB
  rslider bounds(4, 25, 80, 80), channel("delayBL"), range(.25, 4, 0.5, 1, 0.25), text("Delay L"), popuptext("Beats per tap"), identchannel("BeatL"), visible(0), $EFF_KNOB
  rslider bounds(4, 25, 80, 80), channel("delayPBL"), range(1, 16, 2, 1, 1), text("Delay L"), popuptext("Taps per beat"), identchannel("PerBeatL"), visible(0), $EFF_KNOB

  rslider bounds(86, 25, 80, 80), channel("delayTR"), range(.001, 6, 0.5, .5, 0.001), text("Delay R"), popuptext("Time in seconds"), identchannel("TimeR"), visible(0), $EFF_KNOB
  rslider bounds(86, 25, 80, 80), channel("delayBR"), range(.25, 4, 0.5, 1, 0.25), text("Delay R"), popuptext("Beats per tap"), identchannel("BeatR"), visible(0), $EFF_KNOB  
  rslider bounds(86, 25, 80, 80), channel("delayPBR"), range(1, 16, 2, 1, 1), text("Delay R"), popuptext("Taps per beat"), identchannel("PerBeatR"), visible(0), $EFF_KNOB

  rslider bounds(168, 25, 80, 80), channel("feedback"), range(0, 150, 60, .5, 0.01), text("Feedback %"), identchannel("fb-c"), $EFF_KNOB
  label bounds(255, 30, 90, 15), text("Time Mode:"), align("centre"), $TEXT
  combobox bounds(255, 50, 100, 30), channel("mode"), items("Time in Sec", "Beats", "Taps per Beat"), value(1), $COMBO
  combobox bounds(255, 82, 100, 30), channel("tempomode"), items("Host DAW", "Internal"), identchannel("tempotest"), value(1), visible(0) $COMBO
  label bounds(230, 118, 90, 15), text("BPM:"), align("centre"), identchannel("tempolabel"), visible(0), $TEXT
  nslider bounds(294, 115, 60, 20), channel("tempo"), range(40, 240, 60), identchannel("tempobox"), visible(0), $NUMBOX
  label bounds(280, 118, 90, 15), text("---"), align("centre"), identchannel("hosttempo"), visible(0), $TEXT
  checkbox bounds(5, 115, 79, 20), channel("link"), text("Link L+R"), value(0), identchannel("link-c"), $GREEN_CB
  checkbox bounds(100, 115, 82, 20), channel("swap"), text("Swap L+R"), value(0), $GREEN_CB
  checkbox bounds(5, 145, 83, 20), channel("pong"), text("Ping Pong"), value(0), $GREEN_CB
  checkbox bounds(100, 145, 69, 20), channel("smooth"), text("Smooth"), value(0), $GREEN_CB
  button bounds(255, 143, 102, 25), channel("clear"), text("Clear FB","CLEARING"), latched("0"), value(0), $BUTTON
}

groupbox bounds(10, 271, 178, 120), text("HPF"), plant("HPF"), identchannel("hpf-c"), $PLANT {
  rslider bounds(10, 22, 50, 50), channel("hpffreq"), range(10, 15000, 10, .5, 0.01), text("Freq"), identchannel("hpff_c"), visible(0), $FILT_KNOB
  rslider bounds(110, 22, 50, 50), channel("hpfg"), range(-10, 10, 0, 1, 0.01), text("Gain"), identchannel("hpfg_c"), visible(0), $FILT_KNOB
  rslider bounds(60, 22, 50, 50), channel("hpfq"), range(0.01, 1, 0.5, 1, 0.01), text("Q/Res"), identchannel("hpfq_c"), visible(0), $FILT_KNOB
  combobox bounds(5, 80, 100, 30), channel("hpfmode"), channeltype("number"), value(1), $COMBO, $HPF_MENU
  rslider bounds(110, 70, 50, 50), channel("hpfdepth"), range(0, 8, 1, 1, 1), text("Depth"), identchannel("hpfdepth_c"), visible(0), $FILT_KNOB
}

groupbox bounds(193, 271, 178, 120), text("LPF"), plant("LPF"), identchannel("lpf-c"), $PLANT {
  rslider bounds(10, 22, 50, 50), channel("lpffreq"), range(10, 15000, 15000, .5, 0.01), text("Freq"), identchannel("lpff_c"), visible(0), $FILT_KNOB
  rslider bounds(110, 22, 50, 50), channel("lpfg"), range(-10, 10, 0, 1, 0.01), text("Gain"), identchannel("lpfg_c"), visible(0), $FILT_KNOB
  rslider bounds(110, 22, 50, 50), channel("lpfd"), range(0, 1, 0, 1, 0.01), text("Distort"), identchannel("lpfd_c"), visible(0), $FILT_KNOB
  rslider bounds(60, 22, 50, 50), channel("lpfq"), range(0.01, 1, 0.5, 1, 0.01), text("Q/Res"), identchannel("lpfq_c"), visible(0), $FILT_KNOB
  combobox bounds(5, 80, 100, 30), channel("lpfmode"), channeltype("number"), value(1), identchannel("lpfmode-c"), $COMBO, $LPF_MENU
  rslider bounds(110, 70, 50, 50), channel("lpfdepth"), range(0, 8, 1, 1, 1), text("Depth"), identchannel("lpfdepth_c"), visible(0), $FILT_KNOB
}

groupbox bounds(0, 0, 350, 110), text("Warning"), plant("Warning"), popup(1), identchannel("rezzy-popup"), show(0) {
  label bounds(0, 20, 350, 90), text(""), align("centre"), $WARN_TEXT
  label bounds(0, 20, 350, 30), text("Warning!"), align("centre"), $WARN_HEAD
  label bounds(0, 50, 350, 20), text("Rezzy in LPF mode is *VERY*"), align("centre"), $WARN_TEXT
  label bounds(0, 70, 350, 20), text("unstable.  Be careful."), align("centre"), $WARN_TEXT
}
  ; label bounds(0, 266, 320, 15), text("---"), align("left"),  colour(155, 0, 0), fontcolour(255, 255, 255, 255), identchannel("debug"), visible(0)

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

; headroom before OL lights and clipping is applied
#define CLIP_LEV_DB #-.5#
#define CLIP_LEV #db($CLIP_LEV_DB)#

; amount of portk on delay time if smooth is enabled
#define PORT_TIME #.03#
#define DEL_PORT_TIME #.3#

; Default BPM only used when host provides no BPM, or invalid BPM based on defined min/max
#define DEFAULT_BPM #60#
#define MIN_BPM #40#
#define MAX_BPM #280#

; Do not adjust these definitions
#define TIME #1#
#define BEAT #2#
#define PER #3#
#define EXT #1#
#define INT #2#

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

#define DRYWET(d'w'dw) #($d*min((-1*$dw)+1,1))+($w*min(($dw+1),1))#
#define PANL(s'p) #($s*abs(($p-1)*.5 ))#
#define PANR(s'p) #($s*abs(($p+1)*.5))#
#define BALL(sl'sr'b) #$PANL($sl'$b)+($sr*max(0,($b*-.5)))#
#define BALR(sl'sr'b) #$PANR($sr'$b)+($sl*max(0,($b*.5)))#
#define BYPASS(sd'sw'bp) #($sd*$bp)+($sw*(1-$bp))#

; opcode to clip to a certain level and report back if clipped
opcode quickclip,ak,aj
  asig, icliplev xin
  kclip rms asig

  #ifndef $CLIP_LEV
    #define $CLIP_LEV #.99#
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

; stereo version of opcode calls mono version
opcode quickclip,aak,aaj
  asigL, asigR, icliplev xin
  asigL, kclipL quickclip asigL, icliplev
  asigR, kclipR quickclip asigR, icliplev
  kclip = kclipL==1 || kclipR==1 ? 1 : 0
  xout asigL, asigR, kclip
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
    ; maybe make reseting filters when changed a selectable option in the future?
    ; reset depth when filter changes for safety?
    ; chnset k(1), sprintfk("%sdepth",Sprefix)
    ; set defaults for q/res
    ; ktemp = kmode==$F_LPF18 ? .2 : .7
    ; chnset ktemp, sprintf("%sq",Sprefix)
    chnset sprintfk("show(%d), pos(1, 1)", kmode==$F_REZZYLP ? 1 : 0), "rezzy-popup"
    chnset sprintfk("text(m: %d)",kmode),"debug"
  endif
endop

; initialize non-0 variables in case widgets don't reload properly
chnset 1, "mode"
chnset 1, "tempomode"
chnset 1, "hpfmode"
chnset 1, "lpfmode"
chnset 1, "hpfdepth"
chnset 1, "lpfdepth"
chnset 10, "hpffreq"
chnset 15000, "lpffreq"
chnset .5, "hpfq"
chnset .5, "lpfq"
chnset .5, "delayTL"
chnset .5, "delayTR"
chnset .5, "delayBL"
chnset .5, "delayBR"
chnset 2, "delayPBL"
chnset 2, "delayPBR"
chnset 60, "feedback"
chnset 60, "tempo"

; main instrument
instr 1
ktestL chnget "testL"
ktestR chnget "testR"
ktestSt chnget "testSt"
kbypass chnget "bypass"
kmono chnget "mono"
ksend = ampdb(chnget:k("send"))
kreturn = ampdb(chnget:k("return"))
kdrywet chnget "drywet"
kbalance chnget "balance"

; read most of the delay widgets (time comes later)
kmode chnget "mode"
ktempomode chnget "tempomode"
kfb = chnget:k("feedback")*.01
klink chnget "link"
kpong chnget "pong"
kswap chnget "swap"
ksmooth chnget "smooth"
kclear chnget "clear"

; read hpf filter widgets
khpfmode chnget "hpfmode"
khpffreq chnget "hpffreq"
khpfgain chnget "hpfg"
khpfgain ampdb khpfgain
khpfq chnget "hpfq"
khpfdepth chnget "hpfdepth"

; read lpf filter widgets
klpfmode chnget "lpfmode"
klpffreq chnget "lpffreq"
klpfgain chnget "lpfg"
klpfdist chnget "lpfd"
klpfgain ampdb klpfgain
klpfq chnget "lpfq"
klpfdepth chnget "lpfdepth"

; Determine beat tempo based on tempomode
if (ktempomode==1) then
  kBPM chnget "HOST_BPM"
else
  kBPM chnget "tempo"
endif

; Adjust for Min/Max
if (kBPM<$MIN_BPM) || (kBPM>$MAX_BPM) then
  kBPM=$DEFAULT_BPM
endif

; Beat time in seconds
kBtime=60/kBPM

; Read delay time widgets based off mode
if (kmode==1) then
  kdelL chnget "delayTL"
  kdelR chnget "delayTR"
elseif (kmode==2) then
  kdelL chnget "delayBL"
  kdelR chnget "delayBR"
elseif (kmode==3) then
  kdelL chnget "delayPBL"
  kdelR chnget "delayPBR"
endif

; Adjust widgets if linked
if (klink==1) then
  if changed(kdelL)==1 then
    if kmode==$TIME then
      chnset kdelL, "delayTR"
    elseif kmode==$BEAT then
      chnset kdelL, "delayBR"
    elseif kmode==$PER then
      chnset kdelL, "delayPBR"
    endif
  elseif changed(kdelR)==1 then
    if kmode==$TIME then
      chnset kdelR, "delayTL"
    elseif kmode==$BEAT then
      chnset kdelR, "delayBL"
    elseif kmode==$PER then
      chnset kdelR, "delayPBL"
    endif
  endif
endif

; Adjust delay time for tempo as needed
if (kmode==$BEAT) then
  kdelL = kdelL*kBtime
  kdelR = kdelR*kBtime
elseif (kmode==$PER) then
  kdelL = kBtime/kdelL
  kdelR = kBtime/kdelR
endif

; metro for tap lights, can't update much faster than 10hz anyway
kmL metro min(1/kdelL,10)
kmR metro min(1/kdelR,10)

; flash the tap lights in time with the delay
if changed(kmL)==1 then
  chnset sprintfk("value(%d)",kmL==0 ? 1 : 0),"tapl-c"
  if (klink==1) then
    chnset sprintfk("value(%d)",kmL==0 ? 1 : 0),"tapr-c"  
  endif
endif
; only flash right tap if not linked
if changed(kmR)==1 && (klink==0) then
  chnset sprintfk("value(%d)",kmR==0 ? 1 : 0),"tapr-c"
endif

; adjust for milliseconds
kdelL = kdelL*1000
kdelR = kdelR*1000

; Calculate max delay time, the last number is the max number allowed in the "delayB" widgets
init_maxdel:
imaxdeltime=(60/$MIN_BPM)*1000*4

; handle gui changes here
if changed(kmono)==1 then
; waiting for ternary string comparisons bug in csound
;  chnset sprintfk("text(%s)", kmono==1 ? "Mono L+R" : "Stereo In"),"mono-c"
; update mono labels
  if (kmono==1) then
    Sbuf strcpyk "text(\"Mono L+R\")"
  else
    Sbuf strcpyk "text(\"Stereo In\")"
  endif
  chnset Sbuf, "mono-c"
endif

; update bypassed labels and turn off effect plants
if changed(kbypass)==1 then
  if (kbypass==1) then
    Sbuf strcpyk "text(\"Bypassed\")"
    Sbuf2 strcpyk "visible(0)"
  else
    Sbuf strcpyk "text(\"Bypass\")"
    Sbuf2 strcpyk "visible(1)"
  endif
  chnset Sbuf, "bypass-c"
  chnset Sbuf2, "delay-c"
  chnset Sbuf2, "hpf-c"
  chnset Sbuf2, "lpf-c"
endif

; Change visible time controls based on mode and tempomode
if changed(kmode, ktempomode)==1 then
  chnset strcpyk("popuptext(test)"), "clip-c"
	chnset sprintfk("visible(%d)", kmode==$TIME ? 1 : 0)  , "TimeL"
	chnset sprintfk("visible(%d)", kmode==$TIME ? 1 : 0), "TimeR"
	chnset sprintfk("visible(%d)", kmode==$TIME ? 0 : 1), "tempotest"
    chnset sprintfk("visible(%d)", kmode==$TIME ? 0 : 1), "tempolabel"

   	chnset sprintfk("visible(%d)", kmode==$BEAT ? 1 : 0), "BeatL"
	chnset sprintfk("visible(%d)", kmode==$BEAT ? 1 : 0), "BeatR"	

	chnset sprintfk("visible(%d)", kmode==$PER ? 1 : 0), "PerBeatL"
	chnset sprintfk("visible(%d)", kmode==$PER ? 1 : 0), "PerBeatR"
endif

; change visible tempo controls based on mode, tempomode, and tempo
if changed(kmode,ktempomode,kBPM)==1 then
    chnset sprintfk("visible(%d) text(%5.2f)", kmode!=$TIME && ktempomode==$EXT ? 1 : 0, kBPM), "hosttempo"
    chnset sprintfk("visible(%d)", kmode!=$TIME && ktempomode==$INT ? 1 : 0), "tempobox"
endif

; convert filter modes from combobox to multifilt values
ktmp = gihpfval[khpfmode]
khpfmode = ktmp
ktmp = gilpfval[klpfmode]
klpfmode = ktmp

; set widgets visibility based off mode
multifiltvis khpfmode, "hpf"
multifiltvis klpfmode, "lpf"

; start processing audio
; init feedback
afbL init 0
afbR init 0

; Handle Inputs
asrcL inch 1
asrcR inch 2

#ifdef $DEBUG
if (ktestL==1 || ktestSt==1) then
  asrcL oscil .7, 440
endif
if (ktestR==1 || ktestSt==1) then
  asrcR oscil .7, 440
endif

if (ktestSt==1) then
  ; asrcL, asrcR diskin "stereotest.wav", 1, 0, 1
endif

kinit init 0
if (kinit<=50) then
  Sbuf strcpyk "visible(1)"
  chnset Sbuf, "testl-c"
  chnset Sbuf, "testr-c"
  chnset Sbuf, "tests-c"
  chnset Sbuf, "debug"
  kinit = kinit+1
endif
#endif

; keep a true dry copy for bypass
adryL = asrcL
adryR = asrcR

; Mono input collapse
if (kmono==1) then
  asrcL   =       (asrcL+asrcR)*.5
  asrcR   =       asrcL
endif

; check for and display input clipping
asrcL, asrcR, kclip quickclip asrcL, asrcR
if changed(kclip)==1 then
  chnset sprintfk("value(%d)", kclip==1 ? 1 : 0), "in-clip-c"
endif

; Smooth delay time changes if enabled
if (ksmooth==1) then
  kdelL port kdelL, $DEL_PORT_TIME
  adelTL interp kdelL
  kdelR port kdelR, $DEL_PORT_TIME
  adelTR interp kdelR
else
  adelTL = kdelL
  adelTR = kdelR
endif

; Delay the signal with feedback
asigL vdelay3 (asrcL*ksend)+afbL, adelTL, imaxdeltime
asigR vdelay3 (asrcR*ksend)+afbR, adelTR, imaxdeltime

; reinit if filter depth changes
if changed(khpfdepth)==1 then
  reinit hpfinit
endif
hpfinit:
idepth=i(khpfdepth)
; run filter
asigL, asigR multifilt asigL, asigR, khpfmode, khpffreq, khpfq, khpfgain, idepth

; set gain to dist value if LPF18
klpfgain=klpfmode==$F_LPF18 ? klpfdist : klpfgain

; reinit if filter depth changes
if changed(klpfdepth)==1 then
  reinit lpfinit
endif
lpfinit:
idepth=i(klpfdepth)
; run filter
asigL, asigR multifilt asigL, asigR, klpfmode, klpffreq, klpfq, klpfgain, idepth

; PingPong feedback if enabled
if (kpong==0) then
  afbL = asigL*kfb
  afbR = asigR*kfb
else
  afbR = asigL*kfb
  afbL = asigR*kfb
endif

; Clear feedback while button is held
if (kclear==1) then
  afbL = 0
  afbR = 0
endif

; Swap channels if needed
if (kswap==1) then
  atmpL = asigL
  asigL = asigR
  asigR = atmpL
endif

; apply return gain
asigL = asigL*kreturn
asigR = asigR*kreturn

asigL = $DRYWET(asrcL'asigL'kdrywet)
asigR = $DRYWET(asrcR'asigR'kdrywet)

asrcL = $BALL(asigL'asigR'kbalance)
asrcR = $BALR(asigL'asigR'kbalance)

; check for and display output clipping
asigL, asigR, kclip quickclip asrcL, asrcR
if changed(kclip)==1 then
  chnset sprintfk("value(%d)", kclip==1 ? 1 : 0), "clip-c"
endif

; smooth bypass swap to avoid clicks
kbypass port kbypass, $PORT_TIME
abypass interp kbypass
asigL = $BYPASS(adryL'asigL'abypass)
asigR = $BYPASS(adryR'asigR'abypass)

outs asigL, asigR
endin

</CsInstruments>  
<CsScore>
i1 0 z
</CsScore>
</CsoundSynthesizer>
