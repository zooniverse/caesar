RSpec.describe SubjectRuleEffectPolicy do
  subject { described_class }
  let(:project) { create :project}
  let(:admin_credential) { fake_credential admin: true }
  let(:collaborator_credential) { fake_credential project_ids: [project.id] }

  permissions :create?, :update?, :focus do
    let(:subject_rule_effect) { create :subject_rule_effect }

    it 'denies access when not an admin' do
      expect(subject).not_to permit(collaborator_credential, project)
    end

    it 'grants access to admin' do
      expect(subject).to permit(admin_credential, project)
    end
  end
end