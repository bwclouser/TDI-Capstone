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

    ;IF i EQ 1205 THEN stop

    WRITEU,wlun,i,pos,yr,mo,dy,vid

  ENDFOR

  FREE_LUN,lun
  FREE_LUN,wlun

  PRINT,SYSTIME(1)-t0

END

