#!/usr/bin/env ruby

require 'pi_piper'
include PiPiper

MEDIA_DIR = '/home/pi/media'

MEDIA = {
  :thunder => "#{MEDIA_DIR}/thunder",
  :god => "#{MEDIA_DIR}/god"
}

PINS = {
    :thunder_button    => 17,
    :lightning_button  => 18,
    :god_button        => 27,

    :thunder_led       => 24,
    :lightning_led     => 23,
    :god_led           => 22,

    :lightning_relay_1 => 25,
    :lightning_relay_2 => 4

}

BUTTONS = {
    :thunder => PiPiper::Pin.new(:pin => PINS[:thunder_button], :direction => :in),
    :lightning => PiPiper::Pin.new(:pin => PINS[:lightning_button], :direction => :in),
    :god => PiPiper::Pin.new(:pin => PINS[:god_button], :direction => :in)
}

LEDS = {
    :thunder => PiPiper::Pin.new(:pin => PINS[:thunder_led], :direction => :out),
    :lightning => PiPiper::Pin.new(:pin => PINS[:lightning_led], :direction => :out),
    :god => PiPiper::Pin.new(:pin => PINS[:god_led], :direction => :out)
}

LIGHTNING_RELAYS = [
    PiPiper::Pin.new(:pin => PINS[:lightning_relay_1], :direction => :out),
    PiPiper::Pin.new(:pin => PINS[:lightning_relay_2], :direction => :out)
]

watch :pin => PINS[:thunder_button] do
  button_pressed :thunder if value == 0
end

watch :pin => PINS[:lightning_button] do
  button_pressed :lightning if value == 0
end

watch :pin => PINS[:god_button] do
  button_pressed :god if value == 0
end


def button_pressed which
  puts "got #{which.to_s}"
  return if handleSpecialSequence which
  flashLed which
  if which == :lightning
    sequenceLightning
  else
    playRandomFile MEDIA[which]
  end
end

def playRandomFile(dir)
  excluded = ['.', '..']
  sample = (Dir.entries(dir.to_s) - excluded).sample
  playFile File.join(dir, sample) unless sample.nil?
end

def playFile(fileName)
  command = "mpg321 #{fileName} &"
  puts "\n$ #{command}"
  system command
end

# this is an array of hashes and sleep intervals. the hashes should have key value pairs
# where the key is LIGHTNING_RELAY index to turn on if the value is :on or off if the value is :off
LIGHTNING_SEQUENCES = [
  [{0 => :on}, 0.25, {1 => :on}, 0.25, {0 => :off}, 0.5, {0 => :on}, 0.25, {0 => :off, 1 => :off}],
  [{0 => :on}, 0.5, {1 => :on}, 0.25, {0 => :off}, 0.5, {1 => :off}, 0.25, {0 => :on, 1 => :on}, 0.5, {0 => :off, 1 => :off}]
]

def sequenceLightning
  Thread.new do
    index = rand(0..LIGHTNING_SEQUENCES.length-1)
    puts "LIGHTNING_SEQUENCES[#{index}]"
    playSequence LIGHTNING_RELAYS, LIGHTNING_SEQUENCES[index]
  end
end

def playSequence pins, sequence
  sequence.each do |instruction|
    if instruction.kind_of?(Hash)
      instruction.each do |relayIndex, state|
        if relayIndex > pins.length - 1
          puts "ERROR: Relay index out of bounds. pins=#{pins.to_s}, relayIndex=#{relayIndex}, instruction=#{instruction}"
        end
        if state == :on
          puts "turning on relay #{relayIndex}"
          pins[relayIndex].on
        elsif state == :off
          puts "turning off relay #{relayIndex}"
          pins[relayIndex].off
        else
          puts "ERROR: Unrecognized lightning sequence state.  relayIndex=#{relayIndex}, instruction=#{instruction}"
        end
      end
    elsif instruction.kind_of?(Numeric)
      puts "sleeping for #{instruction} seconds"
      sleep instruction
    else
      puts "ERROR: Unrecognized sequence instruction.  pins=#{pins.to_s} relayIndex=#{relayIndex}, instruction=#{instruction}, " +
               "instruction.class=#{instruction.class}"
    end
  end

end

$previousButton = nil

def handleSpecialSequence buttonPressed
  if buttonPressed == :god && $previousButton == :lightning2
    specialSequence
    $previousButton = nil
    return true
  else
    if buttonPressed == :lightning
      if $previousButton == :lightning1
        $previousButton = :lightning2
      else
        $previousButton = :lightning1
      end
    else
      $previousButton = nil
    end
  end
  return false
end

def specialSequence
  specialLedSequence
  playFile File.join MEDIA_DIR, "special", "shitshow.mp3"
end

def specialLedSequence
  Thread.new do
    playSequence LEDS.values, [
      {0 => :off, 1 => :off, 2 => :off}, 5,
      {0 => :on, 1 => :on, 2 => :on}, 0.25,
      {0 => :off, 1 => :off, 2 => :off}, 0.25,
      {0 => :on, 1 => :on, 2 => :on}, 0.25,
      {0 => :off, 1 => :off, 2 => :off}, 0.25,
      {0 => :on, 1 => :on, 2 => :on}, 0.25,
      {0 => :off, 1 => :off, 2 => :off}, 0.25,
      {0 => :on, 1 => :on, 2 => :on}, 0.25,
      {0 => :off, 1 => :off, 2 => :off}, 0.25,
      {0 => :on}, 0.1,
      {0 => :off, 1 => :on}, 0.2,
      {1 => :off, 2 => :on}, 0.2,
      {2 => :off, 0 => :on}, 0.2,
      {0 => :off, 1 => :on}, 0.2,
      {1 => :off, 2 => :on}, 0.2,
      {2 => :off, 0 => :on}, 0.2,
      {0 => :off, 1 => :on}, 0.2,
      {1 => :off, 2 => :on}, 0.2,
      {2 => :off, 0 => :on}, 0.2,
      {0 => :off, 1 => :on}, 0.2,
      {1 => :off, 2 => :on}, 0.2,
      {2 => :off, 0 => :on}, 0.2,
      {0 => :off, 1 => :on}, 0.2,
      {1 => :off, 2 => :on}, 0.2,
      {0 => :on, 1 => :on, 2 => :on}, 0.5,
      {0 => :off, 1 => :off, 2 => :off}, 0.5,
      {0 => :on, 1 => :on, 2 => :on}, 0.5,
      {0 => :off, 1 => :off, 2 => :off}, 0.5,
      {0 => :on}, 0.1,
      {0 => :off, 1 => :on}, 0.1,
      {1 => :off, 2 => :on}, 0.1,
      {2 => :off, 0 => :on}, 0.1,
      {0 => :off, 1 => :on}, 0.1,
      {1 => :off, 2 => :on}, 0.1,
      {2 => :off, 0 => :on}, 0.1,
      {0 => :off, 1 => :on}, 0.1,
      {1 => :off, 2 => :on}, 0.1,
      {0 => :on, 1 => :on, 2 => :on}
    ]
  end
end

def flashLed(which)
  Thread.new do
    led = LEDS[which]
    puts "flashing #{which.to_s} LED"
    3.times do
      led.off
      sleep 0.5
      led.on
      sleep 0.5
    end
  end
end

playFile File.join MEDIA_DIR, "special", "godnowonline.mp3"

if ARGV.include? "--debug"
  LEDS.values.each {|led| led.off}

  LEDS.each do |name, led|
    puts "turning on #{name}"
    led.on
    sleep 5
  end
else
  LEDS.values.each {|led| led.on}
end


PiPiper.wait