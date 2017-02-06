require 'spec_helper'

describe Extractors::ExternalExtractor do
  let(:classification) do
    Classification.new("annotations" => [{"task" => "T0", "value" => "foo"}], "links" => {"workflow" => "1021"})
  end
  
  it 'posts the classification to a foreign API' do
    stub_request(:post, "http://example.org/post/classification/here").
      with(:body => "{\"attributes\":{\"annotations\":[{\"task\":\"T0\",\"value\":\"foo\"}],\"links\":{\"workflow\":\"1021\"}}}",
           :headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type'=>'application/json', 'Host'=>'example.org', 'User-Agent'=>'Ruby'}).
      to_return(:status => 200, :body => "{}", :headers => {})

    extractor = described_class.new("ext", "url" => "http://example.org/post/classification/here")
    extractor.process(classification)

    expect(a_request(:post, "example.org/post/classification/here")
             .with(body: classification.to_json))
      .to have_been_made.once
  end

  it 'stores the returned data as an extract' do
    data = {"foo" => "bar"}

    stub_request(:post, "http://example.org/post/classification/here").
      with(:body => "{\"attributes\":{\"annotations\":[{\"task\":\"T0\",\"value\":\"foo\"}],\"links\":{\"workflow\":\"1021\"}}}",
           :headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type'=>'application/json', 'Host'=>'example.org', 'User-Agent'=>'Ruby'}).
      to_return(:status => 200, :body => data.to_json, :headers => {})

    extractor = described_class.new("ext", "url" => "http://example.org/post/classification/here")
    result = extractor.process(classification)

    expect(result).to eq(data)
  end

  it 'does not post if no url is configured' do
    extractor = described_class.new("ext")
    extractor.process(classification)

    expect(a_request(:post, "example.org/post/classification/here")
             .with(body: classification.to_json))
      .not_to have_been_made
  end
end
