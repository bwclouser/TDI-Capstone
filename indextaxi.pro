PRO indexTaxi,fname,num

  t0=systime(1)

  s=''

  OPENR,lun,fname,/GET_LUN
  READF,lun,s

  OPENW,wlun,'TaxiIndex.dat',/GET_LUN

  nlun=-1*lun
  
  oneline=''
  remainder=''
  id=''
  tid=''
  mo=0B
  dy=0B
  yr=0
  vid=0B

  pos=0LL

  FOR i=0ull,num-1ull DO BEGIN

    POINT_LUN,nlun,pos
    pos=long64(pos)
    ;POINT_LUN,lun,pos;+170ull
    READF,lun,oneline
    READS,oneline,id,remainder,FORMAT='(A41,A)'
    IF remainder.substring(0,1) NE 'NA' THEN BEGIN
      READS,remainder,tid,mo,dy,yr,FORMAT='(A128,X,I2,X,I2,X,I4)'
      vid=1B
    ENDIF ELSE BEGIN
      READS,remainder,tid,mo,dy,yr,FORMAT='(A2,X,I2,X,I2,X,I4)'
      vid=0B
    ENDELSE

    WRITEU,wlun,i,pos,yr,mo,dy,vid

  ENDFOR
  print,pos
  FREE_LUN,lun
  FREE_LUN,wlun

  PRINT,SYSTIME(1)-t0

END

PRO indexTaxiMC,lines,fname,numstart,numend,core,TIME=time

  t0=systime(1)

  outname='TaxiIndex.dat.'+STRING(core,FORMAT='(I02)')+'.part'

  s=''

  OPENR,lun,fname,/GET_LUN
  READF,lun,s

  OPENW,wlun,outname,/GET_LUN

  nlun=-1*lun

  oneline=''
  remainder=''
  id=''
  tid=''
  mo=0B
  dy=0B
  yr=0S
  vid=0B

  i=0ULL

  pos=numstart
  
  POINT_LUN,lun,numstart

  WHILE pos lt numend DO BEGIN
    
    READF,lun,oneline
    READS,oneline,id,remainder,FORMAT='(A41,A)'
    
    IF remainder.substring(0,1) NE 'NA' THEN BEGIN
      READS,remainder,tid,mo,dy,yr,FORMAT='(A128,X,I2,X,I2,X,I4)'
      vid=1B
    ENDIF ELSE BEGIN
      READS,remainder,tid,mo,dy,yr,FORMAT='(A2,X,I2,X,I2,X,I4)'
      vid=0B
    ENDELSE

    WRITEU,wlun,i,pos,yr,mo,dy,vid
    
    POINT_LUN,nlun,pos
    pos=ULONG64(pos)
    i++
    
  ENDWHILE
  
  print,pos
  lines=i

  FREE_LUN,lun
  FREE_LUN,wlun

  PRINT,SYSTIME(1)-t0

END

PRO indexTaxiWrap,ncores,fname,PATH=PATH,TIME=time

  ;this program takes about 2 minutes to run with ~12 cores. Maybe further gains in speed could be attained by writing to a shared file?

  str={i:0ULL,pos:0ULL,yr:0S,mo:0B,dy:0B,vid:0B}

  t0=SYSTIME(1)

  s=''

  IF NOT KEYWORD_SET(PATH) THEN PATH=':/home/benjamin/Documents/GitHub/TDI-Capstone'
  outname="'TaxiIndex.dat'"

  IF ncores GT !CPU.HW_NCPU THEN BEGIN
    PRINT,'You want to use more threads than are available!'
  ENDIF ELSE BEGIN
    OPENR,lun,fname,/GET_LUN
    nlun=-1*lun
    fs=FSTAT(lun)
    blockSize=ULONG64(fs.size/ncores)
    byteGuesses=(UL64INDGEN(ncores)+1ull)*blocksize
    byteVals=ULON64ARR(2,ncores)
    byteVals[1,ncores-1]=fs.size

    FOR i=0,ncores-2 DO BEGIN
      POINT_LUN,lun,byteGuesses[i]
      READF,lun,s
      POINT_LUN,nlun,pos
      byteVals[1,i]=pos
      byteVals[0,i+1]=pos
    ENDFOR
    
    POINT_LUN,lun,0
    READF,lun,s
    POINT_LUN,nlun,pos
    byteVals[0,0]=pos
    FREE_LUN,lun
    
    scmd=LIST()

    FOR i=0,ncores-1 DO BEGIN

      tname='t'+STRING(i,FORMAT='(I02)')
      cmd0=tname+'=OBJ_NEW("IDL_IDLBridge",output="t"+STRING(i,FORMAT="(I02)")+".txt")'
      cmd1=tname+'.setvar,"PATH",PATH'
      cmd2=tname+'.setvar,"byteVals",byteVals'
      cmd3=tname+'.setvar,"i",i'
      cmd4=tname+'.setvar,"fname",fname
      cmd5=tname+'.execute,"!PATH+=PATH"'
      cmd6=tname+'.execute,".compile indextaxi"'
      
      cmd7=tname+'.execute,"indexTaxiMC,lines,fname,byteVals[0,i],byteVals[1,i],i,TIME=time",/NOWAIT'
      scmd.add,tname+'.status()'
      res=EXECUTE(cmd0+' & '+cmd1+' & '+cmd2+' & '+cmd3+' & '+cmd4+' & '+cmd5+' & '+cmd6+' & '+cmd7)

    ENDFOR

    i=0ull

    scmd=scmd.toarray()
    cmd='ssum=TOTAL('
    FOR j=0,ncores-2 DO BEGIN
      cmd+=scmd[j]
      cmd+='+'
    ENDFOR
    cmd+=scmd[ncores-1]
    cmd+=')'
    res=EXECUTE(cmd)

    WHILE ssum NE 0 DO BEGIN
      WAIT,1
      res=EXECUTE(cmd)
      PRINT,ssum
    ENDWHILE

    OPENW,lun,'TaxiIndex.dat',/GET_LUN

    tlines=0ULL

    FOR j=0,ncores-1 DO BEGIN
      strnum=STRING(j,FORMAT='(I02)')
      cmd0='lines'+strnum+'=t'+strnum+'.getvar("lines")'
      cmd1='OBJ_DESTROY,t'+strnum
      cmd2='tlines=tlines+lines'+strnum
      res=EXECUTE(cmd0+' & '+cmd1+' & '+cmd2)
    ENDFOR
    stop
    FOR j=0,ncores-1 DO BEGIN
      IF j EQ 0 THEN BEGIN
        WRITEU,lun,ULONG64(tlines)
        lines=0ULL
      ENDIF

      strnum=STRING(j,FORMAT='(I02)')
      fname='"TaxiIndex.dat.'+strnum+'.part"'
      cmd0='dat=REPLICATE(str,lines'+strnum+')'
      cmd1='OPENR,rlun,'+fname+',/GET_LUN'
      cmd2='READU,rlun,dat'
      cmd3='dat.i=dat.i+lines'
      cmd4='WRITEU,lun,dat'
      cmd5='FREE_LUN,rlun'
      cmd6='FILE_DELETE,'+fname
      cmd7='lines+=lines'+strnum

      res=EXECUTE(cmd0+' & '+cmd1+' & '+cmd2+' & '+cmd3+' & '+cmd4+' & '+cmd5+' & '+cmd6+' & '+cmd7)

    ENDFOR

    FREE_LUN,lun

    ;FILE_MOVE,'TNPIndex.dat.00.part','TNPIndex.dat',/OVERWRITE

  ENDELSE

  PRINT,SYSTIME(1)-t0

END
