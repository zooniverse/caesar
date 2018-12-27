require 'spec_helper'

module Helpers
  def helper_subjects
    [
      create(:subject, metadata: { 'blah' => 'true' }),
      create(:subject, metadata: { '#training_subject' => 'true' }),
    ]
  end

  def helper_extracts(subjects)
    [
      Extract.new(
        id: 0,
        subject_id: subjects[0].id,
        extractor_key: "foo",
        classification_id: 1234,
        classification_at: Date.new(2014, 12, 4),
        data: {"foo" => "bar"}
      ),
      Extract.new(
        id: 1,
        subject_id: subjects[0].id,
        extractor_key: "foo",
        classification_id: 1234,
        classification_at: Date.new(2014, 12, 4),
        data: {"foo" => "baz"}
      ),
      Extract.new(
        id: 2,
        subject_id: subjects[1].id,
        extractor_key: "bar",
        classification_id: 1235,
        classification_at: Date.new(1980, 10, 22),
        data: {"bar" => "baz"}
      ),
      Extract.new(
        id: 3,
        subject_id: subjects[1].id,
        extractor_key: "baz",
        classification_id: 1236,
        classification_at: Date.new(2017, 2, 7),
        data: {"baz" => "bar"}
      ),
      Extract.new(
        id: 4,
        subject_id: subjects[0].id,
        extractor_key: "foo",
        classification_id: 1237,
        classification_at: Date.new(2017, 2, 7),
        data: {"foo" => "fufufu"}
      )
    ]
  end
end

RSpec.configure{ |c| c.include Helpers }
