var bindColorPicker, bindCropper, bindImageUpdater, bindKindSizeRefresh, computeInitialCrop, imageIsLoaded, img, updateCropField;

img = new Image();

imageIsLoaded = 'naturalWidth' in img ? function(img) {
  return img.naturalWidth !== 0;
} : 'complete' in img ? function(img) {
  return img.complete === true;
} : function(img) {
  return img.readyState === 'complete';
};

bindColorPicker = function() {
  var feedback, padder, picker;
  padder = $('#btn-pad');
  picker = $('#color-picker');
  feedback = picker.find('.color');
  return picker.colorpicker().on('changeColor', function(data) {
    var hex;
    hex = data.color.toHex();
    padder.val(hex);
    return feedback.css({
      background: hex
    });
  });
};

bindCropper = function() {
  var api, options;
  img = $('#prefull-image');
  if (!imageIsLoaded(img[0])) {
    return setTimeout(bindCropper, 100);
  }
  $('#loading-indicator').hide();
  options = {
    minSize: gMinDimensions,
    setSelect: computeInitialCrop(img),
    onSelect: updateCropField,
    bgColor: '#888888'
  };
  if (_.isNumber(gAspectRatio)) {
    options.aspectRatio = gAspectRatio;
  }
  api = null;
  img.Jcrop(options, function() {
    return api = this;
  });
  return $('#image-cropper-zone').on('dblclick', '.jcrop-tracker', function(e) {
    e.preventDefault();
    return api.setSelect(computeInitialCrop(img));
  });
};

bindKindSizeRefresh = function() {
  return $('#images select[name*=kind]').on('change', function() {
    return $('#min-fullSize').text(gFullSizes[$(this).val()]);
  });
};

bindImageUpdater = function() {
  var form, updater;
  updater = $('#image-updater');
  form = updater.find('form');
  updater.find('.yes').click(function() {
    form.submit();
    return updater.modal('hide');
  });
  updater.find('.no').click(function() {
    return updater.modal('hide');
  });
  return $('#images').on('click', '.edit', function(e) {
    var thumbnail;
    e.preventDefault();
    thumbnail = $(this).closest('.thumbnail');
    form.attr('action', form.attr('action').replace(/(?:\/\d+)?$/, "/" + (thumbnail.data('id'))));
    updater.find('img').attr('src', thumbnail.find('img').attr('src'));
    updater.find('select[name*="kind"]').val(thumbnail.data('kind'));
    updater.find('input[name*="zoomable"]').attr('checked', thumbnail.data('zoomable') === 'true');
    updater.find('input[name*="legend"]').val(thumbnail.data('legend'));
    return updater.modal('show');
  });
};

computeInitialCrop = function() {
  var h, nh, nw, w, _ref, _ref1;
  _ref = [img.width(), img.height()], w = _ref[0], h = _ref[1];
  if (!_.isNumber(gAspectRatio)) {
    return [0, 0, w, h];
  }
  _ref1 = w / gAspectRatio > h ? [Math.floor(h * gAspectRatio), h] : [w, Math.floor(w / gAspectRatio)], nw = _ref1[0], nh = _ref1[1];
  return [Math.floor((w - nw) / 2), Math.floor((h - nh) / 2), nw, nh];
};

updateCropField = function(coords) {
  return $('#cropping').val("" + coords.x + "," + coords.y + "," + coords.w + "," + coords.h);
};

$(function() {
  function bindImageDeleters() {
    $('#images').on('click', function(e) {
      var target = $(e.target);
      var deleter = $(target).closest('.js-image-deleter');
      var thumbnail = $(target).closest('.js-thumbnail');
      if (deleter.length) {
        e.preventDefault();
        e.stopPropagation();
        if (confirm('Supprimer cette image ?')) {
          $.ajax({
            url: deleter.attr('href'),
            type: 'DELETE'
          });
          thumbnail.remove();
        }
      }
    });
  }

  if ($('#images').length) {
    bindKindSizeRefresh();
    bindImageDeleters();
  }
  if ($('#prefull-image').length) {
    bindCropper();
    bindColorPicker();
  }
  if ($('#image-updater').length) {
    return bindImageUpdater();
  }
});

