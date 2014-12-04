class Sequence < ActiveRecord::Base
  has_many :notes
  has_many :sessions

  attr_accessor :input

  mount_uploader :file, FileUploader

  def create_notes
    self.notes.each do |n|
      n.destroy
    end

    mapping = {35 => 7, 36 => 7, 38 => 5, 40 => 5, 42 => 1, 44 => 1, 46 => 1, 49 => 0, 57 => 0, 52 => 0,
               55 => 0, 51 => 2, 53 => 2, 59 => 2, 41 => 6, 43 => 6, 45 => 6, 47 => 4, 48 => 3, 50 => 3 }

    # open sequence
    note_sequence = []
    info_array = []
    seq = MIDI::Sequence.new()

    File.open(File.join(Rails.root, 'public', self.file.to_s), 'rb') { |f|
      seq.read(f)
    }

    # get notes and time signature
    seq.tracks.each do |t|
      info_array.concat t.events.select {|e| e.class == MIDI::NoteOn}
      if t.events.select {|e| e.class == MIDI::TimeSig}.any?
        self.meter_top = t.events.select {|e| e.class == MIDI::TimeSig}.first.data[0]
        self.meter_bottom = 2**t.events.select {|e| e.class == MIDI::TimeSig}.first.data[1]
      end
    end

    info_array.each do |n|
      note_drum = mapping[n.note]
      note_duration = (n.off.time_from_start - n.time_from_start) / seq.ppqn.to_f * (meter_bottom / 4.to_f)
      
      note_bar = ((n.time_from_start / seq.ppqn.to_f) * (self.meter_bottom / 4.to_f) / self.meter_top).floor
      note_beat = (n.time_from_start / seq.ppqn.to_f) * (self.meter_bottom / 4.to_f) % self.meter_top

      new_note = Note.create(:drum => note_drum, :duration => note_duration.round(2), :bar => note_bar, :beat => note_beat, :sequence_id => self.id)

      note_sequence.push(new_note)
    end

    self.bars = self.notes.select(:bar).distinct.length
    self.save

    return note_sequence
  end

  # def start_seq(mode, action, bpm)
  def start_seq(mode, bpm)
    new_session = Session.create(:sequence_id => self.id, :user_id => 1)
    seq_length = self.notes.select('bar, beat').distinct.length

    # create tracks/lengths
    beats = []
    track1 = '[t:'
    track2 = '[t:'
    track3 = '[t:'
    lengths = '[l:'

    self.notes.select('bar, beat').distinct.each do |s|
      beats << self.notes.where(:bar => s.bar, :beat => s.beat)
    end

    if self.notes.first.hand.nil?
      for i in 0..(beats.length - 1)
        to_add = beats[i]

        (3 - beats[i].length).times do
          to_add << nil
        end

        if !to_add[0].nil?
          track1 << to_add[0].drum.to_s << ','
        else
          track1 << '-1,'
        end
        if !to_add[1].nil?
          track2 << to_add[1].drum.to_s << ','
        else
          track2 << '-1,'
        end
        if !to_add[2].nil?
          track3 << to_add[2].drum.to_s << ','
        else
          track3 << '-1,'
        end

        note1 = beats[i].first
        lengths << (note1.start.to_f / bpm * 60000).to_i.to_s << ','

        if i != beats.length - 1
          note2 = beats[i+1].first

          # add a rest to fill the gap between 
          if beats[i+1].any? && note1.start + note1.duration < note2.start
            lengths << ((note1.start + note1.duration).to_f / bpm * 60000).to_i.to_s << ','
            track1 << '-1,'
            track2 << '-1,'
            track3 << '-1,'
          end
        end
      end
    end

    # else
    #   for i in 0..seq_length - 1
    #     if beats[i].where(:hand => 'left').any?
    #       track1 << beats[i].where(:hand => 'left').drum.to_s << ','
    #     else
    #       track1 << '-1,'
    #     end

    #     if beats[i].where(:hand => 'right').any?
    #       track2 << beats[i].where(:hand => 'right').drum.to_s << ','
    #     else
    #       track2 << '-1,'
    #     end

    #     if beats[i].where(:hand => 'foot').any?
    #       track1 << beats[i].where(:hand => 'foot').drum.to_s << ','
    #     else
    #       track3 << '-1,'
    #     end

    #     if i == beats.length - 1
    #       lengths << beats[i].first.duration.to_s << ','
    #     else
    #       note1 = beats[i].first
    #       note2 = beats[i+1].first

    #       if beats[i+1].empty?
    #         lengths << note1.duration.to_s << ','
    #       elsif note1.start + note1.duration >= note2.start
    #         # truncate the note at the start of the next note
    #         lengths << (note2.start - note1.start).to_s << ','
    #       else
    #         # add a rest to fill the gap
    #         lengths << beats[i].first.duration.to_s << ',' << (note2.start - (note1.start + note1.duration)).to_s << ','
    #         track1 << '-1,'
    #         track2 << '-1,'
    #         track3 << '-1,'
    #       end
    #     end
    #   end
    # end

    metadata = '[m:' << mode.to_s << ',' << track1.count(',').to_s << ']'

    track1[-1], track2[-1], track3[-1], lengths[-1] = ']', ']', ']', ']'
    # lengths = '[l:' << ([1]*track1.count(',')).to_s.gsub!(/\s+/,'')[1..-1]

    seq = [metadata, track1, track2, track3, lengths]

    puts seq

    # write sequence to serial
    sp = SerialPort.new('/dev/tty.usbmodem1411', 115200, 8, 1, SerialPort::NONE)
    sp.sync = true
    
    seq.each do |i|
      puts 'app> ' + i.strip
      sp.write i.strip
      sleep 0.1
    end

    sp.flush

    buf = ''
    while true do
      if (o = sp.gets)
        sp.flush
        buf << o
        if buf.include? ']'
          input = buf.slice!(buf.index('['), buf.index(']') + 1)
          puts 'mcu> '+ input
          if input.include? '[e'
            sp.close
            break
          elsif input.include? '[h'
            hit = input.strip[3..-2].split(',')
            message = {:drum => hit[0], :start => hit[1], :correct => hit[2]}
            $redis.publish('messages.create', message.to_json)
          end
          input = ''
        end
      end
    end

    sp.close

    return seq
  end
end
