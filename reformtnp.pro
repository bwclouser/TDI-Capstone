PRO reformTNP,index,fname,num

t0=SYSTIME(1)

;str={num:0ull,pos:0ll,yr:0,mo:0b,dy:0b}
;dat=REPLICATE(str,num)
;bad=[18724701ULL,25919077ULL,28577856ULL,28970783ULL]
bad=[0ull]
stro={id:0ull,sdy:0b,shr:0b,smn:0b,eyr:fix(0),emo:0b,edy:0b,ehr:0b,emn:0b,trips:0ul,tripmi:0.,ctpickup:0ull,ctdropoff:0ull,capickup:0b,cadropoff:0b,fare:0.,tip:0.,addcharge:0.,ttotal:0.,stauth:0b,tppool:0b,clatpickup:0d0,clonpickup:0d0,clatdropoff:0d0,clondropoff:0d0}


;plist=['id','smo','sdy','syr','smn','ssc','sampm','emo','edy','eyr','ehr','emn','esc','eampm','trips','tripmi','ctpickup','ctdropoff','capickup','cadropoff','fare','tip','addcharge','ttotal','tppool','clatpickup','clonpickup','clocpickup','clatdropoff','clondropoff','clocdropoff']
;pform=['A40,x,','I2,x,','I2,x,','I4,x,','I2,x,','I2,x,','I2,x,','A2,x,','I2,x,','I2,x,','I4,x,','I2,x,','I2,x,','I2,x,','A2,x,','F,x,','F,x,','I11,x,','I11,x,','I,x,','I,x,','F,x,','F,x,','F,x,','F,x,','I,x,','F,x,','F,x,','A36,x,','F,x,','F,x,','A36']

cmdarr=['id=STRING(-1,FORMAT="(I02)")','smo=-1b & sdy=-1b & syr=-1s & shr=-1b & smn=-1b & ssc=-1b & sampm=STRING(-1,FORMAT="(I02)")','emo=-1b & edy=-1b & eyr=-1s & ehr=-1b & emn=-1b & esc=-1b & eampm=STRING(-1,FORMAT="(I02)")','trips=-1.','tripmi=-1.','ctpickup=0ull','ctdropoff=0ull','capickup=-1b','cadropoff=-1b','fare=-1.','tip=-1.','addcharge=-1.','ttotal=-1.','tppool=-1b','clatpickup=-1d0','clonpickup=-1d0','clocpickup=STRING(-1,FORMAT="(I02)")','clatdropoff=-1d0','clondropoff=-1d0','clocdropoff=STRING(-1,FORMAT="(I02)")']
vararr=['id,','smo,sdy,syr,shr,smn,ssc,sampm,','emo,edy,eyr,ehr,emn,esc,eampm,','trips,','tripmi,','ctpickup,','ctdropoff,','capickup,','cadropoff,','fare,','tip,','addcharge,','ttotal,','tppool,','clatpickup,','clonpickup,','clocpickup,','clatdropoff,','clondropoff,','clocdropoff,']
formarr=['A40,x,','I2,x,I2,x,I4,x,I2,x,I2,x,I2,x,A2,x,','I2,x,I2,x,I4,x,I2,x,I2,x,I2,x,A2,x,','F,','F,','I11,x,','I11,x,','I,','I,','F,','F,','F','F','I,','F,','F,','A36,x,','F,','F,','A36']


id=''
smo=0
sdy=0
syr=0
shr=0
smn=0
ssc=0
sampm=''
emo=0
edy=0
eyr=0
ehr=0
emn=0
esc=0
eampm=''
trips=0ul
tripmi=0.
ctpickup=0ull
ctdropoff=0ull
capickup=0
cadropoff=0
fare=0.
tip=0.
addcharge=0.
ttotal=0.
stauth=0
tppool=0
clatpickup=0d0
clonpickup=0d0
clocpickup=''
clatdropoff=0d0
clondropoff=0d0
clocdropoff=''

;OPENR,ilun,indname,/GET_LUN
;FOR i=0ull,215037931ull DO BEGIN
;  READU,ilun,str
;  dat[i]=str
;ENDFOR
;FREE_LUN,ilun

yrtime=index.yr+index.mo/30.5+index.dy/365.

tmin=MIN(yrtime,jmin)
tmax=MAX(yrtime,jmax)

yrmin=index[jmin].yr
momin=index[jmin].mo

yrmax=index[jmax].yr
momax=index[jmax].mo

nmonths=(yrmax-yrmin-1)*12.+(12.-momin+1)+momax

oneline=''

OPENR,rlun,fname,/GET_LUN

