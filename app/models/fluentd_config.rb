module FluentdConfig
	class MatchElement
		KEYS = [
		 :type, :describe, :stores, :sources
		].freeze

		attr_accessor(*KEYS)
	end

	class SourceElement
		KEYS = [
		  :type, :tag, :describe, :interval
		].freeze

		attr_accessor(*KEYS)
	end
end