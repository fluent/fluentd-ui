json.id element_id(current_label, element)
json.current_label current_label || "ROOT"
json.label element["@label"] || element["label"]
json.name element.name
json.type element["@type"] || element["type"]
json.arg element.arg
json.settings element
json.content element.to_s
