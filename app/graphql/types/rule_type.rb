Types::EffectInterface = GraphQL::InterfaceType.define do
  name "Effect"

  field :raw_config, Types::JsonType, property: :config
end

Types::RetireSubjectType = GraphQL::ObjectType.define do
  name "RetireSubject"
  interfaces [Types::EffectInterface]

  field :reason, !types.String
end

Types::AddSubjectToSetType = GraphQL::ObjectType.define do
  name "AddSubjectToSet"
  interfaces [Types::EffectInterface]

  field :subject_set_id, !types.Int
end

Types::AddSubjectToCollectionType = GraphQL::ObjectType.define do
  name "AddSubjectToCollection"
  interfaces [Types::EffectInterface]

  field :collection_id, !types.Int
end

Types::RuleType = GraphQL::ObjectType.define do
  name "Rule"

  field :condition, Types::JsonType
  field :effects, types[Types::EffectInterface]
end
