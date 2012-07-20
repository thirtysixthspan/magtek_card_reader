require 'gibberish'

def verify_signature(data, passphrase)
  test = data.clone
  test[:passphrase] = passphrase
  sha512 = test[:sha512]
  test.delete(:sha512)
  fail "Tampering detected." unless Gibberish::SHA512(test.sort.to_s) == sha512
  true
end

def add_signature(data, passphrase, originator = nil)
  signed = data.clone
  signed.delete(:sha512)
  signed[:passphrase] = passphrase
  signed[:timestamp] = Time.now.to_i.to_s
  signed[:originator] = originator if originator
  signed[:sha512] = Gibberish::SHA512(signed.sort.to_s)
  signed.delete(:passphrase)
  signed
end
