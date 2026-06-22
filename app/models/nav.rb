class Nav
  attr_reader :data

  def initialize(data = [])
    @data = data.freeze
    route_map
  end

  # Returns the current nav item's root
  def current_item_root(request)
    current = current_item(request)

    data.find { |item| item["name"] == current[:parents][0] }
  end

  # Returns top-level sections with children only on the section the user is
  # currently in. Other sections render as navigable links without their subtree.
  # Used by the global top-nav to avoid rendering the full tree on every page.
  def data_for_top_nav(request)
    current = current_item(request)
    current_root_name = current && current[:parents].first

    data.map do |section|
      if section["name"] == current_root_name
        section
      else
        section.reject { |k, _| k == "children" }
      end
    end
  end

  # Returns the current nav item
  def current_item(request)
    return nil if request.path == "/docs"

    item = route_map[request.path.sub("/docs/", "")]
    raise ActionController::RoutingError.new("Missing navigation for #{request.path}") unless item

    item
  end

  # Returns the breadcrumb trail (ancestor sections and the page itself) for a
  # given docs path, as an array of nav nodes from the top-level section down to
  # the page. Nodes without a path (section toggles) are included so callers can
  # decide whether to link them. Returns an empty array when the path is unknown.
  #
  # @example
  #   nav.breadcrumb_trail("pipelines/configure/environment-variables")
  #   #=> [{ "name" => "Pipelines", "path" => "pipelines" },
  #   #    { "name" => "Configure", "path" => nil },
  #   #    { "name" => "Environment variables", "path" => "pipelines/configure/environment-variables" }]
  def breadcrumb_trail(path)
    find_trail(data, path) || []
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

  private

  # Depth-first search for the chain of nav nodes leading to the node whose
  # path matches the target. Returns nil when no node matches.
  def find_trail(items, target, ancestors = [])
    items.each do |item|
      next if item["type"] == "divider"

      trail = ancestors + [item]
      return trail if item["path"] == target

      if item["children"].present?
        found = find_trail(item["children"], target, trail)
        return found if found
      end
    end

    nil
  end
end
