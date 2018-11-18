# == Schema Information
#
# Table name: users
#
#  id                 :bigint(8)        not null, primary key
#  sign_in_count      :integer          default(0), not null
#  current_sign_in_at :datetime
#  last_sign_in_at    :datetime
#  current_sign_in_ip :inet
#  last_sign_in_ip    :inet
#  access_token       :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  # :database_authenticatable, :registerable,
  # :recoverable, :rememberable, :validatable

  devise :trackable

  after_create :update_access_token!

  has_many :clips, dependent: :destroy
  has_many :restaurants, through: :clips
  has_many :boards

  def update_access_token!
    self.access_token = "#{id}:#{Devise.friendly_token}"
    save!
  end

  def search_clips(id_params, q)
    q.present? ? search_clips_with_query(id_params, q) : search_clips_without_query(id_params)
  end

  def clips_info
    Clip.includes([:boards, { restaurant: [:restaurant_pictures, :category, :station] }]).where(user: self).order("created_at DESC").map(&:merge_restaurant_and_boards)
  end

  def search_clipped_restaurants(q)
    clips.where(restaurant_id: Restaurant.where('name LIKE ?', "%#{q}%").pluck(:id)).map do |c|
      {
        name: c.restaurant.name,
        station: c.restaurant.station.name,
        category: c.restaurant.category.short_name,
        clip_id: c.id
      }
    end
  end

  def search_boards(q)
    boards.where('name LIKE ?', "%#{q}%")
  end

  private

    def search_clips_with_query(ids, q)
      query = q.split(' ').map { |k| "%#{k}%" } if q.present?
      # ボード内のクリップのみ取り出す
      user_clips = clips.joins(:boards).where('boards.id = ? OR boards.name ILIKE ANY (array[?])', ids[:board_id], query)
      # ボードにない場合全てのクリップを取り出す
      user_clips = clips if user_clips.blank?
      # カテゴリーで絞りこむ
      searching_categories = Category.where(id: ids[:category_id]).or(Category.where(['categories.short_name ILIKE ANY (array[?])', query.map { |qr| "%#{qr}%" }]))
      user_clips = user_clips.joins(:category).merge(searching_categories) if searching_categories.present?
      # 検索条件に駅がある場合その位置情報を入手し、次で周辺のレストランを取得
      station_locations = Station.where(id: ids[:station_id]).map(&:location_array) || Station.where(['name ILIKE ANY (array[?])', query.map { |qr| "%#{qr}%" }]).map(&:location_array)
      # レストラン（と駅）で絞りこむ
      restaurant_ids = restaurants.where('restaurants.name ILIKE ANY (array[?]) OR restaurants.address ILIKE ANY (array[?])', query, query).pluck(:id) + (station_locations.map { |ll| restaurants.within(800, origin: ll).pluck(:id) })
      user_clips = user_clips.where(restaurant_id: restaurant_ids) if restaurant_ids.present?
      # メモで絞り込む
      memo_clip_ids = clips.where(['memo ILIKE ANY (array[?])', query]).pluck(:id)
      user_clips = user_clips.where(id: memo_clip_ids) if memo_clip_ids.present?

      user_clips.includes([:boards, { restaurant: [:restaurant_pictures, :category, :station] }]).map(&:merge_restaurant_and_boards)
    end

    def search_clips_without_query(ids)
      user_clips = ids[:board_id].present? ? clips.joins(:boards).where('boards.id = ?', ids[:board_id]) : clips
      user_clips = user_clips.joins(:category).merge(Category.where(id: ids[:category_id])) if ids[:category_id].present?
      user_clips = user_clips.where(restaurant_id: restaurants.within(800, origin: Station.find(id: ids[:station_id]).location_array).pluck(:id)) if ids[:station_id].present?
      user_clips.includes([:boards, { restaurant: [:restaurant_pictures, :category, :station] }]).map(&:merge_restaurant_and_boards)
    end

end
