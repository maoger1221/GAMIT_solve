#!/bin/bash

#先获取日期时间，根据时间update gamit文件
year=$((10#$(date +%y)))
month=$((10#$(date +%m)))
day=$((10#$(date +%d)))
hour=$((10#$(date +%H)))
#有时更新不好使nutabl,soltab,luntab没更新
./gamit_upd_table.sh -f 20$year $month $day
echo "update${year}:${month}:${day}">>/home/mao/automaticSolution/startedLog

