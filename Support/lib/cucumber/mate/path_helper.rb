module PathHelper
  
  def full_project_directory
    features_directory = find_project_dir(File.dirname(@full_file_path))
  end

  # Evaluates the block within the full_project_directory
  # and returns the result
  def in_project_directory(&block)
    result = nil
    Dir.chdir(full_project_directory) { result = yield }
    result
  end

  def find_project_dir(current_dir)
    return nil unless File.exists?(current_dir)
    current_dir = File.expand_path(current_dir)
    FileUtils.chdir(current_dir) do
      parent_dir = File.expand_path("..")
      return nil if parent_dir == current_dir
      boot_file = File.join(current_dir, "config", "boot.rb")
      return File.exists?(boot_file) ? current_dir : find_project_dir(parent_dir)
    end
  end

end
