PRO reformDivvy,fname
COMPILE_OPT strictarrsubs
ON_ERROR,0
str={id:0ULL,sdy:0B,shr:0B,smn:0B,ssc:0B,emo:0B,edy:0B,eyr:0S,ehr:0B,emn:0B,esc:0B,trips:0UL,bid:0UL,fid:0S,fname:'',tid:0S,tname:'',utype:'',gender:'',byr:0S,flat:0.,flon:0.,floc:'',tlat:0.,tlon:0.,tloc:''}

;cmdarr=['id=STRING(-1,FORMAT="(I02)")','tid=STRING(-1,FORMAT="(I02)")','smo=-1b & sdy=-1b & syr=-1s & shr=-1b & smn=-1b & ssc=-1b & sampm=STRING(-1,FORMAT="(I02)")','emo=-1b & edy=-1b & eyr=-1s & ehr=-1b & emn=-1b & esc=-1b & eampm=STRING(-1,FORMAT="(I02)")','trips=-1.','tripmi=-1.','ctpickup=0ull','ctdropoff=0ull','capickup=-1b','cadropoff=-1b','fare=-1.','tip=-1.','tolls=-1.','extras=-1.','ttotal=-1.','clatpickup=-1d0','clonpickup=-1d0','clocpickup=STRING(-1,FORMAT="(I02)")','clatdropoff=-1d0','clondropoff=-1d0','clocdropoff=STRING(-1,FORMAT="(I02)")']
;vararr=['id,','smo,sdy,syr,shr,smn,ssc,sampm,','emo,edy,eyr,ehr,emn,esc,eampm,','trips,','bid,','fid,','fname,','tid,','tname,','utype,','gender,','byr,','flat,','flon,','floc,','tlat,','tlon,','tloc,']
;formarr=['I,x,','I2,x,I2,x,I4,x,I2,x,I2,x,I2,x,A2,x,','I2,x,I2,x,I4,x,I2,x,I2,x,I2,x,A2,x,','I,','I,','I','A','I,','I,','A,','A,','A,','F,','F,','A,','F,','F,','A,']
cmdarr=["id=ULONG(strings[j-offset])", "READS,strings[j-offset],smo,sdy,syr,shr,smn,ssc,sampm,FORMAT='(I2,x,I2,x,I4,x,I2,x,I2,x,I2,x,A2)'", "READS,strings[j-offset],emo,edy,eyr,ehr,emn,esc,eampm,FORMAT='(I2,x,I2,x,I4,x,I2,x,I2,x,I2,x,A2)'", "bid=ULONG(strings[j-offset])", "trips=ULONG(strings[j-offset])", "ssta=FIX(strings[j-offset])", "sstaname=strings[j-offset]", "tsta=FIX(strings[j-offset])", "tstaname=strings[j-offset]", "utype=strings[j-offset]", "ugend=strings[j-offset]", "byr=FIX(strings[j-offset])", "flat=FLOAT(strings[j-offset])", "flon=FLOAT(strings[j-offset])", "floc=strings[j-offset]", "tlat=FLOAT(strings[j-offset])", "tlon=FLOAT(strings[j-offset])", "tloc=strings[j-offset]"]
cmdno=["id=0ULL", "READS,strings[1],smo,sdy,syr,shr,smn,ssc,sampm,FORMAT='(I2,x,I2,x,I4,x,I2,x,I2,x,I2,x,A2)'", "READS,strings[2],emo,edy,eyr,ehr,emn,esc,eampm,FORMAT='(I2,x,I2,x,I4,x,I2,x,I2,x,I2,x,A2)'", "bid=0ULL", "trips=0ULL", "ssta=-1S", "sstaname='NA'", "tsta=-1S", "tstaname='NA'", "utype='NA'", "ugend='NA'", "byr=FIX(-1)", "flat=-1.", "flon=-1.", "floc='NA'", "tlat=-1.", "tlon=-1.", "tloc='NA'"]
oneline=''

id=0L
smo=0B
sdy=0B
syr=0S
shr=0B
smn=0B
ssc=0B
sampm=''
emo=0B
edy=0B
eyr=0S
ehr=0B
emn=0B
esc=0B
eampm=''
bid=0UL
trips=0UL
ssta=0S
sstaname=''
tsta=0S
tstaname=''
utype=''
ugend=''
byr=0S
flat=0.
flon=0.
floc=''
tlat=0.
tlon=0.
tloc=''

OPENR,rlun,fname,/GET_LUN

lines=FILE_LINES(fname)

data=REPLICATE(str,lines-1)

READF,rlun,oneline

yrs=intarr(lines-1)
mos=bytarr(lines-1)


