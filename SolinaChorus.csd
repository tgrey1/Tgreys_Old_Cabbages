<Cabbage>
;
; SolinaChorus.csd by Kevin Welsh (tgrey)
; version 1.0 - Jun.4 2016
;
; This is a simple cabbage wrapper around Steven Yi's
; solina_chorus UDO, original commentary follows:
;
; Solina Chorus, based on Solina String Ensemble Chorus Module
; 
; based on:
;
; J. Haible: Triple Chorus
; http://jhaible.com/legacy/triple_chorus/triple_chorus.html
;
; Hugo Portillo: Solina-V String Ensemble
; http://www.native-instruments.com/en/reaktor-community/reaktor-user-library/entry/show/4525/ 
;
; Parabola tabled shape borrowed from Iain McCurdy delayStereoChorus.csd:
; http://iainmccurdy.org/CsoundRealtimeExamples/Delays/delayStereoChorus.csd
;
; Author: Steven Yi
; Date: 2016.05.22
;

#define GREEN_CB colour:0(0, 25, 0, 255), colour:1(0,255,0,255), fontcolour(160, 160, 160, 255), shape("circle"),
#define RED_CB colour:0(25, 0, 0, 255), colour:1(255,0,0,255), fontcolour(160, 160, 160, 255), shape("circle"),
#define CLIP_CB colour:0(25, 0, 0, 255), colour:1(255,0,0,255), fontcolour(160, 160, 160, 255), active(0), shape("square"),
#define GAIN_KNOB colour(255, 0, 0, 160), trackercolour(0, 255, 0, 255), fontcolour(160, 160, 160, 255),
#define DW_KNOB colour(0, 95, 255, 255), trackercolour(0, 255, 0, 255), fontcolour(160, 160, 160, 255),
#define PAN_KNOB colour(125, 125, 125, 255), trackercolour(0, 255, 0, 255), fontcolour(160, 160, 160, 255),
#define EFF_KNOB colour(0,255,0,160), trackercolour(0, 255, 0, 255), fontcolour(160, 160, 160, 255),
#define FILT_KNOB colour(255, 255, 0, 160), trackercolour(0, 255, 0, 255), fontcolour(160, 160, 160, 255),
#define TEST_BUTTON colour:0(30, 30, 30, 255), colour:1(60,60,60,255), fontcolour:0(160, 160, 160, 255), fontcolour:1(0,255,0,255),
#define DIS_PLANT colour(55,55,55,55), fontcolour(50, 50, 50, 255), line(1), text("Disabled")
#define PLANT colour(40,40,40,255), fontcolour(160, 160, 160, 255), line(1)
#define ROOT colour(20,20,20,255)

form size(380, 368), caption("Solina Chorus"), pluginID("tslc"), $ROOT

groupbox bounds(10, 10, 360, 80), text("In/Out"), plant("io"), $PLANT {
  label bounds(10, 5, 120, 10), text("OL"), align("left"), $TEXT
  checkbox bounds(25, 5, 10, 10), channel("in-clip"), value(0), identchannel("in-clip-c"), popuptext("Input Overload"), $CLIP_CB
  label bounds(325, 5, 120, 10), text("OL"), align("left"), $TEXT
  checkbox bounds(340, 5, 10, 10), channel("clip"), value(0), identchannel("clip-c"), popuptext("Ouput Overload"), $CLIP_CB
  button bounds(70, 0, 60, 20), channel("test"), text("Test", "Testing..."), latched(1), value(0), visible(0). identchannel("test-c"), $TEST_BUTTON

  checkbox bounds(10, 25, 90, 25), channel("bypass"), text("---"), identchannel("bypass-c"), $GREEN_CB
  checkbox bounds(10, 52, 90, 25), channel("mono"), text("---"), identchannel("mono-c"), $RED_CB

  rslider bounds(208, 25, 50, 50), channel("gain"), range(-90, 30, 0, 2.5, 0.01), text("Gain"), identchannel("gain-c"), $GAIN_KNOB
  rslider bounds(256, 25, 50, 50), channel("drywet"), range(-1, 1, 1, 1, 0.01), text("Dry/Wet"), identchannel("drywet-c")  $DW_KNOB
  rslider bounds(304, 25, 50, 50), channel("balance"), range(-1, 1, 0, 1, 0.01), text("Balance"), $PAN_KNOB
}

groupbox bounds(10, 94, 360, 130), $DIS_PLANT
groupbox bounds(10, 228, 178, 130), $DIS_PLANT
groupbox bounds(192, 228, 178, 130), $DIS_PLANT

groupbox bounds(10, 94, 360, 130), text("Controls"), plant("lfo2"), identchannel("control-c"), $PLANT {
  rslider bounds(5, 30, 80, 80), channel("fscale"), range(.01, 20000, 1, .18), text("Freq Scale"), $EFF_KNOB
  rslider bounds(93, 30, 80, 80), channel("ascale"), range(.01, 100, 1, .5), text("Amp Scale"), $EFF_KNOB
   checkbox bounds(200, 85, 112, 25), channel("split"), text("---"), identchannel("split-c"), $GREEN_CB
}

groupbox bounds(10, 228, 178, 130), text("LFO 1"), plant("lfo1"), identchannel("lfo1-c"), $PLANT {
  rslider bounds(5, 30, 80, 80), channel("freq1"), range(.01, 1, .5), text("Freq"), $FILT_KNOB
  rslider bounds(93, 30, 80, 80), channel("amp1"), range(0, 1, .5), text("Amp"), $FILT_KNOB
}

