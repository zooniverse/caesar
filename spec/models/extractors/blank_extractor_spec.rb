require 'spec_helper'

describe Extractors::BlankExtractor do
  let(:extractor) { described_class.new('blanco', 'task_key' => task_key) }
  let(:task_key) { 'T1' }
  let(:blank_annotations) { [{'task' => task_key, 'value' => []}] }
  let(:present_annotations) do
    [
      {
        'task' => task_key,
        'value' => [
          {
            'x' => 601.796875,
            'y' => 357,
            'rx' => 232.1055794245369,
            'ry' => 93.59086493883898,
            'tool' => 0,
            'angle' => 178.27177234950145,
            'frame' => 0,
            'details' => []
          }
        ]
      }
    ]
  end

  describe '#process' do
    it 'detects blanks from classification step' do
      classification = Classification.new('annotations' => blank_annotations)
      expect(extractor.process(classification)).to eq('blank' => true)
    end

    it 'detects not-blanks from classification step' do
      classification = Classification.new('annotations' => present_annotations)
      expect(extractor.process(classification)).to eq('blank' => false)

      classification = Classification.new('annotations' => [{"task"=>task_key, "value"=>1}])
      expect(extractor.process(classification)).to eq('blank' => false)
    end
  end
end