FOR i=0ULL,lines-2ULL DO BEGIN

  READF,rlun,oneline
  ;out=STRSPLIT(oneline,',',/EXTRACT)
  
  bline=oneline.toByte()
  wComma=WHERE(bline eq 44)
  wAdjr=wComma-SHIFT(wComma,1)

  IF bline[0] EQ 44 THEN wAdjr[0]=1
  IF bline[N_ELEMENTS(bline)-1] EQ 44 THEN wAdjr[N_ELEMENTS(wAdjr)-1]=1

  isAdj=WHERE(wAdjr EQ 1,COMPLEMENT=notAdj)
  IF wComma[0] EQ 0 THEN isAdj=[0,isAdj]
  IF wComma[16] EQ N_ELEMENTS(bline)-1 THEN isAdj=[isAdj,17]
  ;IF isAdj[0] EQ -1 THEN BEGIN
  ;  READS,oneline,id,smo,sdy,syr,shr,smn,ssc,sampm,emo,edy,eyr,ehr,emn,esc,eampm,bid,trips,ssta,sstaname,tsta,tstaname,utype,ugend,byr,flat,flon,floc,tlat,tlon,tloc,FORMAT='(I,I2,x,I2,x,I4,x,I2,x,I2,x,I2,x,A2,x,I2,x,I2,x,I4,x,I2,x,I2,x,I2,x,A2,x,I,I,A,I,A,A,I,F,F,A,F,F,A)'
  ;ENDIF
  
  strings=strsplit(oneline,',',/EXTRACT)
  
  IF N_ELEMENTS(strings) EQ N_ELEMENTS(wcomma)+1 THEN BEGIN
    IF N_ELEMENTS(strings) EQ 13 THEN STOP
  
    id=ULONG(strings[0])
    READS,strings[1],smo,sdy,syr,shr,smn,ssc,sampm,FORMAT='(I2,x,I2,x,I4,x,I2,x,I2,x,I2,x,A2)'
    READS,strings[2],emo,edy,eyr,ehr,emn,esc,eampm,FORMAT='(I2,x,I2,x,I4,x,I2,x,I2,x,I2,x,A2)'
    bid=ULONG(strings[3])
    trips=ULONG(strings[4])
    ssta=FIX(strings[5])
    sstaname=strings[6]
    tsta=FIX(strings[7])
    tstaname=strings[8]
    utype=strings[9]
    ugend=strings[10]
    byr=FIX(strings[11])
    flat=FLOAT(strings[12])
    flon=FLOAT(strings[13])
    floc=strings[14]
    tlat=FLOAT(strings[15])
    tlon=FLOAT(strings[16])
    tloc=strings[17]
    ;stop
  ENDIF ELSE BEGIN
    offset=0
    FOR j=0,17 DO BEGIN
      IF WHERE(j EQ isAdj) EQ -1 THEN BEGIN
        res=EXECUTE(cmdarr[j])
        ;stop
      ENDIF ELSE BEGIN
        ;stop
        res=EXECUTE(cmdno[j])
        offset++
      ENDELSE
    ENDFOR
  ENDELSE
  IF !error_state.code EQ -144 THEN STOP

  yrs[i]=syr
  mos[i]=smo
  str.id=id
  str.sdy=sdy
  IF sampm EQ 'PM' THEN str.shr=(shr MOD 12S)+12S ELSE str.shr=(shr MOD 12S)
  str.smn=smn
  str.ssc=ssc
  str.emo=emo
  str.edy=edy
  str.eyr=eyr
  IF eampm EQ 'PM' THEN str.ehr=(ehr MOD 12S)+12S ELSE str.ehr=(ehr MOD 12S)
  str.emn=emn
  str.esc=esc
  str.bid=bid
  str.trips=trips
  str.fid=ssta
  str.fname=sstaname
  str.tid=tsta
  str.tname=tstaname
  str.utype=utype
  str.gender=ugend
  str.byr=byr
  str.flat=flat
  str.flon=flon
  str.floc=floc
  str.tlat=tlat
  str.tlon=tlon
  str.tloc=tloc
  data[i]=str
  
ENDFOR

yrtime=yrs+mos/30.5+str.sdy/365.

tmin=MIN(yrtime,jmin)
tmax=MAX(yrtime,jmax)

yrmin=yrs[jmin]
momin=mos[jmin]

yrmax=yrs[jmax]
momax=mos[jmax]

nmonths=(yrmax-yrmin-1)*12.+(12.-momin+1)+momax

years=yrmin+FIX((momin+indgen(nmonths)-1)/12)
months=FIX(((momin+indgen(nmonths)-1) MOD 12)+1)

FOR i=0,nmonths-1 DO BEGIN
  ;STOP
  yr=yrmin+FIX((momin+i-1)/12)
  mo=FIX(((momin+i-1) MOD 12)+1)
  thisTime=WHERE(yrs EQ yr AND mos EQ mo)
  nTimes=N_ELEMENTS(thisTime)
  dvname=STRING(yr,FORMAT='(I04)')+STRING(mo,FORMAT='(I02)')+'Divvy.dat'
  OPENW,wlun,dvname,/GET_LUN
  WRITEU,wlun,yr,mo,nTimes
  WRITEU,wlun,data[thisTime]
  FREE_LUN,wlun

ENDFOR

END