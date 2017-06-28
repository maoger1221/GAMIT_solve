#!/bin/bash
export PATH="$PATH:/opt/GAMIT10.5/gamit/bin:/opt/GAMIT10.5/com:/opt/GAMIT10.5/kf/bin"
export HELP_DIR=/opt/GAMIT10.5/help/
export PATH=$PATH:/usr/local/bin/grads-2.1.1.b0/bin/
export GADDIR=/usr/local/lib/grads
export GASCRP=$HOME/grads/scripts
export GAUDFT=$HOME/grads/udf/table

#进入当前文件路径
path=/home/mao/automaticSolution
rm -rf $path/test
day=0
# 10#转换为十进制
minute=10#$(date +%M)

cd $path
#第一次赋值为0
lastday=$day
#先获取日期时间，根据时间update gamit文件
year=$((10#$(date +%y)))
month=$((10#$(date +%m)))
day=$((10#$(date +%d)))
hour=$((10#$(date +%H)))
echo "gamit${year}:${month}:${day}:${hour}:${minute}">>/home/mao/automaticSolution/startedLog
#一天更新一次
##if [ $day != $lastday ]
##then
#有时更新不好使nutabl,soltab,luntab没更新
##./gamit_upd_table.sh -f 20$year $month $day
##fi

#根据日期计算年积日，下载观测文件、导航电文、预报星历
#0点到8点是前一个doy
if [ $hour -lt '8' ]
then
	flagg=1
else
	flagg=0
fi

if [ $(($year%4)) = '0' ]
then
	flag=1
else
	flag=0
fi

case $month in
1)
doy=$[$day-$flagg]
;;
2)
doy=$[31+$day-$flagg]
;;
3)
doy=$[59+$day+$flag-$flagg]
;;
4)
doy=$[90+$day+$flag-$flagg]
;;
5)
doy=$[120+$day+$flag-$flagg]
;;
6)
doy=$[151+$day+$flag-$flagg]
;;
7)
doy=$[181+$day+$flag-$flagg]
;;
8)
doy=$[212+$day+$flag-$flagg]
;;
9)
doy=$[243+$day+$flag-$flagg]
;;
10)
doy=$[273+$day+$flag-$flagg]
;;
11)
doy=$[304+$day+$flag-$flagg]
;;
12)
doy=$[334+$day+$flag-$flagg]
;;
esac

#########计算前2天的########igs站数据延迟2天
doy=$[$doy-2]
if [ $doy -lt '10' ]
then
	doyy=00$doy
elif [ $doy -lt '100' ]
then
	doyy=0$doy
else
	doyy=$doy
fi


#创建目录
mkdir $path/test
mkdir $path/test/rinex
mkdir $path/test/brdc
mkdir $path/test/igs
mkdir $path/result

#下载o文件
cd $path/test/rinex
#下载tjjd文件,-O重命名,要写在url前面
#网站上存了两年的数据，如果有前一年的，则tjjd1771.17o和tjjd1770.17o
wget -c -O tjjd${doyy}0.${year}o http://10.60.12.54/CACHEDIR2553655085/download/Internal/2926${doyy}0.T02?format=RNX&Ver=2.11
wget -c -O tjjd${doyy}1.${year}o http://10.60.12.54/CACHEDIR2553655085/download/Internal/2926${doyy}1.T02?format=RNX&Ver=2.11

for site in shao chan bjfs bjnm wuhn urum lhaz tnml
do
echo ${site}${doyy}
#-c表示断点续传，-T 20表示等待20秒连接不上就算超时,-t参数表示重试次数，例如需要重试100次，那么就写-t 100
wget -c -T 20 ftp://cddis.gsfc.nasa.gov/pub/gps/data/daily/20${year}/${doyy}/${year}o/${site}${doyy}0.${year}o.Z
uncompress ${site}${doyy}0.${year}o.Z
done
#下载brdc文件
cd $path/test/brdc
wget -c -T 20 ftp://cddis.gsfc.nasa.gov/pub/gps/data/daily/20${year}/brdc/brdc${doyy}0.${year}n.Z
uncompress brdc${doyy}0.${year}n.Z
#计算gps week

week=$((($(date -d $(date +%Y)$(date +%m)$(date +%d) +%s) - $(date -d "19800106" +%s))/(24*60*60*7)))
#计算gps day of week
dow=$[$((($(date -d $(date +%Y)$(date +%m)$(date +%d) +%s) - $(date -d "19800106" +%s))/(24*60*60)))-$week*7]
#########计算前2天的########
dow=$[$dow-2]

if [ $dow = '-1' ]
then
week=$[$week-1]
dow=6
elif [ $dow = '-2' ]
then
week=$[$week-1]
dow=5
fi

#下载预报星历
cd $path/test/igs
for igutime in 00 06 12 18
do
wget -c -T 20 ftp://cddis.gsfc.nasa.gov/pub/gps/products/$week/igu${week}${dow}_${igutime}.sp3.Z
uncompress igu${week}${dow}_${igutime}.sp3.Z
done

cd $path/test
#gamit解算
#修改嘉定站天线名
cd rinex
sed -i 's/Trimble NetR9/TRIMBLE NETR9/g' tjjd${doyy}0.${year}o
sed -i 's/Trimble NetR9/TRIMBLE NETR9/g' tjjd${doyy}1.${year}o
cd ..
sh_setup -yr 20${year}
cd tables
sh_upd_stnfo -l sd
mv station.info.new station.info
sed -i '8,$d' station.info
sh_upd_stnfo -files ../rinex/*.${year}o
cd ..
sh_gamit -expt test -d 20${year} ${doyy} -orbit IGSU -copt x k p -dopts c ao

cd $path/test/${doyy}
#zshao7.doy,7表示年
yearr=$[$year-10]
sh_metutil -f otesta.${doyy} -z ztjjd${yearr}.${doyy}
cd $path

#获取当前系统时间(时、分)
time=$(date +%H%M)

#拷贝文件并重命名
#cp $path/test/${doyy}/met_tjjd.${year}${doyy} $path/result/met_tjjd${time}.${year}${doyy}
#cp $path/test/${doyy}/otesta.${doyy} $path/result/otesta${time}.${doyy}
#cp $path/test/${doyy}/qtesta.${doyy} $path/result/qtesta${time}.${doyy}
#cp $path/test/${doyy}/htesta.${year}${doyy} $path/result/htesta${time}.${year}${doyy}
mv -f $path/test/${doyy}/met_tjjd.${year}${doyy} $path/result/pwv_tjjd.txt
mv -f $path/test/${doyy}/otesta.${doyy} $path/result/otesta.${doyy}
mv -f $path/test/${doyy}/qtesta.${doyy} $path/result/qtesta.${doyy}
mv -f $path/test/${doyy}/htesta.${year}${doyy} $path/result/htesta.${year}${doyy}
for prn in {01..32}
do
mv -f $path/test/${doyy}/DPH.TJJD.PRN${prn} $path/result/DPH.TJJD.PRN${prn}
done
#删除test文件
rm -rf $path/test


