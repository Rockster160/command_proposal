class ::CommandProposal::Service::JSONWrapper
  # Allows directly setting pre-stringified JSON.
  def self.dump(obj); obj.is_a?(String) ? obj : JSON.dump(obj); end
  def self.load(str); str.present? ? JSON.parse(str) : str; end
end
