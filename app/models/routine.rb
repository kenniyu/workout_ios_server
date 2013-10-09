class Routine < ActiveRecord::Base
  attr_accessible :creator_id, :description, :name

  has_many :routine_tags
  has_many :tags, :through => :routine_tags

  has_many :routine_exercises
  has_many :exercises, :through => :routine_exercises

  # Twitter helper
  include Twitter::Extractor

  def self.analyze(name, description)
    return nil if name.blank? || description.blank?

    analyzed_data = {
      :name => name,
      :description => description,
      :tags => Twitter::Extractor.extract_hashtags(description)
    }
    return analyzed_data
  end


end
