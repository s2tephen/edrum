class SequencesController < ApplicationController
  include ActionController::Live
  before_action :set_sequence, only: [:show, :edit, :update, :destroy, :practice, :start_practice, :compose, :compose_receive, :start_compose]

  # GET /sequences
  # GET /sequences.json
  def index
    @sequences = Sequence.all
    @sequence = Sequence.new # for add form
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
        if not @sequence.bpm
          format.html { redirect_to action: 'index', notice: 'Sequence was successfully created.' }
          format.json { render :index, status: :created, location: @sequence }
          @sequence.create_notes
        else
          format.html { redirect_to action: 'compose', id: @sequence.id, notice: 'Sequence ready to compose.' }
          format.json { render :compose, status: :created, location: @sequence }
        end
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
    notes = @sequence.notes
    @sequence.destroy
    respond_to do |format|
      format.html { redirect_to sequences_url, notice: 'Sequence was successfully destroyed.' }
      format.json { head :no_content }
      notes.each do |n|
        n.destroy
      end
    end
  end

  # GET /sequences/1
  # GET /sequences/1.json
  def practice
  end

  def start_practice
    if params[:demoMode]
      mode = 0 #DEMO mode
    elsif params[:enableStepByStep] and not params[:enableLoop]
      mode = 1  #STEP BY STEP
    elsif not params[:enableLoop]
      mode = 2 #PRACTICE
    elsif params[:enableLoop] and params[:enableStepByStep]
      mode = 3 #STEP BY STEP LOOP
    elsif params[:enableLoop]
      mode = 4 #PRACTICE LOOP
    end
    puts "MODE:**********", mode

    if params[:enableSticking]
      sticking = 1
    else
      sticking = 0
    end

    @sequence.start_seq(mode, params[:playBPM].to_i, sticking)  #@sequence.bpm) cant use this until high speed lights issue fixed
    render :nothing => true
  end

  def compose
  end

  def start_compose
    @sequence.start_seq(5,1,0);
    render :nothing => true
  end

  def compose_receive
    @sequence = Sequence.find_by_id(params[:id])

    @sequence.notes.each do |n|
      n.destroy
    end
    notes = []

    hits = params[:hits]
    hits.each do |hit|
      total_beat = (@sequence.bpm*hit[:start].to_i/60000).floor
      puts "total_beat****#{total_beat}"
      note_bar = (total_beat/@sequence.meter_bottom).floor
      note_beat = total_beat % @sequence.meter_bottom
      notes << Note.create(:drum => hit[:drum], :bar => note_bar, :beat => note_beat, :sequence_id => @sequence.id, :duration => 0.25)
    end

    @sequence.end_compose()
    render :nothing => true
  end

  # GET /serial
  def serial
    response.headers['Content-Type'] = 'text/event-stream'

    redis = Redis.new
    redis.subscribe('messages.create') do |on|
      on.message do |event, data|
        response.stream.write("data: #{data}\n\n")
      end
    end
  rescue IOError
  ensure
    redis.quit
    response.stream.close
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_sequence
      @sequence = Sequence.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def sequence_params
      params.require(:sequence).permit(:title, :artist, :default_bpm, :meter_top, :meter_bottom, :bars, :file)
    end
end
