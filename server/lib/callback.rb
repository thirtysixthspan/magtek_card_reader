require 'rest_client'
require 'fileutils'
require 'json'
require './lib/signature'

class Callback
  
  @@ivs = [:url, :title, :passphrase]
  @@ivs.each { |v| attr_accessor v }
  
  def verbose
    @verbose=true
    self
  end

  def log(message)
    time = Time.now.strftime("%Y-%m-%d %H:%M")
    puts "[#{time}] #{message}" if @verbose
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
    signed_query = add_signature({:data => data},@passphrase)
    
    3.times do |t|
      begin
        response = RestClient.post @url, signed_query
      rescue Exception => e
        log "Connection failed : #{e.message}"
        sleep t
        next
      end
      params = JSON.parse(response.body) if response.code == 200 
      if response.code == 200 && 
         params.include?('status') && 
         params['status'] == 'swipe accepted'                 
        log "Correct server response"
        return true
      else
        log "Incorrect server response #{response.code}: #{response.body}"
        next
      end
    end
    log "Timeout: Unable to successfully communicate with server"
    return false
  end
    
  def run(data)
    open_logs()    
    log "Running callback"
    post_to_server(data) if @url.match('^https{0,1}://')
  end

  def call(data)
    begin
      log "Running Callback"
      run(data)
    rescue
      log "Callback Failed"
    end  
  end

end


