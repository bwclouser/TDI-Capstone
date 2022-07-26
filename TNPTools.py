import numpy as np
import pandas as pd
import pyspark.sql.functions as F
from pyspark import SparkContext
from pyspark.sql import SQLContext
sc = SparkContext('local[*]','temp')
sqlContext=SQLContext(sc)

def read_array(x):
    array=np.frombuffer(bytes(x),dtype=dt)
    return array.tolist()[0]

def read_in_range(start_year,start_month,end_year,end_month,path='/media/benjamin/Data/Chicago_Transit/TNP/'):
    dt=np.dtype([('id',np.ulonglong),('start year',np.short),('start month',np.byte),('start day',np.byte),('start hour',np.byte),('start minute',np.byte),('start julian',np.double),('end year',np.short),('end month',np.byte),('end day',np.byte),('end hour',np.byte),('end minute',np.byte),('trip seconds',np.uint32),('trip miles',np.single),('pickup census tract',np.ulonglong),('dropoff census tract',np.ulonglong),('pickup community area',np.byte),('dropoff community area',np.byte),('fare',np.single),('tip',np.single),('addcharge',np.single),('trip total',np.single),('st auth',np.byte),('pool',np.byte),('pickup lat',np.double),('pickup lon',np.double),('dropoff lat',np.double),('dropoff lon',np.double)])

    #Calculate month and year ranges
    nmonths=(end_year-start_year-1)*12.+(12.-start_month+1)+end_month
    yrs=(start_year+np.floor((start_month+np.arange(0,nmonths)-1)/12.)).astype(int)
    mos=(np.floor((np.mod(start_month+np.arange(nmonths)-1,12)+1 ))).astype(int)

    #construct list of file names
    fnames=''
    if nmonths > 1:
        for i in np.arange(0,nmonths,dtype=np.int16):
            fnames+=(path+"{0:04d}{1:02d}".format(yrs[i],mos[i])+'TNP.dat')
            if i != nmonths-1:
                fnames+=','
    else:
        fnames=path+"{0:04d}{1:02d}".format(yrs,mos)+'TNP.dat'

    #load binary records into rdd given record length
    rdd=sc.binaryRecords(fnames,104)
    out=rdd.map(read_array)
    df=out.toDF(['id','start year','start month','start day','start hour','start minute','start julian','end year','end month','end day','end hour','end minute','trip seconds','trip miles','pickup census tract','dropoff census tract','pickup community area','dropoff community area','fare','tip','addcharge','trip total','st auth','pool','pickup lat','pickup lon','dropaff lat','dropoff lon'])
    out.unpersist()
    return df

def area_out(df,ca,to_pandas=True):
    with_out=df.groupby(['start year','start month','start day','start hour','start julian','pickup community area']).count()
    out_area=with_out.where(with_out['pickup community area']==ca)
    out_area_sort=out_area.sort(['start year','start month','start day','start hour'])
    if to_pandas:
        outdf=out_area_sort.toPandas()
        outdf=outdf.rename(columns={'start year':'year','start month':'month','start day':'day','start hour':'hour'})
    else:
        outdf=out_area_sort.withColumnRenamed('start year','year').withColumnRenamed('start month','month').withColumnRenamed('start day','day').withColumnRenamed('start hour','hour')
    return outdf

def one_time_count(df,yr,mo,dy,hr):
        one_time=df.where((df['start year']==yr) & (df['start month']==mo) & (df['start day']==dy) & (df['start hour']==hr))
        cnt=one_time.groupby(['pickup community area']).count().toPandas()
        return cnt

def plot_chicago(chicago,counts):
    #expects geopandas dataframe with chicago boundary information
    #and counts as a pandas dataframe
    counts=counts.rename(columns={'area_num_1':'pickup community area'})
    with_count=chicago.merge(counts,on='pickup community area',how='left')
    fix, ax = plt.subplots(1,1)
    with_count.plot(column='pickup community area',ax=ax,legend=True,legend_kwds={'label':'Pickup Count'})
    return with_count
