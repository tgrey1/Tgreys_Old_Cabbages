<Cabbage>
;
; DTMFdialer.csd by Kevin Welsh (tgrey)
; version 1.0 - Oct.20 2015
;
; keypad DTMF dialer including A B C & D control tones, dial tone,
; ringback, busy, and reorder signals, and an autodialer.  Currently
; only generates US tones, but who knows for the future.
;
; "Pass Audio" lets all audio coming in pass through unchanged, so
; the dialer can be inserted as an effect on adio channels and be used in
; parallel.  "Send dB" and "Pan" only affect generated audio.
;
; Dialtone turns off when any key is pressed, or response is started.
; Response turns off when dialtone is started.
; Any keypress interruptx response audio.
;
; Autodialer takes in text, hit enter to start dialing.  Accepted input includes
; 0-9: number pad
; * s S: star button
; # p P: pound button
; a-d A-D: control buttons
; any other text input will be ignored and create spaces in the dialed numbers.
;
; KNOWN BUG: autodialer does not work exported as an effect
;

#define TEXTBOX_COLOR colour(60,60,60,240), fontcolour(160, 160, 160, 255)
#define KEYPAD_COLOR colour:0(90, 90, 90, 255), colour:1(60, 60, 60, 255), fontcolour:0(180,180,180,255), fontcolour:1(255, 255, 255, 255)
#define BUTTON_COLOR colour:0(60, 60, 60, 255), colour:1(90, 90, 90, 255), fontcolour:0(180,180,180,255), fontcolour:1(150, 255, 150, 255)

#define AUTO_CHECKBOX_COLOR shape("circle"), colour:0(0,25,0,255), colour:1(0,255,0,255)
#define RESP_CHECKBOX_COLOR shape("circle"), colour:0(25,0,0,255), colour:1(255,0,0,255)

form size(504, 384), caption("DTMF Dialer"), pluginID("dtmf")


groupbox bounds(10, 10, 484, 80), text("In / Out"), line(1) plant("io") {
  button bounds(100, 2, 50, 15), channel("testR"), text("Test R","ON"), latched("0"), colour:0(30, 30, 30, 255), colour:1(60, 60, 60, 255), fontcolour:0(160, 160, 160, 255), fontcolour:1(0, 255, 0, 255), value(0), visible(0), identchannel("testr-c")
  button bounds(46, 2, 50, 15), channel("testL"), text("Test L","ON"), latched("0"), colour:0(30, 30, 30, 255), colour:1(60, 60, 60, 255),fontcolour:0(160, 160, 160, 255), fontcolour:1(0, 255, 0, 255), value(0), visible(0), identchannel("testl-c")
  button bounds(230, 2, 60, 15), channel("testSt"), text("Test St","TESTING"), latched("1"), colour:0(30, 30, 30, 255), colour:1(60, 60, 60, 255),fontcolour:0(160, 160, 160, 255), fontcolour:1(0, 255, 0, 255), value(0), visible(0), identchannel("tests-c")

  label bounds(10, 5, 120, 10), text("OL"), align("left"),  colour(0, 0, 0, 0), fontcolour(160, 160, 160, 255),
  checkbox bounds(25, 5, 10, 10), channel("in-clip"), shape("square"), colour:0(25,0,0,255), colour:1(255,0,0,255), value(0), identchannel("in-clip-c"), active(0)

  label bounds(449, 5, 120, 10), text("OL"), align("left"),  colour(0, 0, 0, 0), fontcolour(160, 160, 160, 255),
  checkbox bounds(464, 5, 10, 10), channel("clip"), shape("square"), colour:0(25,0,0,255), colour:1(255,0,0,255), value(0), identchannel("clip-c"), active(0)

  checkbox bounds(10, 35, 95, 25), channel("pass"), shape("circle"), colour:0(0, 25, 0, 255), colour:1(0,255,0,255), fontcolour(160, 160, 160, 255), text("---"), identchannel("pass-c")

  rslider bounds(374, 25, 50, 50), channel("send"), range(-90, 30, -3, 2.5, 0.01), text("Send dB"),  colour(255, 0, 0, 160), trackercolour(0, 255, 0, 255), fontcolour(160, 160, 160, 255),
  rslider bounds(424, 25, 50, 50), channel("pan"), range(-1, 1, 0, 1, 0.01), text("Pan"),  colour(125, 125, 125, 255), trackercolour(0, 255, 0, 255), fontcolour(160, 160, 160, 255),
}

