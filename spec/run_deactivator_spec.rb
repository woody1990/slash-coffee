require './spec/spec_helper'

describe RunDeactivator do
  describe '::deactivate_if_timed_out' do
    it 'returns nil if run is nil' do
      RunDeactivator.deactivate_if_timed_out(nil).must_be_nil
    end
  end
end