FOR i=10,nmonths-1 DO BEGIN
  yr=yrmin+FIX((momin+i-1)/12)
  mo=FIX(((momin+i-1) MOD 12)+1)
  wfname=STRING(yr,FORMAT='(I04)')+STRING(mo,FORMAT='(I02)')+'TNP.dat'
  OPENW,wlun,wfname,/GET_LUN
  thisTime=WHERE(index.yr EQ yr AND index.mo EQ mo)
  nTimes=N_ELEMENTS(thisTime)
  ;stop
  WRITEU,wlun,yr,mo,nTimes
  
  FOR j=0l,nTimes-1 DO BEGIN
    isBad=WHERE(index[thisTime[j]].num eq bad)
    IF isBad[0] EQ -1 THEN BEGIN
      POINT_LUN,rlun,index[thisTime[j]].pos
      READF,rlun,oneline
      IF oneline.CONTAINS('true,') THEN BEGIN
        stauth=1b
        oneline=oneline.REPLACE('true,','')
      ENDIF ELSE BEGIN
        stauth=0b
        oneline=oneline.REPLACE('false,','')
      ENDELSE
      bline=oneline.toByte()
      wComma=WHERE(bline eq 44)
      wAdjr=wComma-SHIFT(wComma,1)
  
      IF bline[0] EQ 44 THEN wAdjr[0]=1
      IF bline[N_ELEMENTS(bline)-1] EQ 44 THEN wAdjr[N_ELEMENTS(wAdjr)-1]=1
  
      f1=STRING(wAdjr[11]-1,FORMAT='(I02)')
      f2=STRING(wAdjr[12]-1,FORMAT='(I02)') 
      toAdd=',F'+f1+',x,F'+f2+',x'
  
      isAdj=WHERE(wAdjr EQ 1,COMPLEMENT=notAdj)
      IF isAdj[0] EQ -1 THEN BEGIN
        cmd0='READS,oneline,id,smo,sdy,syr,shr,smn,ssc,sampm,emo,edy,eyr,ehr,emn,esc,eampm,trips,tripmi,ctpickup,ctdropoff,capickup,cadropoff,fare,tip,addcharge,ttotal,tppool,clatpickup,clonpickup,clocpickup,clatdropoff,clondropoff,clocdropoff,FORMAT="(A40,x,I2,x,I2,x,I4,x,I2,x,I2,x,I2,x,A2,x,I2,x,I2,x,I4,x,I2,x,I2,x,I2,x,A2,x,2F,I11,x,I11,x,2I,2F'
        cmd1=',I,F,F,A36,x,F,F,A36)"'
        cmd=cmd0+toAdd+cmd1
        res=EXECUTE(cmd)
        ;stop      ;
      ENDIF ELSE BEGIN
  
        cmd='READS,oneline,'
        FOR k=0,N_ELEMENTS(cmdarr)-1 DO BEGIN
          kWh=WHERE(k EQ isAdj)
          IF kWh[0] EQ -1 THEN BEGIN
            cmd+=vararr[k]
          ENDIF ELSE BEGIN
            res=EXECUTE(cmdarr[k])
          ENDELSE
        ENDFOR
        cmd+="FORMAT='("
        FOR k=0,N_ELEMENTS(formarr)-1 DO BEGIN
        kWh=WHERE(k EQ isAdj)
          IF kWh[0] EQ -1 THEN BEGIN
            cmd+=formarr[k]
            IF k EQ 11 THEN cmd+=(f1+',x,')
            IF k EQ 12 THEN cmd+=(f2+',x,')
          ENDIF ELSE BEGIN
            cmd+='x,'
          ENDELSE
        ENDFOR
        cmd+=")'"
        res=EXECUTE(cmd)
        ;stop
      ENDELSE  
      ;  
      stro.id=index[thisTime[j]].num
      stro.sdy=sdy
      IF sampm EQ 'PM' THEN stro.shr=shr+12s ELSE stro.shr=shr
      stro.smn=smn
      stro.eyr=eyr
      stro.emo=emo
      stro.edy=edy
      IF eampm EQ 'PM' THEN stro.ehr=ehr+12s ELSE stro.ehr=ehr
      stro.emn=emn
      stro.trips=trips
      stro.tripmi=tripmi
      stro.ctpickup=ctpickup
      stro.ctdropoff=ctdropoff
      stro.capickup=capickup
      stro.cadropoff=cadropoff
      stro.fare=fare
      stro.tip=tip
      stro.addcharge=addcharge
      stro.ttotal=ttotal
      stro.stauth=stauth
      stro.tppool=tppool
      stro.clatpickup=clatpickup
      stro.clonpickup=clonpickup
      stro.clatdropoff=clatdropoff
      stro.clondropoff=clondropoff
      WRITEU,wlun,stro
    ENDIF
  ENDFOR
  FREE_LUN,wlun
  PRINT,SYSTIME(1)-t0
  t0=SYSTIME(1)
ENDFOR

FREE_LUN,rlun

END
