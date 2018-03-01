class ActsController < ApplicationController
  before_action :set_act, only: [:show, :edit, :update, :destroy]
  respond_to :html, :json
  helper_method :sort_column, :sort_direction

  # GET /acts
  # GET /acts.json
  def index
    # @acts = ActsDatatable.new(view_context)
    # @acts = Act.where(actx: FALSE, gp_sts: 'Valid').
    #   order(sort_column + ' ' + sort_direction).
    #   paginate(:page => params[:page], :per_page => 50)

    ## Splits 'cont_any' strings into array, if string and has ','
    if !params[:q].nil?
      acts_helper = Object.new.extend(ActsHelper)
      params[:q] = acts_helper.split_ransack_params(params[:q])
    end

    @search = Act.where(gp_sts: 'Valid').ransack(params[:q])
    @acts = @search.result(distinct: true).paginate(:page => params[:page], :per_page => 50)
    respond_with(@acts)
  end

  def show
    respond_to do |format|
      format.html
      format.js
    end
  end

  def new
    @act = Act.new
  end

  def edit
  end

  def create
    @act = Act.new(act_params)
    respond_to do |format|
      if @act.save
        format.html { redirect_to @act, notice: 'Act was successfully created.' }
        format.json { render :show, status: :created, location: @act }
      else
        format.html { render :new }
        format.json { render json: @act.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @act.update(act_params)
        format.html { redirect_to @act, notice: 'Act was successfully updated.' }
        format.json { render :show, status: :ok, location: @act }
      else
        format.html { render :edit }
        format.json { render json: @act.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @act.destroy
    respond_to do |format|
      format.html { redirect_to acts_url, notice: 'Act was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    def sort_column
      Act.column_names.include?(params[:sort]) ? params[:sort] : "act_name"
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ?  params[:direction] : "asc"
    end


    def set_act
      @act = Act.find(params[:id])
    end

    def act_params
      params.require(:act).permit(:id, :act_name, :street, :city, :state, :zip, :phone, :url, :updated_at, :gp_date)
    end
end
