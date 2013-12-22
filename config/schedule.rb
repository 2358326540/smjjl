env :PATH, ENV['PATH']
set :output, "log/cron_log.log"
set :job_template, "bash -l -c ':job'"

# 抓取id
every :day, :at => '1:00am', :roles => [:master] do
  rake "daemon:get_id"
end

# 更新内容
every :day, :at => '4:00am', :roles => [:master] do
  rake "daemon:update_content"
end

# 抓取价格
every '0 8,14,20 * * *', :roles => [:master] do
  rake "daemon:update_price"
end

# 每小时清空log
every '10 * * * *', :roles => [:master] do
  command "> log/production.log"
end

# 每小时零10分重启worker服务
every '10 * * * *', :roles => [:worker] do
  rake "sidekiq:restart"
end