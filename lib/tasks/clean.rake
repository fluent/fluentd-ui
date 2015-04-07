desc "clean all files/directories in tmp/ directory (use carefully)"
task :clean do
  tmp_directory = File.join(Rails.root, "tmp")
  system("rm -rf #{tmp_directory}")
  system("mkdir #{tmp_directory}")
end
