require 'gibberish'
require 'json'

class CreditCard

  @@ivs = [:timestamp, 
           :name, :number, :exp_month, :exp_year, 
           :encrypted]
  @@ivs.each { |v| attr_accessor v }

  @@svs = [:rsa_key, :aes_passphrase ]
  
  def data
    { 
      :timestamp => @timestamp.to_s,
      :name => @name.to_s,
      :number => @number.to_s,
      :exp_month => @exp_month.to_s,
      :exp_year => @exp_year.to_s
    }
  end
  
  def plaintext
    JSON.dump(data)
  end
  
  def encrypt
    aes_cypher = Gibberish::AES.new(@aes_passphrase)
    aes_encrypted = aes_cypher.enc(plaintext)
    
    rsa_cipher = Gibberish::RSA.new(@rsa_key)
    @encrypted = rsa_cipher.encrypt(aes_encrypted)
  end
  
  def decrypt
    rsa_cipher = Gibberish::RSA.new(@rsa_key)
    rsa_decrypted = rsa_cipher.decrypt(@encrypted)
    
    aes_cypher = Gibberish::AES.new(@aes_passphrase)
    double_decrypted = aes_cypher.dec(rsa_decrypted)
    
    decrypted = JSON.parse(double_decrypted)
    decrypted.each do |k,v|
      self.instance_variable_set("@#{k}", v) if @@ivs.include?(k.to_sym)      
    end    
  end
  
  def initialize(data, secret)
    data.each do |k,v|
      self.instance_variable_set("@#{k}", v) if @@ivs.include?(k.to_sym)
    end
    @@svs.each do |k,v|
      if secret.include?(k)
        self.instance_variable_set("@#{k}", secret[k]) 
      else  
       raise ArgumentError, "Missing #{k}"
      end
    end
    
    if data.include?(:encrypted)
      decrypt()
    else
      encrypt()
    end
  end
  
end
  