# frozen_string_literal: true

# Downloader to import data from any web accessible csv
class UrlDownloader
  def self.stream(url)
    Tempfile.create('caesar-downloaded-file') do |file|
      HTTParty.get(url, stream_body: true) do |fragment|
        file.write(fragment)
      end

      file.rewind

      yield file
    end
  end
end
