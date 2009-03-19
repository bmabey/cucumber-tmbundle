module PathHelper
  def full_project_directory
    #TODO: get rid of global
    File.expand_path(ENV['TM_PROJECT_DIRECTORY'])
  end
  
  # Evaluates the block within the full_project_directory
  # and returns the result
  def in_project_directory(&block)
    result = nil
    Dir.chdir(full_project_directory) { result = yield }
    result
  end
end