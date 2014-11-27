function bindTinymce() {
  tinyMCE.init({
    language: "fr_FR",
    selector: "textarea.tinymce",
    toolbar: ["undo redo | styleselect | bold italic | bullist numlist outdent indent | link | table | fullscreen"],
    plugins: "fullscreen,image,link,table,code",
    relative_urls: false
  });
}

$(function() {
  $.ajaxPrefilter(function(options, originalOptions, xhr) {
    if (!options.crossDomain) {
      var token = jQuery("meta[name='csrf-token']").attr("content");
      xhr.setRequestHeader('X-CSRF-Token', token);
    }
  });

  function bindCalendars() {
    $('input.with-calendar').datepicker($.datepicker.regional["fr"]);
  }

  function bindCustomLightboxes() {
    $.extend(true, $.magnificPopup.defaults, {
      tClose: 'Fermer (Esc)', // Alt text on close button
      tLoading: 'Chargement…', // Text that is displayed during loading. Can contain %curr% and %total% keys
      gallery: {
        tPrev: 'Photo précédente (Flèche gauche)', // Alt text on left arrow
        tNext: 'Photo suivante (Flèche droite)', // Alt text on right arrow
        tCounter: '%curr% sur %total%' // Markup for "1 of 7" counter
      },
      image: {
        tError: '<a href="%url%">La photo</a> ne peut pas être chargée.' // Error message when image could not be loaded
      },
      ajax: {
        tError: '<a href="%url%">Le contenu</a> ne peut pas être chargé.' // Error message when ajax request failed
      }
    });
    $('.parent-lightbox').magnificPopup({
      delegate: 'a.custom-lightbox',
      gallery: {
        enabled: true
      },
      type: 'image'
    });
  }

  function bindDeleters() {
    $('#main').on('click', function(e) {
      var target = $(e.target);
      var deleter = target.closest('.js-deleter');
      if (!deleter.length) {
        return;
      }
      e.preventDefault();
      e.stopPropagation();
      if (confirm(deleter.attr('title'))) {
        $.ajax({
          type: 'POST',
          data: { _method: 'delete' },
          url: deleter.attr('href'),
          error: function() {
            $.notify('L’élément n’a pas pu être supprimé', 'error');
          },
          success: function() {
            $.notify('L’élément a été supprimé', 'success');
            $.ajax({
              url: window.location,
              type: 'GET',
              cache: false,
              success: function(data) {
                $('#main').html(data);
              }
            });
          }
        });
      }
    });
  }

  function bindExternalLinks() {
    $('a[rel*="external"]').attr('target', '_blank');
  }

  function bindPopovers() {
    $('.link-popover').popover({
      placement: 'right',
      trigger: 'hover',
      html: true
    });
  }

  $(document).ready(function() {
    bindCalendars();
    bindCustomLightboxes();
    bindDeleters();
    bindExternalLinks();
    bindPopovers();
    bindTinymce();
    $('table.clickable tr').click(function() {
      window.location.href = $(this).attr('data-target');
    });
    $('*[data-show]').click(function() {
      $('#' + $(this).attr('data-show')).show().find('*[data-focus]').focus();
    });
    $('*[data-toggle]').click(function() {
      var elt = $('#' + $(this).attr('data-toggle'));
      if (elt.toggle().is(':visible'))
        elt.find('*[data-focus]').focus();
    });
  });
});

