require "deeply_enumerable"

# Mirror the way Rails (ActiveSupport) mixes its enumerable extensions into the
# core classes: reopen each class and include the corresponding module.
class Hash
  include DeeplyEnumerable::HashExtension
end

class Array
  include DeeplyEnumerable::ArrayExtension
end
