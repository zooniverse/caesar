require 'aws-sdk-s3'

class StoredExport
  BUCKET_NAME = "zooniverse-static".freeze
  PATH_PREFIX = "data-exports.zooniverse.org/caesar".freeze

  attr_accessor :filename, :remote_file

  def initialize(filename)
    self.filename = filename
  end

  def upload(file)
    file = Pathname.new(file) unless Pathname === file

    file.open('rb') do |stream|
      remote_file.upload_file stream,
                              content_type: mime_type(file),
                              content_disposition: content_disposition
    end
  end

  def download_url
    remote_file.presigned_url :get, expires_in: 1.week.seconds.to_i
  end

  private

  def mime_type(file)
    `file --brief --mime #{ file.to_s }`.chomp.split(';').first
  rescue
    'text/plain'
  end

  def remote_file
    @remote_file ||= ::Aws::S3::Object.new bucket_name: BUCKET_NAME, key: upload_path
  end

  def upload_path
    "#{PATH_PREFIX}/#{filename}"
  end

  def content_disposition
    "attachment; filename=\"#{filename}\""
  end
end
