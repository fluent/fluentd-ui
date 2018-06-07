import "lodash/lodash"
$(document).ready(() => {
  let configUrl = (name) => {
    return `/daemon/setting/${name}/configure`
  }
  function ownedSectionOnChange() {
    const pluginName = _.last(document.documentURI.replace(/\/configure$/, "").split("/"))
    $("#parse-section select").on("change", (event) => {
      $.ajax({
        url: configUrl(pluginName),
        method: "GET",
        data: {
          parse_type: $(event.target).val()
        }
      }).then((data) => {
        $("#parse-section").html($(data).find("#parse-section").html())
        ownedSectionOnChange()
      })
    })
    $("#format-section select").on("change", (event) => {
      $.ajax({
        url: configUrl(pluginName),
        method: "GET",
        data: {
          format_type: $(event.target).val()
        }
      }).then((data) => {
        $("#format-section").html($(data).find("#format-section").html())
        ownedSectionOnChange()
      })
    })
  }

  ownedSectionOnChange()
})
