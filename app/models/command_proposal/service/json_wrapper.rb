module CommandProposal
  module Service
    class JsonWrapper
      # Allows directly setting pre-stringified JSON.
      def self.dump(obj)
        return obj if obj.is_a?(String)

        JSON.dump(obj)
      end

      def self.load(str)
        return {} unless str.present?

        JSON.parse(str).with_indifferent_access
      end
    end
  end
end
