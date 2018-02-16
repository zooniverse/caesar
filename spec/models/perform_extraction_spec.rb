describe PerformExtraction do
  let(:workflow) { create :workflow, extractors: [build(:survey_extractor)] }
  let(:subject) { create :subject }
  let(:classification) { create :classification, :survey_task, workflow: workflow, subject: subject }

  it 'fetches classifications from panoptes when there are no other extracts' do
    expect do
      described_class.new(workflow).extract(classification)
    end.to change(FetchClassificationsWorker.jobs, :size).by(2)
  end

  it 'does not fetch subject classifications when extracts already present' do
    create(:extract,
           classification_id: classification.id,
           extractor_key: "zzz",
           subject: subject,
           workflow: workflow,
           data: {"ZZZ" => 1}
    )

    expect { described_class.new(workflow).extract(classification) }.
      to change(FetchClassificationsWorker.jobs, :size).by(1)
  end

end
