# belongs_to :iteration
# integer :line_number
# belongs_to :author
# text :body

require_dependency "command_proposal/service/external_belong"

class ::CommandProposal::Comment < ApplicationRecord
  self.table_name = :command_proposal_comments
  include ::CommandProposal::Service::ExternalBelong

  belongs_to :iteration, optional: true, class_name: "CommandProposal::Iteration"
  external_belongs_to :author
end
