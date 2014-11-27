$(function() {
  function bindProductSteps() {
    var wrapper = $('#product-steps-wrapper');
    if (!wrapper.length) { return; }
    var ref = wrapper.children().last();
    if (!ref.length) { return; }
    var index = parseInt(ref.data('index'));
    var ref_html = '<div class="product-item-wrapper product-step-wrapper" data-index="__ID__">' + ref.html().replace(new RegExp("\\["+index+"\\]", 'g'), '[__ID__]').replace(new RegExp('_'+index+'_', 'g'), '___ID___') + '</div>';
    ref.remove();
    $('#product-steps-add').click(function(e) {
      e.preventDefault();
      var my_html = ref_html.replace(/__ID__/g, ++index);
      wrapper.append(my_html);
      $("#product-steps-wrapper .product-item-content").last().find("input[type='text']").first().focus();
    });
    wrapper.click(function(e) {
      var element = $(e.target).closest('a');
      if (!element.hasClass('deleter')) { return; }
      e.preventDefault();
      if (!confirm('Supprimer vraiment ?')) { return; }
      var ref = element.closest('.product-item-wrapper');
      ref.find('input.destroy').val('1');
      ref.find('.product-item-content').remove();
      ref.hide();
    });
  }

  function bindProductOptions() {
    var wrapper = $('#product-options-wrapper');
    if (!wrapper.length) { return; }
    var ref = wrapper.children().last();
    if (!ref.length) { return; }
    var index = parseInt(ref.data('index'));
    var ref_html = '<div class="product-item-wrapper product-option-wrapper" data-index="__ID__">' + ref.html().replace(new RegExp("\\["+index+"\\]", 'g'), '[__ID__]').replace(new RegExp('_'+index+'_', 'g'), '___ID___') + '</div>';
    ref.remove();
    $('#product-options-add').click(function(e) {
      e.preventDefault();
      var my_html = ref_html.replace(/__ID__/g, ++index);
      wrapper.append(my_html);
      bindTinymce();
      $("#product-options-wrapper .product-item-content").last().find("input[type='text']").first().focus();
    });
    wrapper.click(function(e) {
      var element = $(e.target).closest('a');
      if (!element.hasClass('deleter')) { return; }
      e.preventDefault();
      if (!confirm('Supprimer vraiment ?')) { return; }
      var ref = element.closest('.product-item-wrapper');
      ref.find('input.destroy').val('1');
      ref.find('.product-item-content').remove();
      ref.hide();
    });
  }

  $(document).ready(function() {
    bindProductSteps();
    bindProductOptions();
  });
});

