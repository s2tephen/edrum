class Sequence < ActiveRecord::Base
  has_many :notes
  has_many :sessions

  attr_accessor :input

  mount_uploader :midi, MidiUploader

  def create_notes
    mapping = {35 => 7, 36 => 7, 38 => 5, 40 => 5, 42 => 1, 44 => 1, 46 => 1, 49 => 0, 57 => 0, 52 => 0,
               55 => 0, 51 => 2, 53 => 2, 59 => 2, 41 => 6, 43 => 6, 45 => 6, 47 => 4, 48 => 3, 50 => 3 }

    # open sequence
    note_sequence = []
    seq = MIDI::Sequence.new()
    File.open(self.midi.file.file) { |f|
        seq.read(f)
    }

    # find sequence of notes from when they turn on
    info_array = seq.tracks.last.events.select {|e| e.class == MIDI::NoteOn}

    # get the meter of the music piece
    self.meter_top = seq.tracks.first.events.select{|a| a.class == MIDI::TimeSig}.first.data[0]
    self.meter_bottom = 2**seq.tracks.first.events.select{|a| a.class == MIDI::TimeSig}.first.data[1]

    info_array.each do |n|
      note_drum = mapping[n.note]
      note_duration = ((n.off.time_from_start - n.time_from_start) + 1) / seq.ppqn.to_f * (self.meter_bottom / 4.to_f)
      
      note_bar = ((n.time_from_start / seq.ppqn.to_f) * (self.meter_bottom / 4.to_f) / self.meter_top).floor
      note_beat = ((n.time_from_start / seq.ppqn.to_f) * (self.meter_bottom / 4.to_f) % self.meter_top).floor

      new_note = Note.create(:drum => note_drum, :duration => note_duration, :bar => note_bar, :beat => note_beat, :sequence_id => self.id)

      note_sequence.push(new_note)
    end

    return note_sequence
  end

  def start_seq(mode, action, bpm)
    # create metadata
    metadata = '[m:'

    if mode == 'learn'
      metadata << '0,'
    elsif mode == 'practice'
      metadata << '1,'
    elsif mode == 'compose'
      metadata << '2,'
    else
      return nil
    end

    if action == 'play'
      metadata << '0,'
    elsif action == 'listen'
      metadata << '1,'
    else
      return nil
    end

    length = self.notes.last.bar * self.meter_top + self.notes.last.beat
    metadata << bpm.to_s << ',' << length.to_s << ']'

    # create tracks/lengths
    track1 = '[t:'
    track2 = '[t:'
    track3 = '[t:'
    lengths = '[l:'

    length.times do |i|
      notes_at_beat = self.notes.where(:bar => (i / self.meter_top).floor, :beat => i % self.meter_top)
      (3 - notes_at_beat.length).times do
        notes_at_beat << nil
      end

      if notes_at_beat[0].nil?
        track1 << '-1,'
        lengths << '1,'
      else
        track1 << notes_at_beat[0].drum.to_s << ','
        lengths << [notes_at_beat[0], notes_at_beat[1], notes_at_beat[2]].compact.map { |n| n.duration }.min.to_s << ','
      end

      if notes_at_beat[1].nil?
        track2 << '-1,'
      else
        track2 << notes_at_beat[1].drum.to_s << ','
      end

      if notes_at_beat[2].nil?
        track3 << '-1,'
      else
        track3 << notes_at_beat[2].drum.to_s << ','
      end
    end

    track1[-1], track2[-1], track3[-1], lengths[-1] = ']', ']', ']', ']'
    seq = [metadata, track1, track2, track3, lengths]

    # write sequence to serial
    sp = SerialPort.new('/dev/tty.usbserial-14P50042', 115200, 8, 1, SerialPort::NONE)
    
    seq.each do |i|
      puts 'app> ' + i
      sp.write i
    end

    sp.flush

    buf = ''
    while true do
      if (o = sp.gets)
        sp.flush
        buf << o
        if buf.include? ']'
          puts 'mcu> '+ buf.strip
          if buf.include? '[e]'
            break
          else
            hit = buf.strip[3..-2].split(',')
            message = {:drum => hit[0], :start => hit[1]}
            $redis.publish('messages.create', message.to_json)
          end
          buf = ''
        end
      end
    end

    sp.close

    return seq
  end
end
