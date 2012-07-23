require 'rest_client'
require 'fileutils'
require 'json'

class Callback
  
  @@ivs = [:url]
  @@ivs.each { |v| attr_accessor v }
  
  def verbose
    @verbose=true
    self
  end

  def log(message)
    puts message if @verbose
  end

  def log_fail(message)
    puts message if @verbose
    fail message
  end
  
  def open_logs()
    if @verbose
      $stdout.reopen 'logs/callback.log'
      $stderr.reopen 'logs/callback.log'    
    end
  end
  
  def initialize(data={})
    data.each do |k,v|
      self.instance_variable_set("@#{k}", v) if @@ivs.include?(k.to_sym)
    end
    @pid = 0
    @verbose = false    
  end
  
  def post_to_server(data)
    10.times do 
      begin
        response = RestClient.post @url, data
      rescue Exception => e
        log "Connection failed : #{e.message}"
        sleep 6
        next
      end
      if response.code == 200 && response.body == "accepted"
        return
      else
        log_fail "Incorrect server response #{response.code}: #{response.body}"
      end
    end
    log_fail "Timeout: Unable to contact server"
  end
    
  def run(data)
    open_logs()    
    log "Running callback"
    if @url.match('^https{0,1}://')
      post_to_server(data)
    end
  end

  def call(data)
    @pid = fork { run(data); Kernel.exit! }
    Process.detach(@pid)
  end

end


