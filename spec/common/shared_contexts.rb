# frozen_string_literal: true

RSpec.shared_context 'calls api' do
  let(:api_params) { {} }
  let(:api_response) { call_api(api_params) }
  let(:api_response_as_json) { JSON.parse(api_response.body) }
end
