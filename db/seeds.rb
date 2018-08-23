# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
Project.create! id: 8, display_name: 'Oceans Eight'
Project.create! id: 2501, display_name: 'Ghost in The Shell'

wf1 = Workflow.create!(id: 55, project_id: 16, name: 'Sample workflow 1', project_name: 'Sample project 1')
wf2 = Workflow.create!(id: 56, project_id: 16, name: 'Sample workflow 2', project_name: 'Sample project 1')
wf3 = Workflow.create!(id: 57, project_id: 17, name: 'Sample workflow 3', project_name: 'Sample project 2')

s1 = Subject.create!(id: 98765)
s2 = Subject.create!
s3 = Subject.create!

Extractor.create!(type: 'Extractors::ExternalExtractor', key: 'External', config: { url: 'https://www.example.com' }, workflow: wf1)
Extractor.create!(type: 'Extractors::PluckFieldExtractor', key: 'Field', config: { field_map: { field1: '$.field1' } }, workflow: wf2)
Extractor.create!(type: 'Extractors::SurveyExtractor', key: 'Question', config: { task_key: 'T1' }, workflow: wf3)

Reducer.create!(type: 'Reducers::UniqueCountReducer', key: 'UC', config: { field: 'External.field1' }, reducible: wf1)
Reducer.create!(type: 'Reducers::CountReducer', key: 'C', config: { }, reducible: wf1, topic: Reducer.topics[:reduce_by_user])
Reducer.create!(type: 'Reducers::SqsReducer', key: 'SQS', config: { queue_url: 'https://sqs.amazon/some_queue' }, reducible: wf2, reduction_mode: Reducer.reduction_modes[:running_reduction])

SubjectReduction.create!(reducible: wf1, subject: s1, reducer_key: 'UC', data: { foo: 'bar' })
SubjectReduction.create!(reducible: wf1, subject: s2, reducer_key: 'UC', data: { foo: 'bar' })
SubjectReduction.create!(reducible: wf2, subject: s3, reducer_key: 'C', data: { bar: 'foo' })

sr1 = SubjectRule.create!(workflow: wf1, condition: ["lte", ["const", 5], ["const", 3]])
sr2 = SubjectRule.create!(workflow: wf1, condition: ["gte", ["lookup", "UC.classifications", 5], ["const", 3]])

SubjectRuleEffect.create!(subject_rule: sr1, action: 'retire_subject')
SubjectRuleEffect.create!(subject_rule: sr2, action: 'retire_subject', config: { reason: 'consensus' })
SubjectRuleEffect.create!(subject_rule: sr2, action: 'add_subject_to_set', config: { subject_set_id: '987' })

ur1 = UserRule.create!(workflow: wf1, condition: ["gte", ["lookup", "C.classifications", 5], ["const", 3]])

UserRuleEffect.create!(user_rule: ur1, action: 'promote_user', config: { workflow_id: wf2.id })