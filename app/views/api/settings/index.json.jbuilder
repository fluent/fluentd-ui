@config.group_by_label.each do |label_name, types|
  json.set!(label_name) do
    types.each do |type, elements|
      json.set!(type) do
        json.array!(elements) do |element|
          json.partial! "api/settings/element", current_label: label_name, element: element
        end
      end
    end
  end
end
