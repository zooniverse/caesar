require 'spec_helper'

describe GraphqlController, type: :controller do
  it 'works with no user' do
    get :execute, params: {query: "{me { isLoggedIn }}"}

    expect(response.status).to eq(200)
    expect(JSON.parse(response.body)).to eq("data" => {"me" => {"isLoggedIn" => false}})
  end

  it 'works with normal user' do
    fake_session
    get :execute, params: {query: "{me { isLoggedIn }}"}

    expect(response.status).to eq(200)
    expect(JSON.parse(response.body)).to eq("data" => {"me" => {"isLoggedIn" => true}})
  end

  it 'works with admin user' do
    fake_session(admin: true)
    get :execute, params: {query: "{me { isLoggedIn isAdmin }}"}

    expect(response.status).to eq(200)
    expect(JSON.parse(response.body)).to eq("data" => {"me" => {"isLoggedIn" => true, "isAdmin" => true}})
  end
end
