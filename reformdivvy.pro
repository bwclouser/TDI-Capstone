PRO reformDivvy,fname

s=''

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

OPENR,rlun,fname,/GET_LUN

lines=FILE_LINES(fname)

READF,rlun,s

FOR i=0ULL,lines-1ULL DO BEGIN

  READF,rlun,s
  out=STRSPLIT(s,',',/EXTRACT)
  
  id=ULONG(out[0])
  READS,out[1],smo,sdy,syr,shr,smn,ssc,sampm,FORMAT='(I2,x,I2,x,I4,x,I2,x,I2,x,I2,x,A2)'
  READS,out[2],emo,edy,eyr,ehr,emn,esc,eampm,FORMAT='(I2,x,I2,x,I4,x,I2,x,I2,x,I2,x,A2)'
  bid=ULONG(out[3])
  trips=ULONG(out[4])
  ssta=FIX(out[5])
  sstaname=out[6]
  tsta=FIX(out[7])
  tstaname=out[8]
  utype=out[9]
  ugend=out[10]
  byr=FIX(out[11])
  flat=FLOAT(out[12])
  flon=FLOAT(out[13])
  floc=out[14]
  tlat=FLOAT(out[15])
  tlon=FLOAT(out[16])
  tloc=out[17]
  stop
  
ENDFOR
END