$(function() {
  function bindSelect2Contacts() {
    $(".select2-contacts").select2({
      placeholder: "Contact",
      allowClear: true,
      minimumInputLength: 3,
      initSelection: function(element, callback) {
        var value = element.val();
        if (value !== "") {
          var values = value.split("=");
          callback({ id: values[0], text: values[1] });
        }
      },
      ajax: {
        url: "/contacts",
        dataType: "jsonp",
        quietMillis: 100,
        data: function(term, page) {
          return { text: term, per_page: 10, page: page };
        },
        results: function(data, page) {
          var more = (page * 10) < data.total;
          return { results: JSON.parse(data.contacts), more: more };
        }
      }
    });
  }

  $(document).ready(function() {
    bindSelect2Contacts();
  });
});

