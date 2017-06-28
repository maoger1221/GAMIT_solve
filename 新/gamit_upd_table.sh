#!/bin/bash -f
#脚本输入参数为项目名，年份，年积日,精密星历类型（igs，igr,igu需修改下载的igu文件格式，如igu18752_06.sp3.Z）
#./gamit_upd_table.sh -f 2017 年积日
#自动下载更新所需的tables文件
cd /  
cd ./opt/GAMIT10.5/tables   #gamit的tables更新目录
yr_4=$1;doy=$2
user="anonymous";userpasswd="jason%40ucsd.edu";host="garner.ucsd.edu/pub/gamit/tables"

if [ -e ./antmod.dat ]
then rm ./antmod.dat
fi
wget -c -T 20 http://${user}:${userpasswd}@${host}/antmod.dat

if [ -e ./dcb.dat ]
then rm ./dcb.dat
fi
wget -c -T 20 http://${user}:${userpasswd}@${host}/dcb.dat 

if [ -e ./hi.dat ]
then rm ./hi.dat
fi
wget -c -T 20 http://${user}:${userpasswd}@${host}/hi.dat 

if [ -e ./leap.sec ]
then rm ./leap.sec
fi
wget -c -T 20 http://${user}:${userpasswd}@${host}/leap.sec

if [ -e ./luntab.${yr_4}.J2000 ]
then rm ./luntab.${yr_4}.J2000 
fi
wget -c -T 20 http://${user}:${userpasswd}@${host}/luntab.${yr_4}.J2000 

if [ -e ./nutabl.${yr_4} ]
then rm ./nutabl.${yr_4}
fi
wget -c -T 20 http://${user}:${userpasswd}@${host}/nutabl.${yr_4} 

if [ -e ./pole.usno ]
then rm ./pole.usno
fi
wget -c -T 20 http://${user}:${userpasswd}@${host}/pole.usno 

if [ -e ./rcvant.dat ]
then rm ./rcvant.dat
fi
wget -c -T 20 http://${user}:${userpasswd}@${host}/rcvant.dat

if [ -e ./soltab.${yr_4}.J2000 ]
then rm ./soltab.${yr_4}.J2000
fi
wget -c -T 20 http://${user}:${userpasswd}@${host}/soltab.${yr_4}.J2000

if [ -e ./svnav.dat ]
then rm ./svnav.dat
fi
wget -c -T 20 http://${user}:${userpasswd}@${host}/svnav.dat 

if [ -e ./ut1.usno ]
then rm ./ut1.usno
fi
wget -c -T 20 http://${user}:${userpasswd}@${host}/ut1.usno 

if [ -e ./svs_exclude.dat ]
then rm ./svs_exclude.dat
fi
wget -c -T 20 http://${user}:${userpasswd}@garner.ucsd.edu/pub/gamit/setup/svs_exclude.dat



