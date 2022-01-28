class User::SpotsController < ApplicationController
before_action :authenticate_user!,except: [:index]

  def new
    @spot = Spot.new
    @genres = [[0, "play"], [1, "eat"], [2, "viewing"]]
  end

  def create
    converted_params = spot_params.merge({user_id: current_user.id}) #観光地登録者のユーザー登録
    @spot = Spot.new(converted_params)
    if @spot.save
      flash[:success] = "It was successful."
      redirect_to spots_path
    else
      render :new
    end
  end

  def index
    @spot = Spot.new
    gon.spot = Spot.last
    gon.spots = Spot.all
    @spots = Spot.all
    if params[:box_ids]
      @spots = []
      params[:box_ids].each do |key, value|
        if value == "1"
          box_spots = Box.find_by(box_name: key).spots
          @spots = @spots.empty? ? box_spots : @spots & box_spots
        end
      end
    end
  end

  def show
    @spot = Spot.find(params[:id])
    @comment = Comment.new
  end

  def edit
    @spot = Spot.find(params[:id])
  end

  def update
    @spot = Spot.find(params[:id])
    if params[:spot][:spot_img_ids] #選択した画像の削除
      params[:spot][:spot_img_ids].each do |image_id|
        image = @post.images.find(image_id)
        image.purge
      end
    end
    @spot.update_attributes(spot_params)
    redirect_to spot_path(@spot)
  end

  def destroy
    @spot = Spot.find(params[:id])
    @spot.destroy
    redirect_to spots_path
  end

  def favorite
    favorites = Favorite.where(user_id: current_user.id).pluck(:spot_id)
    @favorite_list = Spot.find(favorites)
  end

  def sarch
  end


  private

  def spot_params
    params.require(:spot).permit(:spot_name, :post_code, :address, :spot_text, :latitude, :longitude, box_ids: [], spot_imgs: [], spotimgs_attachments_attributes: [ :id, :_destroy ])
  end

end
