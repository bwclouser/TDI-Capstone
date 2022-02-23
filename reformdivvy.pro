PRO reformDivvy,fname

str={id:0ULL,sdy:0B,shr:0B,smn:0B,emo:0B,edy:0B,eyr:0S,ehr:0B,emn:0B,trips:0UL,bid:0UL,fid:0S,fname:'',tid:0S,tname:'',utype:'',gender:'',byr:0S,flat:0.,flon:0.,floc:'',tlat:0.,tlon:0.,tloc:''}

cmdarr=['id=STRING(-1,FORMAT="(I02)")','tid=STRING(-1,FORMAT="(I02)")','smo=-1b & sdy=-1b & syr=-1s & shr=-1b & smn=-1b & ssc=-1b & sampm=STRING(-1,FORMAT="(I02)")','emo=-1b & edy=-1b & eyr=-1s & ehr=-1b & emn=-1b & esc=-1b & eampm=STRING(-1,FORMAT="(I02)")','trips=-1.','tripmi=-1.','ctpickup=0ull','ctdropoff=0ull','capickup=-1b','cadropoff=-1b','fare=-1.','tip=-1.','tolls=-1.','extras=-1.','ttotal=-1.','clatpickup=-1d0','clonpickup=-1d0','clocpickup=STRING(-1,FORMAT="(I02)")','clatdropoff=-1d0','clondropoff=-1d0','clocdropoff=STRING(-1,FORMAT="(I02)")']
vararr=['id,','smo,sdy,syr,shr,smn,ssc,sampm,','emo,edy,eyr,ehr,emn,esc,eampm,','trips,','bid,','fid,','fname,','tid,','tname,','utype,','gender,','byr,','flat,','flon,','floc,','tlat,','tlon,','tloc,']
formarr=['I,x,','I2,x,I2,x,I4,x,I2,x,I2,x,I2,x,A2,x,','I2,x,I2,x,I4,x,I2,x,I2,x,I2,x,A2,x,','I,','I,','I','A','I,','I,','A,','A,','A,','F,','F,','A,','F,','F,','A,']

oneline=''

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

data=REPLICATE(str,lines-1)

READF,rlun,oneline

yrs=intarr(lines-1)
mos=bytarr(lines-1)


FOR i=0ULL,lines-2ULL DO BEGIN

  READF,rlun,oneline
  out=STRSPLIT(oneline,',',/EXTRACT)
  
  bline=oneline.toByte()
  wComma=WHERE(bline eq 44)
  wAdjr=wComma-SHIFT(wComma,1)

  IF bline[0] EQ 44 THEN wAdjr[0]=1
  IF bline[N_ELEMENTS(bline)-1] EQ 44 THEN wAdjr[N_ELEMENTS(wAdjr)-1]=1

  isAdj=WHERE(wAdjr EQ 1,COMPLEMENT=notAdj)
  
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
  
  yrs[i]=syr
  mos[i]=smo
  str.sdy=sdy
  IF sampm EQ 'PM' THEN str.shr=(shr MOD 12S)+12S ELSE str.shr=(shr MOD 12S)s=
  str.smn=smn
  str.emo=emo
  str.edy=edy
  str.eyr=eyr
  IF eampm EQ 'PM' THEN str.ehr=(ehr MOD 12S)+12S ELSE str.ehr=(ehr MOD 12S)
  str.bid=bid
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

stop

END