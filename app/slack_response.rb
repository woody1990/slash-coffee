class SlackResponse
  def self.ephemaral(text)
    {text: text}
  end

  def self.in_channel(text)
    {text: text, response_type: 'in_channel'}
  end
end
