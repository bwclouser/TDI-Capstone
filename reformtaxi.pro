PRO reformTaxi,fname,index=index,ncores=ncores

  t0=SYSTIME(1)
  
  restore,'/media/benjamin/Data/Chicago_Transit/Taxi/TaxiCompanies.sav'
  restore,'/media/benjamin/Data/Chicago_Transit/Taxi/TaxiPayments.sav'
  
  bad=[0ULL]
  
  str={id:0ULL,sdy:0B,shr:0B,smn:0B,emo:0B,edy:0B,eyr:0S,ehr:0B,emn:0B,trips:0UL,tripmi:0.,ctpickup:0ULL,ctdropoff:0ULL,capickup:0B,cadropoff:0B,fare:0.,tip:0.,tolls:0.,extras:0.,ttotal:0.,ptype:0B,company:0B,clatpickup:0d0,clonpickup:0d0,clatdropoff:0d0,clondropoff:0d0}

  IF NOT KEYWORD_SET(index) THEN BEGIN
    OPENR,rlun,'/media/benjamin/Data/Chicago_Transit/Taxi/TaxiIndex.dat',/GET_LUN
    num=0ULL
    READU,rlun,num
    index=REPLICATE(str,num)
    READU,rlun,index
    FREE_LUN,rlun
  ENDIF
  
  IF NOT KEYWORD_SET(ncores) THEN ncores=-1

  id=''
  tid=''
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
  trips=0ul
  tripmi=0.
  ctpickup=''
  ctdropoff=''
  capickup=0ULL
  cadropoff=0ULL
  fare=0.
  tip=0.
  tolls=0.
  extras=0.
  ttotal=0.
  ptype=0B
  company=0B
  clatpickup=0d0
  clonpickup=0d0
  clocpickup=''
  clatdropoff=0d0
  clondropoff=0d0
  clocdropoff=''


  ;plist=['id','smo','sdy','syr','smn','ssc','sampm','emo','edy','eyr','ehr','emn','esc','eampm','trips','tripmi','ctpickup','ctdropoff','capickup','cadropoff','fare','tip','addcharge','ttotal','tppool','clatpickup','clonpickup','clocpickup','clatdropoff','clondropoff','clocdropoff']
  ;pform=['A40,x,','I2,x,','I2,x,','I4,x,','I2,x,','I2,x,','I2,x,','A2,x,','I2,x,','I2,x,','I4,x,','I2,x,','I2,x,','I2,x,','A2,x,','F,x,','F,x,','I11,x,','I11,x,','I,x,','I,x,','F,x,','F,x,','F,x,','F,x,','I,x,','F,x,','F,x,','A36,x,','F,x,','F,x,','A36']

  cmdarr=['id=STRING(-1,FORMAT="(I02)")','tid=STRING(-1,FORMAT="(I02)")','smo=-1b & sdy=-1b & syr=-1s & shr=-1b & smn=-1b & ssc=-1b & sampm=STRING(-1,FORMAT="(I02)")','emo=-1b & edy=-1b & eyr=-1s & ehr=-1b & emn=-1b & esc=-1b & eampm=STRING(-1,FORMAT="(I02)")','trips=-1.','tripmi=-1.','ctpickup=0ull','ctdropoff=0ull','capickup=-1b','cadropoff=-1b','fare=-1.','tip=-1.','tolls=-1.','extras=-1.','ttotal=-1.','clatpickup=-1d0','clonpickup=-1d0','clocpickup=STRING(-1,FORMAT="(I02)")','clatdropoff=-1d0','clondropoff=-1d0','clocdropoff=STRING(-1,FORMAT="(I02)")']
  vararr=['id,','tid,','smo,sdy,syr,shr,smn,ssc,sampm,','emo,edy,eyr,ehr,emn,esc,eampm,','trips,','tripmi,','ctpickup,','ctdropoff,','capickup,','cadropoff,','fare,','tip,','tolls,','extras,','ttotal,','clatpickup,','clonpickup,','clocpickup,','clatdropoff,','clondropoff,','clocdropoff,']
  formarr=['A40,x,','A','I2,x,I2,x,I4,x,I2,x,I2,x,I2,x,A2,x,','I2,x,I2,x,I4,x,I2,x,I2,x,I2,x,A2,x,','F,','F,','I11,x,','I11,x,','I,','I,','F,','F,','F,','F,','F,','F,','F,','A36,x,','F,','F,','A36']

  yrtime=index.yr+index.mo/30.5+index.dy/365.

  tmin=MIN(yrtime,jmin)
  tmax=MAX(yrtime,jmax)

  yrmin=index[jmin].yr
  momin=index[jmin].mo

  yrmax=index[jmax].yr
  momax=index[jmax].mo

  nmonths=(yrmax-yrmin-1)*12.+(12.-momin+1)+momax
  
  yrs=yrmin+FIX((momin+indgen(nmonths)-1)/12)
  mos=FIX(((momin+indgen(nmonths)-1) MOD 12)+1)

  oneline=''
  
  IF ncores EQ -1 THEN BEGIN

  OPENR,rlun,fname,/GET_LUN

  FOR i=0,nmonths-1 DO BEGIN
    
    yr=yrmin+FIX((momin+i-1)/12)
    mo=FIX(((momin+i-1) MOD 12)+1)
    wfname=STRING(yr,FORMAT='(I04)')+STRING(mo,FORMAT='(I02)')+'Taxi.dat'
    OPENW,wlun,wfname,/GET_LUN
    thisTime=WHERE(index.yr EQ yr AND index.mo EQ mo)
    nTimes=N_ELEMENTS(thisTime)
    
    WRITEU,wlun,yr,mo,nTimes

    FOR j=0l,nTimes-1 DO BEGIN
      isBad=WHERE(index[thisTime[j]].i eq bad)
      IF isBad[0] EQ -1 THEN BEGIN
        POINT_LUN,rlun,index[thisTime[j]].pos
        READF,rlun,oneline
        
        oneline=oneline.replace('"Taxicab Insurance Agency, LLC"','"Taxicab Insurance Agency LLC"')
        oneline=oneline.replace('"3721 - Santamaria Express, Alvaro Santamaria"','"3721 - Santamaria Express Alvaro Santamaria"')
        oneline=oneline.replace('"2241 - 44667 - Felman Corp, Manuel Alonso"','"2241 - 44667 - Felman Corp Manuel Alonso"')
        
        bline=oneline.toByte()
        wComma=WHERE(bline eq 44)
        wAdjr=wComma-SHIFT(wComma,1)
        
        ;IF N_ELEMENTS(wComma) GE 23 THEN STOP
        
        pAndT=oneline.subString(wComma[14],wComma[16])
        oneline=oneline.remove(wComma[14],wComma[16]-1)
        
        outArr=strsplit(pAndT,',',/EXTRACT,/PRESERVE_NULL)
        IF outArr[1] NE '' THEN BEGIN
          pType=BYTE(WHERE(outarr[1] eq ptypes))
        ENDIF ELSE BEGIN
          pType=255B
        ENDELSE
        IF outArr[2] NE '' THEN BEGIN
          company=BYTE(WHERE(outarr[2] eq ttypes))
        ENDIF ELSE BEGIN
          company=255B
        ENDELSE
        ;stop
        
        bline=oneline.toByte()
        wComma=WHERE(bline eq 44)
        wAdjr=wComma-SHIFT(wComma,1)   

        IF bline[0] EQ 44 THEN wAdjr[0]=1
        IF bline[N_ELEMENTS(bline)-1] EQ 44 THEN wAdjr[N_ELEMENTS(wAdjr)-1]=1

        ;f1=STRING(wAdjr[11]-1,FORMAT='(I02)')
        ;f2=STRING(wAdjr[12]-1,FORMAT='(I02)')
        ;toAdd=',F'+f1+',x,F'+f2+',x'

        isAdj=WHERE(wAdjr EQ 1,COMPLEMENT=notAdj)
        IF isAdj[0] EQ -1 THEN BEGIN
          IF index[thisTime[j]].vid EQ 1 THEN BEGIN
            cmd='READS,oneline,id,tid,smo,sdy,syr,shr,smn,ssc,sampm,emo,edy,eyr,ehr,emn,esc,eampm,trips,tripmi,ctpickup,ctdropoff,capickup,cadropoff,fare,tip,tolls,extras,ttotal,clatpickup,clonpickup,clocpickup,clatdropoff,clondropoff,clocdropoff,FORMAT="(A40,x,A128,x,I2,x,I2,x,I4,x,I2,x,I2,x,I2,x,A2,x,I2,x,I2,x,I4,x,I2,x,I2,x,I2,x,A2,x,2F,I11,x,I11,x,2I,7F,A36,x,F,F,A36)"'
          ENDIF ELSE BEGIN
            cmd='READS,oneline,id,tid,smo,sdy,syr,shr,smn,ssc,sampm,emo,edy,eyr,ehr,emn,esc,eampm,trips,tripmi,ctpickup,ctdropoff,capickup,cadropoff,fare,tip,tolls,extras,ttotal,clatpickup,clonpickup,clocpickup,clatdropoff,clondropoff,clocdropoff,FORMAT="(A40,x,A2,x,I2,x,I2,x,I4,x,I2,x,I2,x,I2,x,A2,x,I2,x,I2,x,I4,x,I2,x,I2,x,I2,x,A2,x,2F,I11,x,I11,x,2I,7F,A36,x,F,F,A36)"'
          ENDELSE
          ;cmd1=',I,F,F,A36,x,F,F,A36)"'
          ;cmd=cmd0+toAdd+cmd1
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
              IF k EQ 1 THEN BEGIN
                IF index[thisTime[j]].vid EQ 1 THEN cmd+='128,x,' ELSE cmd+='2,x,'
              ENDIF
            ENDIF ELSE BEGIN
              cmd+='x,'
            ENDELSE
          ENDFOR
          cmd+=")'"
          ;stop
          res=EXECUTE(cmd)
          ;stop
        ENDELSE
        ;
        str.id=index[thisTime[j]].i
        str.sdy=sdy
        IF sampm EQ 'PM' THEN str.shr=(shr MOD 12S)+12S ELSE str.shr=(shr MOD 12S)
        str.smn=smn
        str.eyr=eyr
        str.emo=emo
        str.edy=edy
        IF eampm EQ 'PM' THEN str.ehr=(ehr MOD 12S)+12S ELSE str.ehr=(ehr MOD 12S)
        str.emn=emn
        str.trips=trips
        str.tripmi=tripmi
        str.ctpickup=ctpickup
        str.ctdropoff=ctdropoff
        str.capickup=capickup
        str.cadropoff=cadropoff
        str.fare=fare
        str.tip=tip
        str.tolls=tolls
        str.extras=extras
        str.ttotal=ttotal
        str.ptype=ptype
        str.company=company
        str.clatpickup=clatpickup
        str.clonpickup=clonpickup
        str.clatdropoff=clatdropoff
        str.clondropoff=clondropoff

        WRITEU,wlun,str
      ENDIF
    ENDFOR
    FREE_LUN,wlun
    PRINT,SYSTIME(1)-t0
    t0=SYSTIME(1)
  ENDFOR

  FREE_LUN,rlun
  
