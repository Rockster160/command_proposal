# string :name
# integer :role
# timestamps

class User < ApplicationRecord
  enum role: {
    nobody: 0,
    admin: 1
  }
end