groupbox bounds(10, 94, 240, 280), text("Keypad"), line(1) plant("dialer") {
  button bounds(10, 30, 230, 30), channel("dialtone"), text("Dial Tone", "Dial Tone"), latched(1), $BUTTON_COLOR

  button bounds(10, 70, 50, 50), channel("1"), text("1", "1"), latched(0), $KEYPAD_COLOR
  button bounds(60, 70, 50, 50), channel("2"), text("2", "2"), latched(0), $KEYPAD_COLOR
  button bounds(110, 70, 50, 50), channel("3"), text("3", "3"), latched(0), $KEYPAD_COLOR
  button bounds(180, 70, 50, 50), channel("A"), text("A", "A"), latched(0), $KEYPAD_COLOR

  button bounds(10, 120, 50, 50), channel("4"), text("4", "4"), latched(0), $KEYPAD_COLOR
  button bounds(60, 120, 50, 50), channel("5"), text("5", "5"), latched(0), $KEYPAD_COLOR
  button bounds(110, 120, 50, 50), channel("6"), text("6", "6"), latched(0), $KEYPAD_COLOR
  button bounds(180, 120, 50, 50), channel("B"), text("B", "B"), latched(0), $KEYPAD_COLOR

  button bounds(10, 170, 50, 50), channel("7"), text("7", "7"), latched(0), $KEYPAD_COLOR
  button bounds(60, 170, 50, 50), channel("8"), text("8", "8"), latched(0), $KEYPAD_COLOR
  button bounds(110, 170, 50, 50), channel("9"), text("9", "9"), latched(0), $KEYPAD_COLOR
  button bounds(180, 170, 50, 50), channel("C"), text("C", "C"), latched(0), $KEYPAD_COLOR

  button bounds(10, 220, 50, 50), channel("*"), text("*", "*"), latched(0), $KEYPAD_COLOR
  button bounds(60, 220, 50, 50), channel("0"), text("0", "0"), latched(0), $KEYPAD_COLOR
  button bounds(110, 220, 50, 50), channel("#"), text("#", "#"), latched(0), $KEYPAD_COLOR
  button bounds(180, 220, 50, 50), channel("D"), text("D", "D"), latched(0), $KEYPAD_COLOR, identchannel("test")
}

groupbox bounds(254, 94, 240, 187), text("Autodial"), line(1) plant("autodial") {
  texteditor bounds(10, 30, 220, 20), channel("number"), identchannel("number-c"), $TEXTBOX_COLOR
  nslider bounds(10, 60, 105, 20), range(20,2000,50,1,1), channel("length"), $TEXTBOX_COLOR
  nslider bounds(125, 60, 105, 20), range(20,2000,50,1,1), channel("space"), $TEXTBOX_COLOR

  label bounds(10, 80, 105, 12), text("Length [ms]"), align("centre")
  label bounds(125, 80, 105, 12), text("Pause [ms]"), align("centre")

  nslider bounds(10, 100, 105, 20), range(200,5000,1000,1,1), channel("dtlength"), $TEXTBOX_COLOR
  nslider bounds(125, 100, 105, 20), range(200,5000,1000,1,1), channel("respondwait"), $TEXTBOX_COLOR

  label bounds(10, 120, 105, 12), text("Dialtone [ms]"), align("centre")
  label bounds(125, 120, 105, 12), text("Rspnd wait [ms]"), align("centre")
  checkbox bounds(10, 140, 158, 20), channel("autodt"), text("Dialtone before dialing"), latched(1), value(0), $AUTO_CHECKBOX_COLOR
  checkbox bounds(10, 162, 149, 20), channel("autorespond"), text("Respond after dialing"), latched(1), value(0), $AUTO_CHECKBOX_COLOR

}

