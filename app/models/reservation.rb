class Reservation < ActiveRecord::Base
  belongs_to :organizer, :class_name => "User"
  belongs_to :movie
  has_many :tickets,
    :order => "participant_id DESC"#,
#    :dependent => :destroy
  has_many :participants, :class_name => "User", :source => :participant, :through => :tickets
  
  delegate :title, :to => :movie
  
  accepts_nested_attributes_for :tickets, :allow_destroy => true
  
  validates_presence_of :reserved_at, :on => :create, :message => "can't be blank, must take place some time"
  validates_presence_of :movie, :on => :create, :message => "can't be blank"
  
  scope :upcoming, lambda { where("reserved_at > ?", Time.now)}
  scope :recent, lambda { |time_ago = 4.week.ago| where(:reserved_at => time_ago..Time.now ) }
  scope :visible, where("visible_for_public = ?", true)
  
  
  def visible_for
    visible_for_public ? "everybody" : "participants only"
  end
  
  def visible_for_user?(user)
    if visible_for_public
      return true
    else
      participants.include?(user) || user == organizer
    end
  end
  
end
