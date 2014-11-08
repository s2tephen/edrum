class Sequence < ActiveRecord::Base
  has_many :notes
  has_many :sessions

def create_notes
	mapping = {35 => 8, 36 => 8, 38 => 6, 40 => 6, 42 => 2, 44 => 2, 46 => 2, 49 => 1, 57 => 1, 52 => 1,
			  		 55 => 1, 51 => 3, 53 => 3, 59 => 3, 41 => 7, 43 => 7, 45 => 7, 47 => 5, 48 => 4, 50 => 4 }

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
		note_duration = (n.off.time_from_start - n.time_from_start) + 1
		n.time_from_start
		# TODO: test these for a variety of time signatures
		note_bar = ((n.time_from_start / seq.ppqn) * (self.meter_bottom / 4) / self.meter_top).floor
		note_beat = (n.time_from_start / seq.ppqn) * (self.meter_bottom / 4) % self.meter_top + 1

		new_note = Note.create(:drum => note_drum, :duration => note_duration, :bar => note_bar, :beat => note_beat)
		
		note_sequence.push(new_note)
	end

	return note_sequence
end

end
