#!/bin/sh
#此文件被cron 调用，检查unicorn 服务是否存在，不存在则会自动启动，注意更改文件权限（可执行）

count=`ps -fe|grep 'unicorn worker'|grep -v grep| wc -l`
#echo "--------------$count"
if [ $count -eq 0 ]
then
  echo "--------already stop-"
  cd /home/deployer/apps/robin8/current && RBENV_ROOT=~/.rbenv RBENV_VERSION= ~/.rbenv/bin/rbenv exec bundle exec unicorn -c /home/deployer/apps/robin8/current/config/unicorn/production.rb -E production -D
  now=`date  +%Y-%m-%d[%H:%M:%S]`
  echo "at $now start cdnclient -b /n"
else
  echo "---- running"
fi
