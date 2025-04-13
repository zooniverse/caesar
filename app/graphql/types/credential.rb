# app/graphql/types/credential_type.rb
module Types
    class Credential < GraphQL::Schema::Object
      graphql_name 'Credential'

      field 'isLoggedIn', Boolean, null: false, method: :logged_in?
      field 'isAdmin', Boolean, null: false, method: :admin?
    end
end
