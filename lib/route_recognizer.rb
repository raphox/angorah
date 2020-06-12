class RouteRecognizer
  # To use this inside your app, call:
  # `RouteRecognizer.initial_path_segments`
  # This returns an array, e.g.: ['assets','blog','team','faq','users']

  INITIAL_SEGMENT_REGEX = %r{^\/([^\/\(:]+)}

  def self.initial_path_segments
    routes = Rails.application.routes.routes
    paths = routes.collect {|r| r.path.spec.to_s }

    paths.collect { |path| path[INITIAL_SEGMENT_REGEX, 1] }.compact.uniq
  end
end
