desc "clean all files/directories in tmp/ directory (use carefully)"
task :clean do
  tmp_directory = Rails.root.join("tmp")
  tmp_directory.rmtree
  tmp_directory.mkdir
end
