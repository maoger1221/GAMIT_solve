#!/bin/bash

while true
do
#当时间是5的倍数时，跳出循环
while true
do
minute=$(date +%M)
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

