# frozen_string_literal: true

module Types
  # Current user's credential information.
  class CredentialType < GraphQL::Schema::Object
    graphql_name 'Credential'

    field :isLoggedIn, Boolean, null: false, method: :logged_in?
    field :isAdmin, Boolean, null: false, method: :admin?
  end
end
