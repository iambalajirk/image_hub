dirname = Constant::ROOT_FOLDER
# Create a root folder if not exists
unless File.directory?(dirname)
	# Rails.logger.info "****** Root directory doesn't exists, Creating one....."
	# Rails.logger.debug "****** Directory #{dirname}"
  FileUtils.mkdir_p(dirname)
# Rails.logger.debug "****** Created #{dirname}" if res
end