groupbox bounds(254, 285, 240, 89), text("Response"), line(1) plant("response") {
  checkbox bounds(10, 25, 75, 20), channel("ring"), text("Ring", "Ring"), latched(1), radiogroup(1), value(1), $RESP_CHECKBOX_COLOR
  checkbox bounds(85, 25, 75, 20), channel("busy"), text("Busy", "Busy"), latched(1), radiogroup(1), $RESP_CHECKBOX_COLOR
  checkbox bounds(160, 25, 75, 20), channel("reorder"), text("Reorder", "Reorder"), radiogroup(1), latched(1), $RESP_CHECKBOX_COLOR
  button bounds(10, 50, 230, 30), channel("respond"), text("Respond", "Responding"), latched(1), $BUTTON_COLOR
}
;label bounds(10, 370, 451, 26), text("---"), align("left"), colour(160, 0, 0, 255), identchannel("debug")
</Cabbage>
<CsoundSynthesizer>
<CsOptions>
-n -d
</CsOptions>
<CsInstruments>
sr = 44100
ksmps = 10
nchnls = 2
0dbfs=1
#define CLIP_LEV #1#
#define PORT_TIME #.001#
#define DTF1 #350#
#define DTF2 #440#
#define ZERO #10#
#define STAR #11#
#define POUND #12#
#define A #13#
#define B #14#
#define C #15#
#define D #16# 
#define DIALTONE #17#

#define FA #1209#
#define FB #1336#
#define FC #1477#
#define FD #1633#

#define F1 #697#
#define F2 #770#
#define F3 #852#
#define F4 #941#

#define R_RING #1#
#define R_BUSY #2#
#define R_REORDER #3#

#define PANL(s'p) #$s*min(abs($p-1),1)#
#define PANR(s'p) #$s*min(abs($p+1),1)#

gasig init 0
gkpad init 0


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

  asigL clip asigL, 2, icliplev
  asigR clip asigR, 2, icliplev
  asigL limit asigL, -1*icliplev, icliplev
  asigR limit asigR, -1*icliplev, icliplev

  xout asigL, asigR, kclip
endop


; keypad/UI listener, outputs accumulated sound from global asig
instr 1
asrcL inch 1
asrcR inch 2

; check for and display input clipping
asrcL, asrcR, kclip quickclip asrcL, asrcR
if changed(kclip)==1 then
  chnset sprintfk("value(%d)", kclip==1 ? 1 : 0), "in-clip-c"
endif

k1 chnget "1"
k2 chnget "2"
k3 chnget "3"
k4 chnget "4"
k5 chnget "5"
k6 chnget "6"
k7 chnget "7"
k8 chnget "8"
k9 chnget "9"
k0 chnget "0"
kstar chnget "*"
kpound chnget "#"
kA chnget "A"
kB chnget "B"
kC chnget "C"
kD chnget "D"
kdt chnget "dialtone"
kpass chnget "pass"
krespond chnget "respond"
kpan chnget "pan"
ksend chnget "send"
ksend ampdb ksend
Snumber chnget "number"

kpressed init -99

if changed(kpass)==1 then
  if (kpass==1) then
    Sbuf strcpyk "text(\"Audio on\")"
  else
    Sbuf strcpyk "text(\"Pass Audio\")"
  endif
  chnset Sbuf, "pass-c"
endif

