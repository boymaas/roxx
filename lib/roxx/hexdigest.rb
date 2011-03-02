def hexdigest *params
  MD5.hexdigest( params.flatten.map {|e| e.respond_to?(:to_hash) ? e.to_hash : e } * ':' )
end
