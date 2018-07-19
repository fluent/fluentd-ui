unless {}.respond_to?(:dig)
  begin
    # backport_dig is faster than dig_rb so prefer backport_dig.
    require 'backport_dig'
  rescue LoadError
    require 'dig_rb'
  end
end