ENDIF ELSE BEGIN
  
  stri={i:0ULL,pos:0ULL,yr:0S,mo:0B,dy:0B,vid:0B}

  shmname='index'
  iSize=SIZE(index)
  SHMMAP,shmname,SIZE=iSize,TEMPLATE=stri
  dex=SHMVAR(shmname)
  dex[0]=index

  names=LIST()
  
  FOR j=0,ncores-1 DO BEGIN
    padd="':/home/benjamin/Documents/GitHub/TDI-Capstone'"
    strnum=STRING(j,FORMAT='(I02)')
    cmd0='t'+strnum+'=OBJ_NEW("IDL_IDLBridge",OUTPUT="debug'+strnum+'.txt")'
    cmd1='t'+strnum+'.execute,"!PATH=!PATH+'+padd+'"'
    cmd2='t'+strnum+'.execute,".compile reformtaxi"'
    cmd3='t'+strnum+'.execute,"  stri={i:0ULL,pos:0ULL,yr:0S,mo:0B,dy:0B,vid:0B}"'
    cmd4='t'+strnum+'.setvar,"shmname",shmname'
    cmd5='t'+strnum+'.setvar,"iSize",iSize'
    cmd6='t'+strnum+'.setvar,"fname",fname'
    cmd7='t'+strnum+'.execute,"SHMMAP,shmname,SIZE=iSize,TEMPLATE=stri"'
    cmd8='t'+strnum+'.execute,"dex=SHMVAR(shmname)"'
    cmd9='names.add,t'+strnum
    print,cmd1
    res=EXECUTE(cmd0+' & '+cmd1+' & '+cmd2+' & '+cmd3+' & '+cmd4+' & '+cmd5+' & '+cmd6+' & '+cmd7+' & '+cmd8+' & '+cmd9)



  ENDFOR
  
  moInd=BYTARR(nmonths,/NOZERO)
  moInd[*]=1B

  WHILE TOTAL(moInd) NE 0 DO BEGIN
    FOREACH nm,names DO BEGIN
      IF nm.status() EQ 0 THEN BEGIN
        ind=WHERE(moInd EQ 1B)
        IF ind[0] NE -1 THEN BEGIN
          moInd[ind[0]]=0B
          yr=yrs[ind[0]]
          mo=mos[ind[0]]
          nm.setvar,'yr',yr
          nm.setvar,'mo',mo
          nm.execute,"CD,'/media/benjamin/Data/Chicago_Transit/Taxi'"
          nm.execute,'reformCoreMCTaxi,fname,dex,yr,mo',/NOWAIT
        ENDIF ELSE BEGIN
          OBJ_DESTROY,nm
        ENDELSE
      ENDIF
    ENDFOREACH
    WAIT,10
    PRINT,moInd

  ENDWHILE

  FOREACH nm,names DO BEGIN
    OBJ_DESTROY,nm
  ENDFOREACH

  dex=0
  SHMUNMAP,'index'

