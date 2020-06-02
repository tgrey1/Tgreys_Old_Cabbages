<Cabbage>
;
; DoubleDown.csd by Kevin Welsh (tgrey)
; version 2.1 - Oct.28 2015
;
; Quick & simple vocal track doubling effect using vdelay
; NOTE: input is collapsed to mono for stereo spread effect
;
; "Amount" controls how far in time the new audio will be from
; the original.  Maximum amount equates to 75ms, but can
; be easily changed in the the line: #define MAX_DELAY #75#
;
; "Spread" is centered at 0, and moves either direction.  This
; moves the original signal and delayed signal apart from
; each other in the stereo field, with -1 or 1 representing
; full pan separation
;
; "Gain" is amount of gain in dB applied to the signal, with
; a range from -90 to +30
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
; v 2.1 - hide effect controls when bypassed
;         removed clip opcode from quickclip, now limit only
;         added DEL_PORT_TIME so bypass and del are different times
;         fixed debug handling in preparation for IS_A_PLUGIN
;

#define GREEN_CB colour:0(0, 25, 0, 255), colour:1(0,255,0,255), fontcolour(160, 160, 160, 255), shape("circle"),
#define RED_CB colour:0(25, 0, 0, 255), colour:1(255,0,0,255), fontcolour(160, 160, 160, 255), shape("circle"),
#define CLIP_CB colour:0(25, 0, 0, 255), colour:1(255,0,0,255), fontcolour(160, 160, 160, 255), active(0), shape("square"),
#define GAIN_KNOB colour(255, 0, 0, 160), trackercolour(0, 255, 0, 255), fontcolour(160, 160, 160, 255),
#define DW_KNOB colour(0, 95, 255, 255), trackercolour(0, 255, 0, 255), fontcolour(160, 160, 160, 255),
#define PAN_KNOB colour(125, 125, 125, 255), trackercolour(0, 255, 0, 255), fontcolour(160, 160, 160, 255),
#define EFF_KNOB colour(0,255,0,160), trackercolour(0, 255, 0, 255), fontcolour(160, 160, 160, 255),
#define TEXT colour(0,0,0,0), fontcolour(160, 160, 160, 255),
#define TEST_BUTTON colour:0(30, 30, 30, 255), colour:1(60,60,60,255), fontcolour:0(160, 160, 160, 255), fontcolour:1(0,255,0,255),
#define DIS_PLANT colour(55,55,55,55), fontcolour(50, 50, 50, 255), line(1), text("Disabled")
#define PLANT colour(40,40,40,255), line(1)
#define ROOT colour(20,20,20,255)

form size(380, 284), caption("Double Down"), pluginID("dbl2"), $ROOT

groupbox bounds(10, 94, 360, 180), $DIS_PLANT

groupbox bounds(10, 10, 360, 80), text("In / Out"), plant("io"), $PLANT {
  label bounds(10, 5, 120, 10), text("OL"), align("left"),  colour(0, 0, 0, 0), $TEXT
  checkbox bounds(25, 5, 10, 10), channel("in-clip"), shape("square"), value(0), identchannel("in-clip-c"), active(0), $CLIP_CB
  label bounds(325, 5, 120, 10), text("OL"), align("left"),  colour(0, 0, 0, 0), $TEXT
  checkbox bounds(340, 5, 10, 10), channel("clip"), shape("square"), value(0), identchannel("clip-c"), active(0), $CLIP_CB

  checkbox bounds(10, 25, 90, 25), channel("bypass"), shape("circle"), text("---"), identchannel("bypass-c"), $GREEN_CB

  button bounds(90, 0, 60, 20), channel("test"), text("Test", "Testing..."), latched(1), value(0), identchannel("test-c"), visible(0), $TEST_BUTTON
  label bounds(8, 55, 130, 15), text("Input: Mono L+R"), align("centre"),  colour(0, 0, 0, 0), $TEXT
  rslider bounds(188, 25, 50, 50), channel("gain"), range(-90, 30, 0, 2.5, 0.01), text("Gain dB"), $GAIN_KNOB
  rslider bounds(246, 25, 50, 50), channel("drywet"), range(-1, 1, 1, 1, 0.01), text("Dry/Wet"), $DW_KNOB
  rslider bounds(304, 25, 50, 50), channel("balance"), range(-1, 1, 0, 1, 0.01), text("Balance"), $PAN_KNOB
}

