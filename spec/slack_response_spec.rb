require './spec/spec_helper'

describe SlackResponse do
  describe '::ephemaral' do
    before do
      @response = SlackResponse.ephemaral('Test response')
    end

    it 'contains the given text' do
      @response[:text].must_equal 'Test response'
    end

    it 'is not in channel' do
      @response[:response_type].must_be_nil
    end
  end

  describe '::in_channel' do
    before do
      @response = SlackResponse.in_channel('Test response')
    end

    it 'contains the given text' do
      @response[:text].must_equal 'Test response'
    end

    it 'is in channel' do
      @response[:response_type].must_equal 'in_channel'
    end
  end
end
