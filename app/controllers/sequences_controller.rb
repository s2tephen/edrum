class SequencesController < ApplicationController
  include ActionController::Live
  before_action :set_sequence, only: [:show, :edit, :update, :destroy, :learn]

  # GET /sequences
  # GET /sequences.json
  def index
    @sequences = Sequence.all
  end

  # GET /sequences/1
  # GET /sequences/1.json
  def show
  end

  # GET /sequences/new
  def new
    @sequence = Sequence.new
  end

  # GET /sequences/1/edit
  def edit
  end

  # POST /sequences
  # POST /sequences.json
  def create
    @sequence = Sequence.new(sequence_params)

    respond_to do |format|
      if @sequence.save
        format.html { redirect_to @sequence, notice: 'Sequence was successfully created.' }
        format.json { render :show, status: :created, location: @sequence }
      else
        format.html { render :new }
        format.json { render json: @sequence.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /sequences/1
  # PATCH/PUT /sequences/1.json
  def update
    respond_to do |format|
      if @sequence.update(sequence_params)
        format.html { redirect_to @sequence, notice: 'Sequence was successfully updated.' }
        format.json { render :show, status: :ok, location: @sequence }
      else
        format.html { render :edit }
        format.json { render json: @sequence.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /sequences/1
  # DELETE /sequences/1.json
  def destroy
    @sequence.destroy
    respond_to do |format|
      format.html { redirect_to sequences_url, notice: 'Sequence was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # GET /sequences/1
  # GET /sequences/1.json
  def learn
    puts @sequence.notes
  end

  # GET /serial
  def serial
    response.headers['Content-Type'] = 'text/event-stream'

    port_str = '/dev/tty.usbmodem1411'
    baud_rate = 115200
    data_bits = 8
    stop_bits = 1
    parity = SerialPort::NONE
    sp = SerialPort.new(port_str, baud_rate, data_bits, stop_bits, parity)

    buf = ''
    while true do
      if (o = sp.gets)
        buf << o
        if buf.include? ']'
          puts 'mcu> '+ buf.strip
          if buf.include? '[e]'
            sp.flush
            break
          else
            hit = buf.strip[3..-2].split(',')
            response.stream.write "data: {\"drum\": " + hit[0] + ", \"start\": " + hit[1] + "}\n\n"
          end
          buf = ''
        end
      end
    end

    # simulate arduino input
    # 1000.times do |n|
    #   drum = rand(8).to_s
    #   start = n.to_s
    #   puts 'mcu> [h:' + drum + ',' + start + ']'

    #   hit = [drum, start]
    #   response.stream.write "data: {\"drum\": " + hit[0] + ", \"start\": " + hit[1] + "}\n\n"
    #   sleep 0.5
    # end
  rescue IOError
  ensure
    # sp.close
    response.stream.close
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_sequence
      @sequence = Sequence.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def sequence_params
      params.require(:sequence).permit(:title, :artist, :default_bpm, :meter_top, :meter_bottom, :time, :buffer)
    end
end
