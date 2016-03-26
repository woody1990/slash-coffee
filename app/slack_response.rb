class SlackResponse
  def initialize(text, in_channel = false)
    @text = text
    @in_channel = in_channel
  end

  def response
    response = {text: @text}
    response[:response_type] = 'in_channel' if @in_channel
    response
  end

  def to_json
    response.to_json
  end

  class << self
    def ephemaral(text)
      SlackResponse.new(text)
    end

    def in_channel(text)
      SlackResponse.new(text, true)
    end
  end
end
