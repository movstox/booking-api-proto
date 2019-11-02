# frozen_string_literal: true

RSpec.shared_context 'calls api' do
  let(:api_params) { {} }
  let(:api_response) { call_api(api_params) }
  let(:api_response_as_json) { JSON.parse(api_response.body) }
end

RSpec.shared_examples 'endpoint returning error message' do |error_status, error_msg|
  it 'returns %s' % error_status do
    expect(api_response.status).to eq(error_status)
  end

  it 'returns error' do
    expect(api_response_as_json.keys).to include('error')
    expect(api_response_as_json['error']).to eq error_msg
  end
end

RSpec.shared_examples 'endpoint responding with' do |response_status, response_json_class|
  it 'returns %s' % response_status do
    expect(api_response.status).to eq(response_status)
  end

  it 'returns an %s' % response_json_class.to_s do
    expect(api_response_as_json).to be_a_kind_of response_json_class
  end
end
