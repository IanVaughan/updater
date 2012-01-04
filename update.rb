require 'rubygems'
require 'sinatra'

helpers do
  def run_update(version, user, host, params)
    @dir = ""
    if version != "-" then # begins with number then set dir releases  !version.nil?
      @dir = "/project/releases/#{version}"
    elsif user != "-" then # begins with letter then set dir users   !user.nil?
      @dir = "/project/users/#{user}/Head"
    end

    param = ""
    params.each {|a| param << a + " "} if !params.nil?

    command = "./update.sh #{param.chop} -h=#{host}"

    cmd = "ssh root@192.168.109.2 \". ~/.bash_profile; cd #{@dir}; #{command}\" > sw_results.txt"
    system(cmd)
  end

  def get_dir_list(dir)
    cmd = "ssh root@192.168.109.2 \"ls #{dir};\" > tmp.txt"
    ok = system(cmd)
    if ok then
      list = File.open('tmp.txt').readlines
      ret_list = []
      list.each {|item| ret_list << item.chop}
      ret_list
    else
      ["error"]
    end
   
  end

  def get_users
    get_dir_list ("/project/users")
  end

  def get_releases
    get_dir_list ("/project/releases")
  end

  def get_hosts
    ["system1", "system2", "rig1"]
  end

  def get_ips(host)
    # really bad/lazy,
    # but could ssh onto build,
    # run "source /root/hosts.sh host",
    # "env | grep HOST_ECM_IP",
    # extract IP : from "HOST_ECM_IP=192.168.109.10"
    # but not going to
    if "#{host}".upcase == "SYSTEM1"
      ["192.168.109.10", "192.168.109.11"]
    elsif "#{host}".upcase == "SYSTEM2"
      ["192.168.109.20", "192.168.109.21"]
    elsif "#{host}".upcase == "RIG1"
      ["192.168.109.5", "192.168.109.5"]
    end

    #ssh root@192.168.109.2 ". /root/hosts.sh ${host} > /dev/null; env | grep HOST_ECM_IP | sed 's/.*=//g' "
    #ssh root@192.168.109.2 ". /root/hosts.sh ${host} > /dev/null; env | grep HOST_TG_IP | sed 's/.*=//g' "
  end

  def get_cal_files
    get_dir_list ("/project/cal/Software/Calibration")
  end

  def set_cal(host, files)
    ips = get_ips(host)
    command = "cd /project/cal/Software/;"
    command += "/project/cal/Software/UpdaterUseOnly.sh #{ips[1]} #{files}"
    cmd = "ssh root@192.168.109.2 \"#{command}\" > cal_results.txt"
    puts "#{cmd}"
    system(cmd)
  end

  def get_override_files
    get_dir_list ("/project/cal/Software/overrides")
  end

end


get '/' do
  @versions = get_releases
  @users = get_users
  @hosts = get_hosts
  @cal_names = ["BCU1", "BCU2", "TRA", "HPA"]
  @cal_files = get_cal_files
  @override_filelist = get_override_files
  erb :index
end

get '/version' do
  @sw_update_ok = false
  @cal_update_ok = false
  system('rm -f sw_results.txt cal_results.txt')
  system('touch sw_results.txt cal_results.txt')
  puts params
  if params[:update_host] == "1"
    param_list = ['-c']
    puts "Run update"
    @sw_update_ok = run_update(params[:version_list], params[:user_list], params[:host], param_list)
    puts "update done"
  end
  if params[:update_cal] == '1'
    puts "Run cal"
    @cal_update_ok = set_cal(params[:host], params[:BCU1_cal_list] << " " << params[:BCU2_cal_list] << " " << params[:TRA_cal_list] << " " << params[:HPA_cal_list])
    puts "cal done"
  end
  @sw_results_file = File.open("sw_results.txt").readlines
  @cal_results_file = File.open("cal_results.txt").readlines
  @hosts = get_ips(params[:host])
  @build_file = "file://///192.168.109.2/#{@dir}/build/Linux-i686/ReleaseAll.txt"
  erb :done
end

#get '/version/:version' do
#  "get version #{params[:version]}"
#end

#get '/version/*/host/*' do
  # matches /version/hello/host/world
  # params[:splat] # => ["hello", "world"]
#end
