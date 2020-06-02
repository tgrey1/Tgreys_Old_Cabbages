<Cabbage>
;
; Tubewarmth.csd by Kevin Welsh (tgrey)
; version 1.0 - Nov.7 2015
;
; This is a simple cabbage wrapper around Steven Yi's
; tap_tubewarmth UDO, which was in turn based off of
; Tom Szilagyi's TAP TubeWarmth LADSPA plugin.
;
; Tom Szilagyi's descriptions of drive and blend:
;
; drive - Values between 2 and 5 are a good starting point
; for a variety of source materials. Since audio tracks can
; vary quite a bit in average and peak levels, experiment
; with this setting and use your ears to get the sound you want.
; (It's quite easy if you know how real tube amps sound like...)
; If the drive level is set too high, the signal will most
; likely sound distorted. If it's too low, you may not hear the
; effect working. 
;
; blend - controls the colour of the TubeWarmth sound. When set
; all the way to the right (+10 or default position), the plugin
; emulates the sound of triode tube distortion. The result is
; asymmetrical, producing mostly second harmonics and some third.
; When set all the way to the left (-10), the plugin emulates the
; sound of analog tape. The result is symmetrical and produces
; mostly third harmonics and some second. With high drive settings,
; moving the blend control to the left increases the apparent
; loudness of low-level signals dramatically. This is because the
; zero-attack, zero-release compression effect is increased under
; these conditions. Use the blend control to set the sound of the
; plugin anywhere between Tape and Tube sound. 
;
;
;
; "Stereo In"/"Mono L+R" switches wheter input is left as stereo
; or collapsed to L+R.
;
; Pre and post gain applies to both wet and dry audio (but not
; bypassed audio!) and can range from -90 to +30 dB.
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
;
#define GREEN_CB colour:0(0, 25, 0, 255), colour:1(0,255,0,255), fontcolour(160, 160, 160, 255), shape("circle"),
#define RED_CB colour:0(25, 0, 0, 255), colour:1(255,0,0,255), fontcolour(160, 160, 160, 255), shape("circle"),
#define CLIP_CB colour:0(25, 0, 0, 255), colour:1(255,0,0,255), fontcolour(160, 160, 160, 255), active(0), shape("square"),
#define GAIN_KNOB colour(255, 0, 0, 160), trackercolour(0, 255, 0, 255), fontcolour(160, 160, 160, 255),
#define DW_KNOB colour(0, 95, 255, 255), trackercolour(0, 255, 0, 255), fontcolour(160, 160, 160, 255),
#define PAN_KNOB colour(125, 125, 125, 255), trackercolour(0, 255, 0, 255), fontcolour(160, 160, 160, 255),
#define EFF_KNOB colour(0,255,0,160), trackercolour(0, 255, 0, 255), fontcolour(160, 160, 160, 255),
#define TEST_BUTTON colour:0(30, 30, 30, 255), colour:1(60,60,60,255), fontcolour:0(160, 160, 160, 255), fontcolour:1(0,255,0,255),
#define DIS_PLANT colour(55,55,55,55), fontcolour(50, 50, 50, 255), line(1), text("Disabled")
#define PLANT colour(40,40,40,255), fontcolour(160, 160, 160, 255), line(1)
#define ROOT colour(20,20,20,255)

form size(380, 304), caption("Tubewarmth"), pluginID("ttub"), $ROOT

groupbox bounds(10, 10, 360, 80), text("In/Out"), plant("io"), $PLANT {
  label bounds(10, 5, 120, 10), text("OL"), align("left"), $TEXT
  checkbox bounds(25, 5, 10, 10), channel("in-clip"), value(0), identchannel("in-clip-c"), $CLIP_CB
  label bounds(325, 5, 120, 10), text("OL"), align("left"), $TEXT
  checkbox bounds(340, 5, 10, 10), channel("clip"), value(0), identchannel("clip-c"), $CLIP_CB
  button bounds(70, 0, 60, 20), channel("test"), text("Test", "Testing..."), latched(1), value(0), visible(0). identchannel("test-c"), $TEST_BUTTON

  checkbox bounds(10, 25, 90, 25), channel("bypass"), text("---"), identchannel("bypass-c"), $GREEN_CB
  checkbox bounds(10, 52, 90, 25), channel("mono"), text("---"), identchannel("mono-c"), $RED_CB

  rslider bounds(160, 25, 50, 50), channel("pregain"), range(-90, 30, 0, 2.5, 0.01), text("PreGain"), identchannel("test2"), $GAIN_KNOB
  rslider bounds(208, 25, 50, 50), channel("postgain"), range(-90, 30, 0, 2.5, 0.01), text("PostGain"), identchannel("test2"), $GAIN_KNOB
  rslider bounds(256, 25, 50, 50), channel("drywet"), range(-1, 1, 1, 1, 0.01), text("Dry/Wet"), $DW_KNOB
  rslider bounds(304, 25, 50, 50), channel("balance"), range(-1, 1, 0, 1, 0.01), text("Balance"), $PAN_KNOB
}

groupbox bounds(10, 94, 360, 200), $DIS_PLANT { }

groupbox bounds(10, 94, 360, 200), text("Tubewarmth"), plant("tube"), identchannel("tube-c"), $PLANT {
  rslider bounds(15, 30, 150, 150), channel("drive"), range(0, 10, 0), text("Drive"), $EFF_KNOB
  rslider bounds(195, 30, 150, 150), channel("blend"), range(-10, 10, 0), text("Blend"), $EFF_KNOB
}
  label bounds(0, 276, 350, 15), text("---"), align("left"),  colour(155, 0, 0), fontcolour(255, 255, 255, 255), identchannel("debug"), visible(0)
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

;#define DEBUG #1#
#ifdef IS_A_PLUGIN
  #ifdef DEBUG
;    #undef DEBUG
  #endif
#endif

#define PORT_TIME #.005#

#define CLIP_LEV_DB #-.25#
#define CLIP_LEV #db($CLIP_LEV_DB)#

#define DRYWET(d'w'dw) #($d*abs(($dw*.5)-.5))+ ( $w*(($dw*.5)+.5))#
#define BYPASS(sd'sw'bp) #($sd*$bp)+($sw*(1-$bp))#
#define PANL(s'p) #($s*abs(($p-1)*.5 ))#
#define PANR(s'p) #($s*abs(($p+1)*.5))#
#define BALL(sl'sr'b) #$PANL($sl'$b)+($sr*max(0,($b*-.5)))#
#define BALR(sl'sr'b) #$PANR($sr'$b)+($sl*max(0,($b*.5)))#

	opcode tap_tubewarmth,a,akk

setksmps 1

ain, kdrive, kblend xin

kdrive	 	limit kdrive, 0.1, 10
kblend 		limit kblend, -10, 10

kprevdrive init 0
kprevblend init 0

krdrive 	init 0
krbdr 		init 0
kkpa 		init 0
kkpb 		init 0
kkna 		init 0
kknb 		init 0
kap 		init 0
kan 		init 0
kimr 		init 0
kkc 		init 0
ksrct 		init 0
ksq 		init 0
kpwrq 		init 0

#define TAP_EPS # 0.000000001 # 
#define TAP_M(X) # $X = (($X > $TAP_EPS || $X < -$TAP_EPS) ? $X : 0) #
#define TAP_D(A) # 
if ($A > $TAP_EPS) then
	$A = sqrt($A)
elseif ($A < $TAP_EPS) then
	$A = sqrt(-$A)
else
	$A = 0
endif
#

if (kprevdrive != kdrive || kprevblend != kblend) then

krdrive = 12.0 / kdrive;
krbdr = krdrive / (10.5 - kblend) * 780.0 / 33.0;

kkpa = 2.0 * (krdrive*krdrive) - 1.0
$TAP_D(kkpa)
kkpa = kkpa + 1.0;

kkpb = (2.0 - kkpa) / 2.0;
kap = ((krdrive*krdrive) - kkpa + 1.0) / 2.0;

kkc = 2.0 * (krdrive*krdrive) - 1.0
$TAP_D(kkc)
kkc = 2.0 * kkc - 2.0 * krdrive * krdrive
$TAP_D(kkc)

kkc = kkpa / kkc

ksrct = (0.1 * sr) / (0.1 * sr + 1.0);
ksq = kkc*kkc + 1.0

kknb = ksq
$TAP_D(kknb)
kknb = -1.0 * krbdr / kknb

kkna = ksq
$TAP_D(kkna)
kkna = 2.0 * kkc * krbdr / kkna

kan = krbdr*krbdr / ksq

kimr = 2.0 * kkna + 4.0 * kan - 1.0
$TAP_D(kimr)
kimr = 2.0 * kknb + kimr


kpwrq = 2.0 / (kimr + 1.0)

kprevdrive = kdrive
kprevblend = kblend

endif

aprevmed 	init 0
amed 		init 0
aprevout	init 0

kin downsamp ain

if (kin >= 0.0) then
	kmed = kap + kin * (kkpa - kin)
	$TAP_D(kmed)
	amed = (kmed + kkpb) * kpwrq
else
	kmed = kap - kin * (kkpa + kin)
	$TAP_D(kmed)
	amed = (kmed + kkpb) * kpwrq * -1
endif

aout = ksrct * (amed - aprevmed + aprevout)

kout downsamp aout
kmed downsamp amed


if (kout < -1.0) then
	aout = -1.0
	kout = -1.0
endif

$TAP_M(kout)
$TAP_M(kmed)

aprevmed = kmed
aprevout = kout

#undef TAP_D
#undef TAP_M
#undef TAP_EPS

xout aout

	endop


; opcode to clip to a certain level and report back if clipped
opcode quickclip,ak,aj
  asig, icliplev xin

  #ifndef $CLIP_LEV
    #define $CLIP_LEV #.99#
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


instr 1

ktest chnget "test"

kmono chnget "mono"
kbypass chnget "bypass"
kpregain = ampdb(chnget:k("pregain"))
kpostgain = ampdb(chnget:k("postgain"))
kdrywet chnget "drywet"
kbalance chnget "balance"

kdrive chnget "drive"
kblend chnget "blend"

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
  chnset Sbuf2, "tube-c"
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

; handle audio inputs
ainL inch 1
ainR inch 2

#ifdef DEBUG
  if ktest==1 then
    ainL        diskin "fox.wav", 1, 0, 1
    ainR        = ainL
;    ainL, ainR diskin "stereotest.wav", 1, 0, 1
  endif
  igoto test_init
  kgoto init_skip
  test_init:
    Sbuf strcpyk "visible(1)"
    chnset Sbuf, "test-c"
    chnset Sbuf, "debug"  
#endif

init_skip:

; mono collapse
if kmono==0 then
  asigL   =       ainL
  asigR   =       ainR
else
  asigL   =       (ainL+ainR)*.5
  asigR   =       asigL
endif

; apply pregain
asrcL = asigL*kpregain
asrcR = asigR*kpregain

; check for and display input clipping
asigL, asigR, kclip quickclip asrcL, asrcR
if changed(kclip)==1 then
  chnset sprintfk("value(%d)", kclip==1 ? 1 : 0), "in-clip-c"
endif

; run tap_tubewarmth
asigL tap_tubewarmth asigL, kdrive, kblend
asigR tap_tubewarmth asigR, kdrive, kblend

; apply postgain
asigL = asigL*kpostgain
asigR = asigR*kpostgain
asrcL = asrcL*kpostgain
asrcR = asrcR*kpostgain

; dry/wet balance snippet
asigL = $DRYWET(asrcL'asigL'kdrywet)
asigR = $DRYWET(asrcR'asigR'kdrywet)

; stereo balance snippet
abalL = $BALL(asigL'asigR'kbalance)
abalR = $BALR(asigL'asigR'kbalance)

; check for and display output clipping
asigL, asigR, kclip quickclip abalL, abalR
if changed(kclip)==1 then
  chnset sprintfk("value(%d)", kclip==1 ? 1 : 0), "clip-c"
endif

; smooth bypass swap to avoid clicks
kbypass port kbypass, $PORT_TIME
abypass interp kbypass
asigL = $BYPASS(ainL'asigL'abypass)
asigR = $BYPASS(ainR'asigR'abypass)

outs asigL, asigR
endin

</CsInstruments>  
<CsScore>
f1 0 1024 10 1
i1 0 3600
</CsScore>
</CsoundSynthesizer>