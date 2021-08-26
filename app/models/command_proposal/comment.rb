# belongs_to :iteration
# integer :line_number
# belongs_to :author
# text :body

require_relative "service/external_belong"

class ::CommandProposal::Comment < ApplicationRecord
  self.table_name = :command_proposal_comments
  include ::CommandProposal::Service::ExternalBelong

  belongs_to :iteration, optional: true
  external_belongs_to :author
end
