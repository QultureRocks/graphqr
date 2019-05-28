# frozen_string_literal: true

begin
  require 'pagy'
rescue LoadError
  Kernel.warn 'Pagy not found'
end
