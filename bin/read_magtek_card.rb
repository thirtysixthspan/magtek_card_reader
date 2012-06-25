#! /usr/bin/env ruby

require 'magtek_card_reader'

mcr = Magtek::CardReader.new

success = mcr.open

fail "Cannot open card reader" unless success

puts "Please swipe a card now."

success, number, name, exp_year, exp_month =  mcr.read(:timeout=>0)

mcr.close

if success
  puts "Name: #{name}"
  puts "Card number: #{number}"
  puts "Expiration Date: #{exp_month}/#{exp_year}"
else
  fail "Card not read."
end