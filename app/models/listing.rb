class Listing < ActiveRecord::Base
  belongs_to :neighborhood
  belongs_to :host, :class_name => "User"
  has_many :reservations
  has_many :reviews, :through => :reservations
  has_many :guests, :class_name => "User", :through => :reservations

  validates_presence_of :address, :listing_type, :title, :description, :price, :neighborhood_id

  validate :neighborhood_exists

  before_save :make_host
  before_destroy :host_status

  # Finds the average rating for a listing
  def average_rating
    Listing.joins("LEFT JOIN RESERVATIONS R ON R.listing_id = listings.id", "LEFT JOIN REVIEWS RE ON RE.reservation_id = R.id").select("listings.title, AVG(rating) as 'avg_rating'").where("listings.id = ?", self.id).first.avg_rating
  end

  private
  # Makes user a host when a listing is created
  def make_host
    unless self.host.host
      self.host.update(:host => true)
    end
  end

  # Changes host status to false when listing is destroyed and user has no more listings
  def host_status
    if self.host.listings.count <= 1
      self.host.update(:host => false)
    end
  end

  # Confirms neighborhood exists ebfore listing validated
  def neighborhood_exists
    errors.add(:neighborhood_id, "doesn't exist") unless Neighborhood.exists?(neighborhood_id)
  end
end
