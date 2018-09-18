class User < ApplicationRecord
  before_save { self.email.downcase! }
  validates :name, presence: true, length: { maximum: 50 }
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i },
                    uniqueness: { case_sensitive: false }
  has_secure_password
  
  has_many :microposts
  has_many :relationships 
  has_many :followings, through: :relationships, source: :follow
  has_many :reverses_of_relationship, class_name: 'Relationship', foreign_key: 'follow_id'
  has_many :followers, through: :reverses_of_relationship, source: :user  

#---actions for Like
  has_many :likes 
  has_many :likees, through: :likes, source: :like
  has_many :reverses_of_like, class_name: 'Like', foreign_key: 'like_id'
  has_many :likers, through: :reverses_of_like, source: :user  
#---actions for Like

  def follow(other_user)
    unless self == other_user
      self.relationships.find_or_create_by(follow_id: other_user.id)
    end
  end

  def unfollow(other_user)
    relationship = self.relationships.find_by(follow_id: other_user.id)
    relationship.destroy if relationship
  end

  def following?(other_user)
    self.followings.include?(other_user)
  end
  
  def feed_microposts
    Micropost.where(user_id: self.following_ids + [self.id])
  end

#---actions for Like

  def like(other_micropost)
#    unless self == other_user
      self.likes.find_or_create_by(like_id: other_micropost.id)
#    end
  end

  def unlike(other_micropost)
    like = self.likes.find_by(like_id: other_micropost.id)
    like.destroy if like
  end

  def liking?(other_micropost)
    self.likees.include?(other_micropost)
  end
  
#---actions for Like


  
end