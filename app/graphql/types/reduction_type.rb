Types::ReductionType = GraphQL::ObjectType.define do
  name "Reduction"
  field :reducer_id, types.String
  field :subject_id, types.String
  field :data, Types::JsonType
end
