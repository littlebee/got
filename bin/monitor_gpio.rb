require 'pi_piper'
include PiPiper

pins = [4, 17, 18, 22, 23, 24, 25, 27]

for pinNum in pins do
  watch :pin => pinNum do

    puts "Pin #{pin} changed from #{last_value} to #{value}"
  end
end

PiPiper.wait

