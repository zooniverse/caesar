require 'spec_helper'

describe Annotation do
  describe 'parsing' do
    it 'parses combo tasks correctly' do
      anno_string = '{"annotations": [ { "task": "T12", "value": [ { "value": "b04edf77c2eb9", "option": true } ] }, { "task": "T13", "value": [ { "task": "T3", "value": "at U.S. 15 and the Potomac River" }, { "task": "T4", "value": "" } ] }, { "task": "T11", "value": [ { "task": "T6", "value": "Ted Bradley" }, { "task": "T7", "value": "19659" }, { "task": "T8", "value": [ { "value": 8, "option": true } ] }, { "task": "T9", "value": [ { "value": 1, "option": true } ] }, { "task": "T10", "value": [ { "value": 1983, "option": true } ] }, { "task": "T1", "value": [ { "value": "United States", "option": true } ] } ] } ]}'
      anno = JSON.parse(anno_string)['annotations']
      parsed = Annotation.parse(anno)

      expect(parsed.keys.size).to eq(9)
      expect(parsed.keys).to include('T3')
      expect(parsed.keys).to include('T12')
      expect(parsed.keys).not_to include('T13')
      expect(parsed.keys).not_to include('T11')
    end

    it 'parses correctly in the presence of multiple annotations per task' do
      anno_string = '{"annotations": [ { "task": "T12", "value": [ { "value": "b04edf77c2eb9", "option": true } ] }, { "task": "T13", "value": [ { "task": "T3", "value": "at U.S. 15 and the Potomac River" }, { "task": "T1", "value": "" } ] }, { "task": "T11", "value": [ { "task": "T6", "value": "Ted Bradley" }, { "task": "T7", "value": "19659" }, { "task": "T8", "value": [ { "value": 8, "option": true } ] }, { "task": "T9", "value": [ { "value": 1, "option": true } ] }, { "task": "T10", "value": [ { "value": 1983, "option": true } ] }, { "task": "T1", "value": [ { "value": "United States", "option": true } ] } ] } ]}'
      anno = JSON.parse(anno_string)['annotations']
      parsed = Annotation.parse(anno)

      expect(parsed.keys.size).to eq(8)
      expect(parsed.keys).to include('T1')
      expect(parsed.keys).to include('T3')
      expect(parsed.keys).to include('T12')
      expect(parsed.keys).not_to include('T13')
      expect(parsed.keys).not_to include('T11')
      expect(parsed['T1'].size).to eq(2)
    end

    it 'parses another sample string correctly' do
      anno_string = '{"annotations": [ { "task": "T12", "value": [ { "value": "446f8d2fb5c75", "option": true } ] }, { "task": "T5", "value": [ { "task": "T2", "value": "Lycopus rubellus" }, { "task": "T3", "value": "Wannee Conservation Area" }, { "task": "T4", "value": "Floodplain swamp" } ] }, { "task": "T11", "value": [ { "task": "T6", "value": "J. Richard Abbot" }, { "task": "T7", "value": "14072" }, { "task": "T8", "value": [ { "value": 10, "option": true } ] }, { "task": "T9", "value": [ { "value": 30, "option": true } ] }, { "task": "T10", "value": [ { "value": 2000, "option": true } ] } ] } ] }'
      anno = JSON.parse(anno_string)['annotations']
      parsed = Annotation.parse(anno)

      expect(parsed.keys.size).to eq(9)
      expect(parsed.keys).to include('T3')
      expect(parsed.keys).to include('T8')
      expect(parsed.keys).not_to include('T11')
    end

    context 'for FEM transcription annotation strings' do
      let(:annotations) do
        '{"annotations": [{"task":"T1","value":[{"x1":217.00167846679688,"x2":794.4693603515625,"y1":245.3994903564453,"y2":239.76519775390625,"frame":0,"details":[{"task":"T1.0.0"}],"toolType":"transcriptionLine","toolIndex":0}],"taskType":"transcription"},{"task":"T1.0.0","value":"Am. Colonisation and Af. Ed. Societies","taskType":"text","markIndex":0},{"task":"T2","value":1,"taskType":"single"}]}'
      end
      let(:annotation_json) { JSON.parse(annotations) }
      let(:expected_data) do
        JSON.parse(
          '{"T1":[{"task":"T1","value":[{"x1":217.00167846679688,"x2":794.4693603515625,"y1":245.3994903564453,"y2":239.76519775390625,"frame":0,"details":[{"task":"T1.0.0"}],"toolType":"transcriptionLine","toolIndex":0}],"taskType":"transcription"}],"T1.0.0":[{"task":"T1.0.0","value":"Am. Colonisation and Af. Ed. Societies","taskType":"text","markIndex":0}],"T2":[{"task":"T2","value":1,"taskType":"single"}]}'
        )
      end

      it 'parses the annotations correctly' do
        annotation_values = annotation_json['annotations']
        parsed_data = Annotation.parse(annotation_values)
        expect(parsed_data).to include(expected_data)
      end
    end
  end
end