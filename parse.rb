require_relative 'norma_aeb43_file'

file_name = ARGV[0]
file = NormaAEB43File.new(file_name)
file.parse
