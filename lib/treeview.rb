class Treeview
  def self.tree(dir)
    new(dir).tree
  end

  attr_reader :root_dir, :path

  def initialize(path)
    @path = path == "" ? "/" : path
  end

  def root_dir
    return "/" if path == "/"
    File.directory?(path) ? path.gsub(/\/\z/, "") : File.dirname(path)
  end

  def tree
    parents + Dir.glob("#{root_dir == "/" ? "/" : "#{root_dir}/"}*").map do |file|
      {
        :path => file,
        :is_dir => File.directory?(file),
      }
    end.sort_by do |ent|
      # first order is directory or not, second order is alphabetical
      [ent[:is_dir] ? 0 : 1, ent[:path]]
    end
  end

  def parents
    paths = []
    current = root_dir
    until current == "/"
      paths << {
        :path => current,
        :is_dir => true,
      }
      current = File.dirname(current)
    end
    paths << {
      :path => "/",
      :is_dir => true,
    }
    paths.reverse
  end
end
