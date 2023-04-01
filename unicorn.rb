# rootパスのディレクトリを指定
root_path = File.expand_path('../../', __FILE__)
# root_path = "/var/rails/APIsnowresort"
# アプリケーションサーバの性能を決定する
worker_processes 2
# アプリケーションの設置されているディレクトリを指定
working_directory root_path
# プロセスIDの保存先を指定
pid "#{root_path}/tmp/pids/unicorn.pid"
# ポート番号を指定
listen "#{root_path}/tmp/sockets/unicorn.sock"
# エラーのログを記録するファイルを指定
stderr_path "#{root_path}/log/unicorn.stderr.log"
# 通常のログを記録するファイルを指定
stdout_path "#{root_path}/log/unicorn.stdout.log"
#応答時間を待つ上限時間を設定
timeout 2000
# ダウンタイムなしでUnicornを再起動時する
preload_app true

GC.respond_to?(:copy_on_write_friendly=) && GC.copy_on_write_friendly = true

check_client_connection false

run_once = true

before_fork do |server, worker|
  defined?(ActiveRecord::Base) &&
    ActiveRecord::Base.connection.disconnect!

  if run_once
    run_once = false # prevent from firing again
  end

  old_pid = "#{server.config[:pid]}.oldbin"
  if File.exist?(old_pid) && server.pid != old_pid
    begin
      sig = (worker.nr + 1) >= server.worker_processes ? :QUIT : :TTOU
      Process.kill(sig, File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH => e
      logger.error e
    end
  end
end

after_fork do |_server, _worker|
  defined?(ActiveRecord::Base) && ActiveRecord::Base.establish_connection
end


















# $worker  = 2
# $timeout = 30
# $app_dir = "/var/rails/APIsnowresort"
# $listen  = File.expand_path 'tmp/sockets/.unicorn.sock', $app_dir
# $pid     = File.expand_path 'tmp/pids/unicorn.pid', $app_dir
# $std_log = File.expand_path 'log/unicorn.log', $app_dir
# # set config
# worker_processes  $worker
# working_directory $app_dir
# stderr_path $std_log
# stdout_path $std_log
# timeout $timeout
# listen  $listen
# pid $pid
# # loading booster
# preload_app true
# # before starting processes
# before_fork do |server, worker|
#   defined?(ActiveRecord::Base) and ActiveRecord::Base.connection.disconnect!
#   old_pid = "#{server.config[:pid]}.oldbin"
#   if old_pid != server.pid
#     begin
#       Process.kill "QUIT", File.read(old_pid).to_i
#     rescue Errno::ENOENT, Errno::ESRCH
#     end
#   end
# end
# # after finishing processes
# after_fork do |server, worker|
#   defined?(ActiveRecord::Base) and ActiveRecord::Base.establish_connection
# end