ENDELSE

END

PRO scanTaxi,fname,ttypes,ptypes

t0=SYSTIME(1)

header=''
oneline=''
ttypes=[]
ptypes=[]

OPENR,lun,fname,/GET_LUN

READF,lun,header
i=0ull
WHILE NOT EOF(lun) DO BEGIN
  READF,lun,oneline
  bline=oneline.toByte()
  wComma=WHERE(bline EQ 44)
  IF N_ELEMENTS(wComma) GE 23 THEN BEGIN
    taxi=oneline.subString(wComma[15],wComma[17])
    taxi=taxi.replace(',','')
  ENDIF ELSE BEGIN
    taxi=oneline.subString(wComma[15],wComma[16])
    taxi=taxi.replace(',','')
  ENDELSE
  payment=oneline.subString(wComma[14],wComma[15])
  payment=payment.replace(',','')
  IF (WHERE(taxi EQ ttypes))[0] EQ -1 THEN BEGIN
    ttypes=[ttypes,taxi]
  ENDIF
  IF (WHERE(payment EQ ptypes))[0] EQ -1 THEN ptypes=[ptypes,payment]
  i++
;  IF i MOD 100000. EQ 0 THEN BEGIN
;    PRINT,SYSTIME(1)-t0
;    STOP
;  ENDIF
ENDWHILE

