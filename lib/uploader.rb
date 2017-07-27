require 'aws-sdk'

class Uploader
  attr_accessor :local_file, :remote_file

  def initialize(file)
    self.local_file = file
    self.remote_file = ::Aws::S3::Object.new bucket_name: 'zooniverse-static', key: upload_path
  end

  def upload
    ::File.open(local_file.path, 'rb') do |stream|
      remote_file.upload_file stream, content_type: mime_type
    end
  end

  def url
    remote_file.presigned_url :get, expires_in: 1.week
  end

  def mime_type
    `file --brief --mime #{ local_file.path }`.chomp.split(';').first
  rescue
    'text/plain'
  end

  def upload_path
    "data-exports.zooniverse.org/#{ ::File.basename(local_file) }".gsub /\/{2,}/, '/'
  end
end
