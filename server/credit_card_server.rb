#!/usr/bin/env ruby

require 'yaml'
require 'fileutils'
require 'pp'
require 'fileutils'
require 'magtek_card_reader'
require './lib/callback.rb'
require './lib/credit_card.rb'
require './lib/signature.rb'

class CreditCardServer

  def verbose
    @verbose=true
  end

  def log(message)
    time = Time.now.strftime("%Y-%m-%d %H:%M")
    puts "[#{time}] #{message}" if @verbose
  end
  
  def write_pid
    File.open(@pid_file, 'w') { |f| f.write Process.pid }
    Kernel.at_exit { FileUtils.rm @pid_file }
  end
  
  def initialize
    @pid_file = "pids/ccs.pid"
    @verbose = false
    @logfile = 'logs/ccs.log'
    @errorfile = 'logs/ccs.error'
    @callbacks = []
    
    @mcr = Magtek::CardReader.new
    fail "Cannot open card reader" unless @mcr.open
    Kernel.at_exit { @mcr.close }
  end

  def open_logs()
    FileUtils.touch(@logfile)
    FileUtils.touch(@errorfile)
    $stdout.reopen @logfile, "a"
    $stdout.sync=true
    $stderr.reopen @errorfile, "a"
    $stderr.sync=true
  end 
  
  def load_callbacks()
    fail "Cannot find callback configuration file" unless File.exists?('conf/callbacks.yaml')
    callbacks = YAML.load(File.open('conf/callbacks.yaml'))
    verify_signature(callbacks,@aes_passphrase)
    callbacks.each do |key,value|
      next if [:timestamp,:sha512,:originator].include?(key)
      callback = {
        :title => key,
        :url => value,
        :passphrase => @aes_passphrase
      }
      puts "Configuring callback #{callback['url']} on #{callback['title']}"
      @callbacks << Callback.new(callback)
    end
  end
  
  def load_secret()
    fail "Cannot find secret configuration file" unless File.exists?('conf/secret.yaml')
    secret = YAML.load(File.open('conf/secret.yaml'))
    verify_signature(secret,@aes_passphrase)
    @enc_secret = { 
      :aes_passphrase => @aes_passphrase,
      :rsa_key => secret[:rsa_public_key]
    }
  end  
  
  def read_card()
    success, number, name, exp_year, exp_month =  @mcr.read(:timeout=>0)
    return false unless success
    return false if Time.now.year.to_i > exp_year.to_i+2000
    return false if Time.now.year.to_i == exp_year.to_i+2000 && Time.now.month.to_i > exp_month.to_i

    data = {
      :timestamp => Time.now.to_i.to_s,
      :name => name,
      :number => number,
      :exp_month => exp_month,
      :exp_year => exp_year
    }
    CreditCard.new( data, @enc_secret )
  end  
    
  def run_callbacks(data)    
    @callbacks.each do |callback|    
      log "Running Callback: #{callback.title}"
      callback.call(data)
    end
  end
   
  def check_for_private
    if File.exists?("conf/private.yaml")
      fail "conf/private.yaml exists! Please move to another computer for maximum security."
    end  
  end
  
  def ask(question)
    print question
    STDIN.gets.chomp
  end  
  
  def start
    check_for_private()
    @aes_passphrase = ask('Please enter your passphrase to start the server: ')
    
    pid=fork do   
      log "Credit Card Server Started"
      open_logs()
      write_pid()
      load_callbacks()
      load_secret()
      loop do
        open_logs()
        data = read_card()
        run_callbacks(data)  
      end  
    end
    Process.detach(pid)
  end 

end  

raise "You must be root to run this script - try rvmsudo #{__FILE__}" unless (Process.euid==0)

ccs = CreditCardServer.new()
ccs.start



