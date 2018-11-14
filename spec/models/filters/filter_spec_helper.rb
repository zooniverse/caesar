require 'spec_helper'

EXTRACTS = [
  Extract.new(
    id: 0,
    extractor_key: "foo",
    classification_id: 1234,
    classification_at: Date.new(2014, 12, 4),
    data: {"foo" => "bar"}
  ),
  Extract.new(
    id: 1,
    extractor_key: "foo",
    classification_id: 1234,
    classification_at: Date.new(2014, 12, 4),
    data: {"foo" => "baz"}
  ),
  Extract.new(
    id: 2,
    extractor_key: "bar",
    classification_id: 1235,
    classification_at: Date.new(1980, 10, 22),
    data: {"bar" => "baz"}
  ),
  Extract.new(
    id: 3,
    extractor_key: "baz",
    classification_id: 1236,
    classification_at: Date.new(2017, 2, 7),
    data: {"baz" => "bar"}
  ),
  Extract.new(
    id: 4,
    extractor_key: "foo",
    classification_id: 1237,
    classification_at: Date.new(2017, 2, 7),
    data: {"foo" => "fufufu"}
  )
]