class Nav
  attr_reader :data, :path

  def initialize(path, data = [])
    @data = data.freeze
    @path = path
  end

  # Returns the current nav item
  def current_item
    item = route_map[path.sub("/docs/", "")]
    if !item
      raise "Could not find nav item for #{path}"
    end
    item
  end

  # Returns a hash of routes, indexed by path
  #
  # @example
  #   {
  #     "path/to/page": {
  #       path: "path/to/page",
  #       parents: ["parent", "grandparent"]
  #     }
  #   }
  def route_map
    index_by_path = Proc.new do |route_map, items, parents|
      items.each do |item|
        route_map[item["path"]] = {
          path: item["path"],
          parents: parents
        }

        if item["children"].present?
          index_by_path.call(
            route_map,
            item["children"],
            parents.clone.push(item["name"]),
          )
        end
      end
    end

    @_route_map ||= data.each_with_object({}) do |node, route_map|
      if node["children"].present?
        index_by_path.call(route_map, node["children"], [node["name"]], 0)
      end
    end
  end
end
