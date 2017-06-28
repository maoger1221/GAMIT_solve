#!/bin/bash

#先获取日期时间，根据时间update gamit文件
year=$((10#$(date +%y)))
month=$((10#$(date +%m)))
day=$((10#$(date +%d)))
hour=$((10#$(date +%H)))
#进入当前文件路径
path=$(cd `dirname $0`; pwd)
cd $path
#有时更新不好使nutabl,soltab,luntab没更新
#./gamit_upd_table.sh -f 20$year $month $day
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

if [ $doy -lt '10' ]
then
	doyy=00$doy
#########计算前1天的########
#doyy=00$[$doy-2]
elif [ $doy -lt '100' ]
then
	doyy=0$doy
#doyy=0$[$doy-2]
else
	doyy=$doy
#doyy=$[$doy-2]
fi




#创建目录
mkdir $path/test
mkdir $path/test/rinex
mkdir $path/test/brdc
mkdir $path/test/igs
mkdir $path/result

#下载o文件
cd $path/test/rinex
for site in shao chan bjfs bjnm wuhn urum lhaz tnml
do
echo ${site}${doyy}
wget ftp://cddis.gsfc.nasa.gov/pub/gps/data/daily/20${year}/${doyy}/${year}o/${site}${doyy}0.${year}o.Z
uncompress ${site}${doyy}0.${year}o.Z
done
#下载brdc文件
cd $path/test/brdc
wget ftp://cddis.gsfc.nasa.gov/pub/gps/data/daily/20${year}/brdc/brdc${doyy}0.${year}n.Z
uncompress brdc${doyy}0.${year}n.Z
#计算gps week

week=$((($(date -d $(date +%Y)$(date +%m)$(date +%d) +%s) - $(date -d "19800106" +%s))/(24*60*60*7)))
#计算gps day of week
dow=$[$((($(date -d $(date +%Y)$(date +%m)$(date +%d) +%s) - $(date -d "19800106" +%s))/(24*60*60)))-$week*7]
#########计算前1天的########
#dow=$[$dow-1]
#week=1938
#dow=5
#下载预报星历
cd $path/test/igs
for igutime in 00 06 12 18
do
wget ftp://cddis.gsfc.nasa.gov/pub/gps/products/$week/igu${week}${dow}_${igutime}.sp3.Z
uncompress igu${week}${dow}_${igutime}.sp3.Z
done

cd $path/test
#gamit解算
sh_setup -yr 20${year}
cd tables
sh_upd_stnfo -l sd
mv station.info.new station.info
sed -i '8,$d' station.info
sh_upd_stnfo -files ../rinex/*.${year}o
cd ..
sh_gamit -expt test -d 20${year} ${doyy} -orbit IGSU -copt x k p -dopts c ao 

#获取当前系统时间(时、分)
time=$(date +%H%M)

#剪切文件并重命名
mv $path/test/${doyy}/otesta.${doyy} $path/result/otesta${time}.${doyy}
mv $path/test/${doyy}/qtesta.${doyy} $path/result/qtesta${time}.${doyy}
mv $path/test/${doyy}/htesta.${year}${doyy} $path/result/htesta${time}.${year}${doyy}
#删除test文件
#rm -rf $path/test


:<<!

while true
do
#当时间是5的倍数时，跳出循环
while true
do
# 10#转换为十进制
minute=10#$(date +%M)
if [ $(($minute%5)) = '0' ]
then
echo "start"
break
fi
#每隔一分钟进行一次循环
sleep 60
done

#程序需要在/home/mao文件下有一个result文件夹，星历、导航电文、o文件放在zzaa下
mkdir /home/mao/test
cp -a /home/mao/zzaa/* /home/mao/test
#遍历文件夹下目录
folder="/home/mao/test/rinex"
for file in ${folder}/*;
do
filename=`basename $file`
echo $filename
done
#截取字符串，获得年份和年积日
year=${filename:0-3:2}
mdoy=${filename:0-8:3}
echo ${year}
echo ${mdoy}

cd test

#gamit解算
sh_setup -yr 20${year}
cd tables
sh_upd_stnfo -l sd
mv station.info.new station.info
sed -i '8,$d' station.info
sh_upd_stnfo -files ../rinex/*.${year}o
cd ..
sh_gamit -expt test -d 20${year} ${mdoy} -orbit IGSR -copt x k p -dopts c ao 

cd ..

#获取当前系统时间(时、分)
time=$(date +%H%M)

#剪切文件并重命名
mv /home/mao/test/${mdoy}/otesta.${mdoy} /home/mao/result/otesta${time}.${mdoy}
mv /home/mao/test/${mdoy}/qtesta.${mdoy} /home/mao/result/qtesta${time}.${mdoy}
mv /home/mao/test/${mdoy}/htesta.${year}${mdoy} /home/mao/result/htesta${time}.${year}${mdoy}
#删除test文件
rm -rf /home/mao/test

#sleep 300
done
!
