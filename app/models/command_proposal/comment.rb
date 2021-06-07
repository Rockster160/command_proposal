# belongs_to :iteration
# integer :line_number
# belongs_to :author
# text :body

class CommandProposal::Comment < ApplicationRecord
  belongs_to :iteration, belongs_to: :optional
  belongs_to :author, belongs_to: :optional
end