groupbox bounds(192, 228, 178, 130), text("LFO 2"), plant("lfo2"), identchannel("lfo2-c"), $PLANT {
  rslider bounds(5, 30, 80, 80), channel("freq2"), range(.01, 1, .75), text("Freq"), $FILT_KNOB
  rslider bounds(93, 30, 80, 80), channel("amp2"), range(0, 1, .25), text("Amp"), $FILT_KNOB
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

; #define DEBUG #1#
#ifdef IS_A_PLUGIN
  #ifdef DEBUG
    #undef DEBUG
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

gi_solina_parabola ftgen 0, 0, 65537, 19, 0.5, 1, 180, 1 

;; 3 sine wave LFOs, 120 degrees out of phase
opcode sol_lfo_3, aaa, kkk
  kfreq, kamp, ksplit xin

  aphs1 phasor kfreq
  aphs2 phasor kfreq, .5

  ; smooth switch of ksplit to avoid clicks, using BYPASS macro
  ksplit port ksplit, .0825
  asplit interp ksplit
  aphs = $BYPASS(aphs2'aphs1'asplit)

  a0   = tablei:a(aphs, gi_solina_parabola, 1, 0, 1)
  a120 = tablei:a(aphs, gi_solina_parabola, 1, 0.333, 1)
  a240 = tablei:a(aphs, gi_solina_parabola, 1, -0.333, 1)

  xout (a0 * kamp), (a120 * kamp), (a240 * kamp)
endop

opcode solina_chorus_stereo, aa, aakkkkk

  aLeft, aRight, klfo_freq1, klfo_amp1, klfo_freq2, klfo_amp2, ksplit xin

  imax = 100

  ;; slow lfo
  as1, as2, as3 sol_lfo_3 klfo_freq1, klfo_amp1, 0

  ;; fast lfo
  af1, af2, af3  sol_lfo_3 klfo_freq2, klfo_amp2, 0

;; slow lfo
  asr1, asr2, asr3 sol_lfo_3 klfo_freq1, klfo_amp1, ksplit

  ;; fast lfo
  afr1, afr2, afr3  sol_lfo_3 klfo_freq2, klfo_amp2, ksplit

  at1 = limit(as1 + af1 + 5, 0.0, imax)
  at2 = limit(as2 + af2 + 5, 0.0, imax)
  at3 = limit(as3 + af3 + 5, 0.0, imax)

  atr1 = limit(asr1 + afr1 + 5, 0.0, imax)
  atr2 = limit(asr2 + afr2 + 5, 0.0, imax)
  atr3 = limit(asr3 + afr3 + 5, 0.0, imax)
    
  aL1 vdelay3 aLeft, at1, imax 
  aL2 vdelay3 aLeft, at2, imax 
  aL3 vdelay3 aLeft, at3, imax 

  aR1 vdelay3 aRight, atr1, imax 
  aR2 vdelay3 aRight, atr2, imax 
  aR3 vdelay3 aRight, atr3, imax 

xout (aL1 + aL2 + aL3) / 3, (aR1 + aR2 + aR3) / 3
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
kpostgain = ampdb(chnget:k("gain"))
kdrywet chnget "drywet"
kbalance chnget "balance"

kfscale chnget "fscale"
kascale chnget "ascale"
ksplit chnget "split"
kfreq1 = chnget:k("freq1")*kfscale
kfreq2 = chnget:k("freq2")*kfscale
kamp1 = chnget:k("amp1")*kascale
kamp2 = chnget:k("amp2")*kascale

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
  chnset Sbuf2, "lfo1-c"
  chnset Sbuf2, "lfo2-c"
  chnset Sbuf2, "drywet-c"
  chnset Sbuf2, "gain-c"
  chnset Sbuf2, "mono-c"
  chnset Sbuf2, "control-c"
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

; change mono/stereo effect text
if changed(ksplit)==1 then
  if (ksplit==1) then
    Sbuf strcpyk "text(\"Stereo Chorus\")"
  else
    Sbuf strcpyk "text(\"Mono Chorus\")"
  endif
  chnset Sbuf, "split-c"
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

; store for dry/wet
asrcL = asigL
asrcR = asigR

; check for and display input clipping
asigL, asigR, kclip quickclip asrcL, asrcR
if changed(kclip)==1 then
  chnset sprintfk("value(%d)", kclip==1 ? 1 : 0), "in-clip-c"
endif

asigL, asigR solina_chorus_stereo asigL, asigR, kfreq1, kamp1, kfreq2, kamp2, ksplit

; dry/wet balance snippet
asigL = $DRYWET(asrcL'asigL'kdrywet)
asigR = $DRYWET(asrcR'asigR'kdrywet)

; apply gain
asigL = asigL*kpostgain
asigR = asigR*kpostgain

; smooth bypass swap to avoid clicks
kbypass port kbypass, $PORT_TIME
abypass interp kbypass
asigL = $BYPASS(ainL'asigL'abypass)
asigR = $BYPASS(ainR'asigR'abypass)

; stereo balance snippet
abalL = $BALL(asigL'asigR'kbalance)
abalR = $BALR(asigL'asigR'kbalance)

; check for and display output clipping
asigL, asigR, kclip quickclip abalL, abalR
if changed(kclip)==1 then
  chnset sprintfk("value(%d)", kclip==1 ? 1 : 0), "clip-c"
endif

outs asigL, asigR
endin

</CsInstruments>  
<CsScore>
i1 0 z
</CsScore>
</CsoundSynthesizer>