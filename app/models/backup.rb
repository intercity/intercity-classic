class Backup < ActiveRecord::Base
  AMAZON_REGIONS = %w(eu-west-1 us-east-1 us-west-1 us-west-2 sa-east-1
                      ap-northeast-1 ap-southeast-1 ap-southeast-2)

  enum storage_type: [:s3]

  belongs_to :application

  validates :s3_access_key, :s3_secret_access_key, presence: true, if: -> { s3_enabled? }
  validates :s3_access_key, format: { with: /\d*\D+\d*/ }, if: -> { s3_access_key.present? && s3_enabled? }
  validates :s3_secret_access_key, format: { with: /\d*\D+\d*/ },
                                   if: -> { s3_secret_access_key.present? && s3_enabled? }

  private

  def s3_enabled?
    s3? && enabled?
  end
end
