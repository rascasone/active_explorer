module Introspection
  def attrs
    attrs = {}
    instance_variables.each { |variable| attrs[variable] = instance_variable_get variable }
    attrs
  end
end