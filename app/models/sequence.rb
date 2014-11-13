class Sequence < ActiveRecord::Base
  has_many :notes
  has_many :sessions

  def create_notes
    mapping = {35 => 7, 36 => 7, 38 => 5, 40 => 5, 42 => 1, 44 => 1, 46 => 1, 49 => 0, 57 => 0, 52 => 0,
               55 => 0, 51 => 2, 53 => 2, 59 => 2, 41 => 6, 43 => 6, 45 => 6, 47 => 4, 48 => 3, 50 => 3 }

    ### initialize empty sequence of drum notes
    note_sequence = []

    ### Create a new, empty sequence.
    seq = MIDI::Sequence.new()

    ### Read the contents of a MIDI file into the sequence.
    File.open(File.join(Rails.root, 'app', 'assets', 'midis', self.file_path), 'rb') { | file |
        seq.read(file)
    }

    ### find sequence of notes from when they turn on
    info_array = seq.tracks.first.events.select { |e| e.class == MIDI::NoteOn}

    ### get the meter of the music piece
    self.meter_top = seq.tracks.first.events.select{ |a| a.class == MIDI::TimeSig }.first.data[0]
    self.meter_bottom = 2**seq.tracks.first.events.select{ |a| a.class == MIDI::TimeSig }.first.data[1]

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
    # create header
    header = '[h:'

    if mode == 'learn'
      header << '0,'
    elsif mode == 'practice'
      header << '1,'
    elsif mode == 'compose'
      header << '2,'
    else
      return nil
    end

    if action == 'play'
      header << '0,'
    elsif action == 'listen'
      header << '1,'
    else
      return nil
    end

    length = self.notes.last.bar * self.meter_top + self.notes.last.beat
    header << bpm.to_s << ',' << length.to_s << ']'

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
    seq = [header, track1, track2, track3, lengths]

    # setup serial port
    port_str = '/dev/tty.usbmodem1411'
    baud_rate = 9600
    data_bits = 8
    stop_bits = 1
    parity = SerialPort::NONE
    sp = SerialPort.new(port_str, baud_rate, data_bits, stop_bits, parity)

    # write sequence to serial
    seq.each do |i|
      puts 'laptop> ' + i
      sp.write i
    end

    sp.flush
    sleep 3

    while (o = sp.gets.chomp) do
      puts 'arduino> '+ o
      if o == '...done.'
        break
      end
    end

    sp.close
    return seq
  end
end
