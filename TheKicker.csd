<Cabbage>
;
; TheKicker.csd by Kevin Welsh (tgrey)
; version 1.2 - Nov. 4 2015
;
; Simple 808 kick synth with a few tweaks.
;
; Original code was borrowed from an 808 kit
; synth, original source forgotten... an older
; version of Iain's perhaps?  I know it's not
; based off his current version.  I didn't plan
; to release this originally or I would have
; made a note of the author, my apologies.
; Added a bunch of tweaks to the original which
; allows for more variety of timbres.
;
; "Type" chooses between a more rich 808
; kick wave, or a simple sine.
;
; "Port Amnt" sets the amount of portamento
; in octaves, ranging from +3 to -3.
;
; "Port Speed" sets how fast the pitch shifts
; to the main frequency.
;
; "L/R Spread" sets phase difference between
; left and right channels, creating a stereo
; effect.
;
; Attack Decay and Release control the amp
; envelope.  Release time only occurs if
; decay time hasn't been filled.  Typically
; a long decay time and a shorter release
; time would be used, allowing sustained
; notes and stacatto notes as needed.
;
; v 1.2:
; updated quickclip UDO
; converted to stereo channels
; added L/R spread control
; added balance control
; fixed centering note of keyboard

#define CLIP_CB colour:0(25, 0, 0, 255), colour:1(255,0,0,255), fontcolour(160, 160, 160, 255), active(0), shape("square"),
#define GAIN_KNOB colour(255, 0, 0, 160), trackercolour(0, 255, 0, 255), fontcolour(160, 160, 160, 255),
#define DW_KNOB colour(0, 95, 255, 255), trackercolour(0, 255, 0, 255), fontcolour(160, 160, 160, 255),
#define PAN_KNOB colour(125, 125, 125, 255), trackercolour(0, 255, 0, 255), fontcolour(160, 160, 160, 255),
#define EFF_KNOB colour(0,255,0,160), trackercolour(0, 255, 0, 255), fontcolour(160, 160, 160, 255),
#define TEXT colour(0,0,0,0), fontcolour(160, 160, 160, 255),
#define COMBO colour(30,30,30,255), fontcolour(160, 160, 160, 255),
#define PLANT colour(40,40,40,255), fontcolour(160, 160, 160, 255), line(1)
#define ROOT colour(20,20,20,255)

form size(668, 210), caption("The Kicker"), pluginID("tkck"), $ROOT

groupbox bounds(10, 10, 300, 100), text("Oscil"), plant("pitch"), $PLANT { 
label bounds(5,25,50,15),text("Type:"), $TEXT

combobox bounds(5, 45, 90, 30), channel("ft"), items("808 Kick", "Pure Sine"), $COMBO
  rslider bounds(100, 25, 65, 65), channel("pchamt"), range(-3, 3, 1, 1, 0.01), text("Port Amnt"), $EFF_KNOB 
  rslider bounds(167, 25, 65, 65), channel("speed"), range(0, 1, .98, 1.75, 0.01), text("Port Speed"), $EFF_KNOB
  rslider bounds(230, 25, 65, 65), channel("spread"), range(0, 1, 0, 1, 0.01), text("L/R Spread"), $EFF_KNOB 

},

groupbox bounds(314, 10, 195, 100), text("Envelope"), plant("env"), $PLANT {
  rslider bounds(0, 25, 65, 65), channel("att"), range(.001, 10, .01, .5, 0.001), text("Attack"), $DW_KNOB 
  rslider bounds(65, 25, 65, 65), channel("dec"), range(.01, 10, 2.6, .5, 0.01), text("Decay"), $DW_KNOB 
  rslider bounds(130, 25, 65, 65), channel("rel"), range(.01, 10, .3, .5, 0.01), text("Release"), $DW_KNOB
},

groupbox bounds(513, 10, 130, 100), text("Out"), plant("out"), $PLANT {
  label bounds(95, 5, 120, 10), text("OL"), align("left"), $TEXT
  checkbox bounds(110, 5, 10, 10), channel("clip"), value(0), identchannel("clip-c"), $CLIP_CB
  rslider bounds(0, 25, 65, 65), channel("level"), range(-90,30, -3, 2.5, 0.01), text("Level dB"), $GAIN_KNOB 
    rslider bounds(65, 25, 65, 65), channel("balance"), range(-1, 1, 0, 1, 0.01), text("Balance"), $PAN_KNOB
},
;label bounds(0,0,300,20),text("---"), identchannel("debug")

keyboard bounds(10, 120, 633, 80), value(34)
</Cabbage>
<CsoundSynthesizer>
<CsOptions>
-n -d -+rtmidi=NULL -M0 --midi-key-cps=4 --midi-velocity-amp=5
</CsOptions>
<CsInstruments>
sr = 44100
ksmps = 64
nchnls = 2
0dbfs=1

#define PANL(s'p) #($s*abs(($p-1)*.5 ))# 
#define PANR(s'p) #($s*abs(($p+1)*.5))#
#define BALL(sl'sr'b) #$PANL($sl'$b)+($sr*max(0,($b*-.5)))#
#define BALR(sl'sr'b) #$PANR($sr'$b)+($sl*max(0,($b*.5)))#

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

; init non 0 widgets just in case
chnset 1, "pchamt"
chnset .98, "speed"
chnset 2.6, "dec"
chnset .01, "att"
chnset .3, "rel"
chnset -3, "level"
chnset 1, "ft"

instr	1
  iattack chnget "att"
  idecay = chnget("dec")*2 ; scale out idur a little
  irel chnget "rel"
  ipchamt chnget "pchamt"
  klevel = ampdb(chnget:k("level"))
  ift chnget "ft"
  ispread = chnget("spread")*.25
  kbalance chnget "balance"
  ; amount of time for portamento	
  iport = .006+((1-chnget("speed"))*.3)
  ; scale down base freq, want bass drums near middle c
  ifrq2	= p4 * .125
  ; derive starting freq for portamento, scale +/- X to +/- octaves
  ifrq1 = ipchamt>=0 ? ifrq2*(2^ipchamt) : ifrq2*(1/(2^abs(ipchamt)))
  ; create pitch envelope
  afrq	expsega	ifrq1,iport,ifrq2,idecay,ifrq2
  ; create amp envelope
  aenv	mxadsr iattack, idecay, .00001, irel, .00001
  ; oscil
  asigL	poscil	aenv, afrq, ift
  asigR	poscil	aenv, afrq, ift, ispread
  ; mix in velocity and output level
  asigL = asigL*p5*klevel
  asigR = asigR*p5*klevel
  ; check for and display output clipping
  asigL, asigR, kclip quickclip asigL, asigR
  if changed(kclip)==1 then
    chnset sprintfk("value(%d)", kclip==1 ? 1 : 0), "clip-c"
  endif
  
  aoutL = $BALL(asigL'asigR'kbalance)
  aoutR = $BALR(asigL'asigR'kbalance)
  
  outs aoutL,aoutR
endin
</CsInstruments>  
<CsScore>
; 808 table
f1 0 1024 9 1 .8 0 2 1 0
; sine table
f2 0 1024 10 1
f0 [ 60*60*24*7*4 ]
</CsScore>
</CsoundSynthesizer>