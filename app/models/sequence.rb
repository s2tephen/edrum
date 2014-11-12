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
		note_duration = (n.off.time_from_start - n.time_from_start) + 1
		n.time_from_start
		# TODO: test these for a variety of time signatures
		note_bar = ((n.time_from_start / seq.ppqn) * (self.meter_bottom / 4) / self.meter_top).floor
		note_beat = (n.time_from_start / seq.ppqn) * (self.meter_bottom / 4) % self.meter_top

		new_note = Note.create(:drum => note_drum, :duration => note_duration, :bar => note_bar, :beat => note_beat, :sequence_id => self.id)

		note_sequence.push(new_note)
	end

	return note_sequence
end

end
