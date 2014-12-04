class Note < ActiveRecord::Base
  belongs_to :sequence

  def start
    return self.bar * self.sequence.meter_bottom + self.beat
  end
end
