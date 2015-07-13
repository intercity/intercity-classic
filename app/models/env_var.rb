class EnvVar < ActiveRecord::Base
  belongs_to :application

  validates :key, :value, presence: true
  validates :key, format: { with: /\A[a-zA-Z0-9_]+\z/ }, if: -> { key.present? }
  validates :value, format: { with: /\A[\S]+\z/ },
                    if: -> { value.present? }
end
