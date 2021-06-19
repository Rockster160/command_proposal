# belongs_to :iteration
# integer :line_number
# belongs_to :author
# text :body

require "command_proposal/service/external_belong"

class ::CommandProposal::Comment < ApplicationRecord
  include ::CommandProposal::Service::ExternalBelong

  belongs_to :iteration, optional: true
  external_belongs_to :author
end