if changed(k1, k2, k3, k4, k5, k6, k7, k8, k9, k0, kstar, kpound, kA, kB, kC, kD, kdt)==1 then
  if (k1==1) then
    kpressed=1
  elseif (k2==1) then
    kpressed=2
  elseif (k3==1) then
    kpressed=3
  elseif (k4==1) then
    kpressed=4
  elseif (k5==1) then
    kpressed=5
  elseif (k6==1) then
    kpressed=6
  elseif (k7==1) then
    kpressed=7
  elseif (k8==1) then
    kpressed=8
  elseif (k9==1) then
    kpressed=9
  elseif (k0==1) then
    kpressed=$ZERO
  elseif (kstar==1) then
    kpressed=$STAR
  elseif (kpound==1) then
    kpressed=$POUND
  elseif (kA==1) then
    kpressed=$A
  elseif (kB==1) then
    kpressed=$B
  elseif (kC==1) then
    kpressed=$C
  elseif (kD==1) then
    kpressed=$D
  elseif (kdt==1) then
    kpressed=$DIALTONE
  elseif (kpressed!=-99) then
    kpressed=-1*kpressed
  endif
endif

if changed(Snumber)==1 then
  if(strlenk(Snumber)>0) then
    event "i", 2, 0, 1
  endif
endif

if changed(kpressed)==1 then
  if (kpressed!=$DIALTONE) && (kdt==1) then
    ; turn off dialtone if anything else was pressed
    chnset k(0), "dialtone"
    turnoff2 3, 0, 1
  endif
  if (kpressed==$DIALTONE) then
    ; turn off response if dialtone was pressed
    chnset k(0), "respond"
  endif
  ; make a fractional instrument number
  kinst=3+(abs(kpressed)*.01)
  if(kpressed>0) then
    event "i", kinst, 0, -1, kpressed
  elseif (kpressed!=-99) then
    event "i", -kinst, 0, -1, kpressed
  endif
endif

if changed(krespond)==1 then
  if(krespond>0) then
    event "i", 4, 0, -1
  else
    event "i", -4, 0, -1
  endif
endif

