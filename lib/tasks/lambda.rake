namespace :lambda do
  desc "Updates the staging lambda script"
  task :staging do
    # aws lambda create-function --region us-east-1 --function-name forward_to_http --zip-file fileb://kinesis-to-http/forward_to_http.zip --role arn:aws:iam::927935712646:role/zooniverse-caesar-forwarder-staging --handler forward_to_http.handler --runtime python2.7 --role arn:aws:iam::927935712646:role/zooniverse-kinesis-lambda
  end

  desc "Updates the production lambda script"
  task :production do
    # aws lambda create-function --region us-east-1 --function-name forward_to_http --zip-file fileb://kinesis-to-http/forward_to_http.zip --role arn:aws:iam::927935712646:role/zooniverse-caesar-forwarder-production --handler forward_to_http.handler --runtime python2.7 --role arn:aws:iam::927935712646:role/zooniverse-kinesis-lambda
  end
end