groupbox bounds(10, 94, 360, 180), text("Doubler"), plant("doubler"), identchannel("doubler-c"), $PLANT {
  rslider bounds(20, 25, 150, 150), channel("amount"), range(0, 1, 0, 1, 0.01), text("Amount"), $EFF_KNOB
  rslider bounds(190, 25, 150, 150), channel("spread"), range(-1, 1, 0, 1, 0.01), text("L/R Spread"), $EFF_KNOB
}
</Cabbage>
<CsoundSynthesizer>
<CsOptions>
-n -d
</CsOptions>
<CsInstruments>
sr		= 44100
ksmps	= 64
nchnls	= 2
0dbfs	= 1

;#define DEBUG #1#
#ifdef IS_A_PLUGIN
  #ifdef DEBUG
;    #undef DEBUG
  #endif
#endif

#define MAX_DELAY #75#

#define CLIP_LEV_DB #-.25#
#define CLIP_LEV #db($CLIP_LEV_DB)#

#define PORT_TIME #.1#
#define DEL_PORT_TIME #.5#

#define DRYWET(d'w'dw) #($d*abs(($dw*.5)-.5))+($w*(($dw*.5)+.5))#
#define BALL(sl'sr'b) #(($sl*min(abs($b-1),1))+($sr*abs(max((-1*$b),0))))*min(1,(1+($b*.5)))#
#define BALR(sl'sr'b) #(($sr*min(abs($b+1),1))+($sl*abs(max($b,0))))*min(1,(1-($b*.5)))#
#define BYPASS(sd'sw'bp) #($sd*$bp)+($sw*(1-$bp))#

; opcode to clip to a certain level and report back if clipped
opcode quickclip,aak,aaj
  asigL, asigR, icliplev xin
  kclipL rms asigL
  kclipR rms asigR

  #ifndef $CLIP_LEV
    #define $CLIP_LEV #.99#
  #end

  if (icliplev<0) then
    icliplev=$CLIP_LEV
  endif

  if (kclipL>=icliplev) || (kclipR>=icliplev) then
    kclip=1
  else
    kclip=0
  endif

  asigL limit asigL, -1*icliplev, icliplev
  asigR limit asigR, -1*icliplev, icliplev

  xout asigL, asigR, kclip
endop

instr 1

; read widget inputs
ktest	chnget "test"
kdelay = chnget:k("amount")*$MAX_DELAY
kspread	chnget "spread"
kdrywet	chnget "drywet"
kbalance chnget "balance"
kbypass chnget "bypass"
kgain = ampdb(chnget:k("gain"))

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
  chnset Sbuf2, "doubler-c"

endif

; read audio inputs
asrcL inch 1
asrcR inch 2

; test code only active if DEBUG is defined
#ifdef DEBUG
  if ktest==1 then
    asrcL	diskin "fox.wav", 1, 0, 1
    asrcR	= asrcL
  endif
  kinit init 0
  if (kinit<=50) then
    Sbuf strcpyk "visible(1)"
    chnset Sbuf, "test-c"
    kinit = kinit+1
  endif
#endif

; check for and display input clipping
asrcL, asrcR, kclip quickclip asrcL, asrcR
if changed(kclip)==1 then
  chnset sprintfk("value(%d)", kclip==1 ? 1 : 0), "in-clip-c"
endif

; collapse input to mono
asig = (asrcL+asrcR)*.5*kgain

; smooth delay time
kdelay port kdelay, $DEL_PORT_TIME
adelay interp kdelay

; delayed signal
adel vdelay asig, adelay, $MAX_DELAY

; l/r spread snippet
asigL = (asig*min(1-kspread,1)+adel*min(kspread+1,1))*(1-(.5*(1-abs(kspread))))
asigR = (adel*min(1-kspread,1)+asig*min(kspread+1,1))*(1-(.5*(1-abs(kspread))))

; dry/wet balance snippet
asigL = $DRYWET(asrcL'asigL'kdrywet)
asigR = $DRYWET(asrcR'asigR'kdrywet)

; stereo balanced output snippet
aoutL = $BALL(asigL'asigR'kbalance)
aoutR = $BALR(asigL'asigR'kbalance)

; check for and display output clipping
aoutL, aoutR, kclip quickclip aoutL, aoutR
if changed(kclip)==1 then
  chnset sprintfk("value(%d)", kclip==1 ? 1 : 0), "clip-c"
endif

; smooth bypass swap to avoid clicks
kbypass	port kbypass, $PORT_TIME
abypass	interp kbypass
aoutL = $BYPASS(asrcL'aoutL'abypass)
aoutR = $BYPASS(asrcR'aoutR'abypass)
		outs aoutL, aoutR
endin

</CsInstruments>  
<CsScore>
f1 0 1024 10 1
i1 0 [ 60*60*24*7*4 ]
</CsScore>
</CsoundSynthesizer>

