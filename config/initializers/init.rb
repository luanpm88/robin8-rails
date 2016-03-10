require 'will_paginate/array'


def append_value(key,value, options = {} )
  values = Rails.cache.read(key) || options[:init_value]  || []
  if value.class == Array
    values += value
  else
    values << value
  end
  if options[:expires_in]
    Rails.cache.write(key, values, :expires_in => option[:expires_in] )
  else
    Rails.cache.write(key, values)
  end
end