FREE_LUN,lun

END


PRO reformCoreMCTaxi,fname,index,yr,mo

  bad=[0ULL]
  oneline=''
  
  restore,'/media/benjamin/Data/Chicago_Transit/Taxi/TaxiCompanies.sav'
  restore,'/media/benjamin/Data/Chicago_Transit/Taxi/TaxiPayments.sav'
  
  str={id:0ULL,sdy:0B,shr:0B,smn:0B,emo:0B,edy:0B,eyr:0S,ehr:0B,emn:0B,trips:0UL,tripmi:0.,ctpickup:0ULL,ctdropoff:0ULL,capickup:0B,cadropoff:0B,fare:0.,tip:0.,tolls:0.,extras:0.,ttotal:0.,ptype:0B,company:0B,clatpickup:0d0,clonpickup:0d0,clatdropoff:0d0,clondropoff:0d0}

  id=''
  tid=''
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
  trips=0ul
  tripmi=0.
  ctpickup=''
  ctdropoff=''
  capickup=0ULL
  cadropoff=0ULL
  fare=0.
  tip=0.
  tolls=0.
  extras=0.
  ttotal=0.
  ptype=0B
  company=0B
  clatpickup=0d0
  clonpickup=0d0
  clocpickup=''
  clatdropoff=0d0
  clondropoff=0d0
  clocdropoff=''

  cmdarr=['id=STRING(-1,FORMAT="(I02)")','tid=STRING(-1,FORMAT="(I02)")','smo=-1b & sdy=-1b & syr=-1s & shr=-1b & smn=-1b & ssc=-1b & sampm=STRING(-1,FORMAT="(I02)")','emo=-1b & edy=-1b & eyr=-1s & ehr=-1b & emn=-1b & esc=-1b & eampm=STRING(-1,FORMAT="(I02)")','trips=-1.','tripmi=-1.','ctpickup=0ull','ctdropoff=0ull','capickup=-1b','cadropoff=-1b','fare=-1.','tip=-1.','tolls=-1.','extras=-1.','ttotal=-1.','clatpickup=-1d0','clonpickup=-1d0','clocpickup=STRING(-1,FORMAT="(I02)")','clatdropoff=-1d0','clondropoff=-1d0','clocdropoff=STRING(-1,FORMAT="(I02)")']
  vararr=['id,','tid,','smo,sdy,syr,shr,smn,ssc,sampm,','emo,edy,eyr,ehr,emn,esc,eampm,','trips,','tripmi,','ctpickup,','ctdropoff,','capickup,','cadropoff,','fare,','tip,','tolls,','extras,','ttotal,','clatpickup,','clonpickup,','clocpickup,','clatdropoff,','clondropoff,','clocdropoff,']
  formarr=['A40,x,','A','I2,x,I2,x,I4,x,I2,x,I2,x,I2,x,A2,x,','I2,x,I2,x,I4,x,I2,x,I2,x,I2,x,A2,x,','F,','F,','I11,x,','I11,x,','I,','I,','F,','F,','F,','F,','F,','F,','F,','A36,x,','F,','F,','A36']

  OPENR,rlun,fname,/GET_LUN

  wfname=STRING(yr,FORMAT='(I04)')+STRING(mo,FORMAT='(I02)')+'Taxi.dat'
  OPENW,wlun,wfname,/GET_LUN

  thisTime=WHERE(index.yr EQ yr AND index.mo EQ mo)
  nTimes=N_ELEMENTS(thisTime)

  WRITEU,wlun,yr,mo,nTimes


    FOR j=0l,nTimes-1 DO BEGIN
      isBad=WHERE(index[thisTime[j]].i eq bad)
      IF isBad[0] EQ -1 THEN BEGIN
        POINT_LUN,rlun,index[thisTime[j]].pos
        READF,rlun,oneline
        
        oneline=oneline.replace('"Taxicab Insurance Agency, LLC"','"Taxicab Insurance Agency LLC"')
        oneline=oneline.replace('"3721 - Santamaria Express, Alvaro Santamaria"','"3721 - Santamaria Express Alvaro Santamaria"')
        oneline=oneline.replace('"2241 - 44667 - Felman Corp, Manuel Alonso"','"2241 - 44667 - Felman Corp Manuel Alonso"')
       
        bline=oneline.toByte()
        wComma=WHERE(bline eq 44)
        wAdjr=wComma-SHIFT(wComma,1)
        
        ;IF N_ELEMENTS(wComma) GE 23 THEN STOP
        
        pAndT=oneline.subString(wComma[14],wComma[16])
        oneline=oneline.remove(wComma[14],wComma[16]-1)
        
        outArr=strsplit(pAndT,',',/EXTRACT,/PRESERVE_NULL)
        IF outArr[1] NE '' THEN BEGIN
          pType=BYTE(WHERE(outarr[1] eq ptypes))
        ENDIF ELSE BEGIN
          pType=255B
        ENDELSE
        IF outArr[2] NE '' THEN BEGIN
          company=BYTE(WHERE(outarr[2] eq ttypes))
        ENDIF ELSE BEGIN
          company=255B
        ENDELSE
        ;stop
        
        bline=oneline.toByte()
        wComma=WHERE(bline eq 44)
        wAdjr=wComma-SHIFT(wComma,1)   

        IF bline[0] EQ 44 THEN wAdjr[0]=1
        IF bline[N_ELEMENTS(bline)-1] EQ 44 THEN wAdjr[N_ELEMENTS(wAdjr)-1]=1

        isAdj=WHERE(wAdjr EQ 1,COMPLEMENT=notAdj)
        IF isAdj[0] EQ -1 THEN BEGIN
          IF index[thisTime[j]].vid EQ 1 THEN BEGIN
            cmd='READS,oneline,id,tid,smo,sdy,syr,shr,smn,ssc,sampm,emo,edy,eyr,ehr,emn,esc,eampm,trips,tripmi,ctpickup,ctdropoff,capickup,cadropoff,fare,tip,tolls,extras,ttotal,clatpickup,clonpickup,clocpickup,clatdropoff,clondropoff,clocdropoff,FORMAT="(A40,x,A128,x,I2,x,I2,x,I4,x,I2,x,I2,x,I2,x,A2,x,I2,x,I2,x,I4,x,I2,x,I2,x,I2,x,A2,x,2F,I11,x,I11,x,2I,7F,A36,x,F,F,A36)"'
          ENDIF ELSE BEGIN
            cmd='READS,oneline,id,tid,smo,sdy,syr,shr,smn,ssc,sampm,emo,edy,eyr,ehr,emn,esc,eampm,trips,tripmi,ctpickup,ctdropoff,capickup,cadropoff,fare,tip,tolls,extras,ttotal,clatpickup,clonpickup,clocpickup,clatdropoff,clondropoff,clocdropoff,FORMAT="(A40,x,A2,x,I2,x,I2,x,I4,x,I2,x,I2,x,I2,x,A2,x,I2,x,I2,x,I4,x,I2,x,I2,x,I2,x,A2,x,2F,I11,x,I11,x,2I,7F,A36,x,F,F,A36)"'
          ENDELSE
          ;cmd1=',I,F,F,A36,x,F,F,A36)"'
          ;cmd=cmd0+toAdd+cmd1
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
              IF k EQ 1 THEN BEGIN
                IF index[thisTime[j]].vid EQ 1 THEN cmd+='128,x,' ELSE cmd+='2,x,'
              ENDIF
            ENDIF ELSE BEGIN
              cmd+='x,'
            ENDELSE
          ENDFOR
          cmd+=")'"
          ;stop
          res=EXECUTE(cmd)
          ;stop
        ENDELSE
        ;
        str.id=index[thisTime[j]].i
        str.sdy=sdy
        IF sampm EQ 'PM' THEN str.shr=(shr MOD 12S)+12S ELSE str.shr=(shr MOD 12S)
        str.smn=smn
        str.eyr=eyr
        str.emo=emo
        str.edy=edy
        IF eampm EQ 'PM' THEN str.ehr=(ehr MOD 12S)+12S ELSE str.ehr=(ehr MOD 12S)
        str.emn=emn
        str.trips=trips
        str.tripmi=tripmi
        str.ctpickup=ctpickup
        str.ctdropoff=ctdropoff
        str.capickup=capickup
        str.cadropoff=cadropoff
        str.fare=fare
        str.tip=tip
        str.tolls=tolls
        str.extras=extras
        str.ttotal=ttotal
        str.ptype=ptype
        str.company=company
        str.clatpickup=clatpickup
        str.clonpickup=clonpickup
        str.clatdropoff=clatdropoff
        str.clondropoff=clondropoff

        WRITEU,wlun,str
      ENDIF
    ENDFOR
 
  FREE_LUN,wlun


  FREE_LUN,rlun



END

