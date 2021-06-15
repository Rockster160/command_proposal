module CommandProposal
  module Service
    module ExternalBelong
      extend ActiveSupport::Concern

      included do
        def self.external_belongs_to key
          define_getters key
          define_setters key
        end

        def self.define_getters key
          define_method key do
            return if user_class.blank?

            if role_scope.present?
              user_class.send(role_scope).find_by(id: "#{key}_id")
            else
              user_class.find_by(id: "#{key}_id")
            end
          end

          define_method "#{key}_name" do
            public_send(key)&.public_send(user_name)
          end
        end

        def self.define_setters key
          define_method "#{key}=" do |obj|
            self.send("#{key}_id=", obj&.id)
          end
        end

        def user_class
          ::CommandProposal.configuration.user_class
        end

        def role_scope
          ::CommandProposal.configuration.role_scope
        end

        def user_name
          ::CommandProposal.configuration.user_name
        end
      end
    end
  end
end
