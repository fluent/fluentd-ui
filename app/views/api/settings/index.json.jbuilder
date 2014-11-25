json.array! @config.elements do |elm|
  json.partial! "api/settings/element", element: elm
end