asigL = $PANL(gasig'kpan)
asigR = $PANR(gasig'kpan)

asigL = asigL * ksend
asigR = asigR * ksend
if (kpass==1) then
  asigL=asrcL+asigL
  asigR=asrcR+asigR
endif

; check for and display output clipping
asrcL, asrcR, kclip quickclip asigL, asigR
if changed(kclip)==1 then
  chnset sprintfk("value(%d)", kclip==1 ? 1 : 0), "clip-c"
endif
outs asrcL, asrcR

gasig = 0
endin

; auto dialer parser
instr 2
  Snumber chnget "number"
  ilen chnget "length"
  ispace chnget "space"
  idtlen chnget "dtlength"
  irespondwait chnget "respondwait"
  iautodt chnget "autodt"
  iautorespond chnget "autorespond"
  
  ilen=ilen*.001
  ispace=ispace*.001
  idtlen=idtlen*.001
  irespondwait=irespondwait*.001

  ; length of string
  istrlen strlen Snumber
  ; length needed for dialing numbers
  idur = ilen*istrlen+(ispace*(istrlen-1))
  ; set duration to idur and time needed for dialtone and response wait
  p3 = (idtlen*iautodt)+idur+(irespondwait*iautorespond)
  
  if (iautodt==1) then
    chnset 1, "dialtone"
  endif
  
  ipnt=0
  itime = (iautodt==1) ? idtlen : 0

  loop:
    ichar strchar Snumber, ipnt
    event_i "i", 3, itime, ilen, ichar
    itime=itime+ilen+ispace
  loop_lt ipnt, 1, istrlen, loop  
  chnset "", "number"
  if release()==1 && (iautorespond==1) then
    chnset k(1), "respond"
  endif
endin

; keypad & dialtone signal generator
instr 3
  idur = abs(p3)
  inum = int(p4)
  ksend chnget "send"
  ksend ampdb ksend

  if(inum>=48) && (inum<=57) then
    ; ascii numbers slide over, 0 becomes 10
    inum = inum==48 ? 10 : inum-48
  elseif (inum>=97) && (inum<=100) then
    ; a-d
    inum = inum-84
  elseif (inum>=65) && (inum<=68) then
    ; A-D
    inum = inum-52
  elseif (inum==42) || (inum==83) || (inum==115 ) then
    ; * s or S for star
    inum = $STAR
  elseif (inum==35) || (inum==80) || (inum==112) then
    ; # p or P for pound
    inum = $POUND
  endif
     
;  chnset sprintfk("text(dialing: %d)",inum),"debug"
  if (inum<1) || ((inum>$D) && (inum!=$DIALTONE)) then
    kgoto skip
  endif

  if (inum==$DIALTONE) then
    ifreq1=$DTF1
    ifreq2=$DTF2
  else
    chnset k(0), "dialtone"
    event_i "i", -1*(3+($DIALTONE*.001)), 0, -1, 1
  if (inum==1) || (inum==2) || (inum==3) || (inum==$A) then
    ifreq1=$F1
  elseif (inum==4) || (inum==5) || (inum==6) || (inum==$B) then
    ifreq1=$F2
  elseif (inum==7) || (inum==8) || (inum==9) || (inum==$C) then
    ifreq1=$F3
  else
    ifreq1=$F4
  endif

  if (inum==1) || (inum==4) || (inum==7) || (inum==$STAR) then
    ifreq2=$FA
  elseif (inum==2) || (inum==5) || (inum==8) || (inum==$ZERO) then
    ifreq2=$FB
  elseif  (inum==3) || (inum==6) || (inum==9) || (inum==$POUND) then
    ifreq2=$FC
  else
    ifreq2=$FD
  endif
  endif
  iatt = .005
  aenv linsegr 0, iatt, .5, idur-iatt, .5, iatt, 0
  asig1 oscil aenv, ifreq1, 1
  asig2 oscil aenv, ifreq2, 1

  gasig = gasig+(asig1+asig2)
  krel release
  if (krel==1) then
    gkpad=0
  else
    gkpad=1
  endif
  skip:
endin

; response tone signal generator
instr 4
  kring chnget "ring"
  kbusy chnget "busy"
  kreorder chnget "reorder"
  ksend chnget "send"
  ksend ampdb ksend
  
  chnset 0, "dialtone"
  event_i "i", -1*(3+($DIALTONE*.001)), 0, -1, 1


  kmode = (kring==1) ? $R_RING : (kbusy==1) ? $R_BUSY : $R_REORDER
  if(kmode==$R_RING) then
    kfreq1=440
    kfreq2=480
    kenvf=1/6
  elseif (kmode==$R_BUSY) then
    kfreq1=480
    kfreq2=620
    kenvf=1
  else
    kfreq1=480
    kfreq2=620
    kenvf=2
  endif
    
  kenvring oscil .5, kenvf, 3
  kenv oscil .5, kenvf, 2
  kenv = (kmode==$R_RING) ? kenvring : kenv
  kenv = kenv*abs(gkpad-1)
  #ifdef $PORT_TIME
    kenv port kenv, $PORT_TIME
    aenv interp kenv
  #else
    aenv=a(kenv)
  #endif

  iatt = .005
  aenv2 linsegr 0, iatt, 1, p3-iatt, 1, iatt, 0

  asig2 oscil aenv*aenv2, kfreq1, 1
  asig1 oscil aenv*aenv2, kfreq2, 1

  gasig = gasig+(asig1+asig2)
endin

</CsInstruments>  
<CsScore>
f1 0 1024 10 1
; square for even spaced envelope
f2 0 1024 7 1 512 1 0 0 512 0
; 33% duty pulse for ring envelope
f3 0 1024 7 1 341 1 0 0 683 0
i1 0 [ 60*60*24*7*4 ]
</CsScore>
</CsoundSynthesizer>
