PRO indexTNP,fname,num

t0=systime(1)

s=''

OPENR,lun,fname,/GET_LUN
READF,lun,s

OPENW,wlun,'TNPIndex.dat',/GET_LUN

nlun=-1*lun

mo=0B
dy=0B
yr=0

pos=0LL

FOR i=0ull,num-1ull DO BEGIN
  
  POINT_LUN,nlun,pos
  pos=long64(pos)
  POINT_LUN,lun,pos+41ull
  READF,lun,mo,dy,yr,FORMAT='(I2,X,I2,X,I4)'
  
  ;stop
  
  WRITEU,wlun,i,pos,yr,mo,dy
;  POINT_LUN,lun,pos
;  READF,lun,s
  
ENDFOR

FREE_LUN,lun
FREE_LUN,wlun

PRINT,SYSTIME(1)-t0

END

PRO writeTripID,fname,num

s=''
s1=''
s2=''
s3=''

OPENR,rlun,fname,/GET_LUN
READF,rlun,s

OPENW,wlun,'TNPTripIDs.dat',/GET_LUN

FOR i=0ull,num-1ull DO BEGIN
  READF,rlun,s1,s2,s3,FORMAT='(A8,A16,A16)'
  cmd0="ul1=ulong('"+s1+"'x)"
  cmd1="ull1=ulong64('"+s2+"'x)"
  cmd2="ull2=ulong64('"+s3+"'x)"
  res=EXECUTE(cmd0+' & '+cmd1+' & '+cmd2)
  WRITEU,wlun,i,ul1,ull1,ull2
ENDFOR

FREE_LUN,rlun
FREE_LUN,wlun

END

