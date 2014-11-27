function bindUploadForm() {
  var form = $('#js-form-upload');
  var files = $('#js-files');
  var progressBar = $('#js-progress-bar');
  var uploadButton = $('#js-upload-button');
  var submitButton = $('#js-submit-button').prop('disabled', true);
  var cancelButton = $('<button/>').addClass('btn btn-xs btn-danger cancel-button').text('Supprimer');

  form.fileupload({
    url: form.attr('action'),
    type: 'POST',
    dataType: 'xml',
    autoUpload: false,
    forceIframeTransport: pushUpRailsS3Enabled && pushUpRailsJSS3IframeEnabled, // Required for Amazon S3 (otherwise you will get 405 Method Not Allowed)
    acceptFileTypes: /(\.|\/)(gif|jpe?g|png)$/i,
    maxFileSize: 5000000, // 5 MB
    maxNumberOfFiles: 1
    // Enable image resizing, except for Android and Opera,
    // which actually support image resizing, but fail to
    // send Blob objects via XHR requests:
    //disableImageResize: /Android(?!.*Chrome)|Opera/.test(window.navigator.userAgent),
    //previewMaxWidth: 100,
    //previewMaxHeight: 100,
    //previewCrop: true
  }).on('fileuploadadd', function(e, data) {
    //console.log('fileuploadadd');
    $.each(data.files, function(index, file) {
      if (data.files.length >= 1) { // maxNumberOfFiles
        uploadButton.hide();
      }
      var node = $('<div class="file"/>');
      node.append($('<p class="file-filename">' + file.name + '</p>'));
      node.append(cancelButton.clone(true).data(data));
      node.append($('<p class="file-spinner">génération des vignettes…</p>').hide());
      files.show();
      submitButton.prop('disabled', false);
      node.appendTo(files.find('.files'));
      node.find('.cancel-button').click(function() {
        uploadButton.show();
        data.files.splice(index, 1);
        node.remove();
        if (data.files.length <= 0) {
          files.hide();
          submitButton.prop('disabled', true);
        }
        if (data.files.length < 1) { // maxNumberOfFiles
          uploadButton.find('.fileinput-button').removeClass('disabled');
          uploadButton.find('input').removeAttr('disabled');
        }
      });
    });
    if (pushUpRailsS3Enabled && pushUpRailsJSUploadEnabled) {
      form.submit(function() {
        files.find('.cancel-button').hide();
        progressBar.show();
        var disabledFields = uploadButton.find('[disabled]');
        disabledFields.prop('disabled', false);
        var enabledFields = form.find('.js-inline-value');
        enabledFields.prop('disabled', true);
        data.formData = form.serializeArray();
        uploadButton.prop('disabled', true);
        submitButton.prop('disabled', true);
        data.submit();
        disabledFields.prop('disabled', true);
        enabledFields.prop('disabled', false);
        return false;
      });
    } else {
      alert('#TODO');
      /*
      form.submit(function() {
        files.find('.cancel-button').hide();
        progressBar.show();
        var disabledFields = uploadButton.find('[disabled]');
        disabledFields.prop('disabled', false);

        form.find('select').prop('disabled', true);
        form.find('input').prop('disabled', true);
        // Whitelist
        form.find('[name="utf8"]').prop('disabled', false);
        $('#js-s3-fields').find('[disabled]').prop('disabled', false);
        $('#js-upload-button').find('[disabled]').prop('disabled', false);
        //form.find('.js-inline-value').prop('disabled', true);
        data.formData = form.serializeArray();
        form.submit();
        form.find('select').prop('disabled', false);
        form.find('input').prop('disabled', false);
        return false;
      });
      */
    }
  //}).on('fileuploadsubmit', function(e, data) {
    //console.log('fileuploadsubmit');
  }).on('fileuploadprocessalways', function (e, data) {
    //console.log('fileuploadprocessalways');
  /*
    var index = data.index,
      file = data.files[index],
      node = $(data.context.children()[index]);
    if (file.preview) {
      console.log('preview');
      node
        .prepend('<br>')
        .prepend(file.preview);
    }
    if (file.error) {
      node
        .append('<br>')
        .append($('<span class="text-danger"/>').text(file.error));
    }
    if (index + 1 === data.files.length) {
      data.context.find('button')
        .text('Upload')
        .prop('disabled', !!data.files.error);
    }
  */
  }).on('fileuploadprogressall', function(e, data) {
    //console.log('fileuploadprogressall');
    var progress = parseInt(data.loaded / data.total * 100, 10);
    $('#js-progress-bar .progress-bar').css('width', progress + '%').text(progress + '%');
  }).on('fileuploaddone', function(e, data) {
    //console.log('fileuploaddone');
    progressBar.hide();
    files.find('.file-spinner').show();
    var key = $(data.result).find('Key').text();
    progressBar.hide();
    $.ajax({
      url: pushUpRailsCreateImageURL,
      type: 'POST',
      data: 'data=' + JSON.stringify({
        key: key,
        image: {
          kind: form.find('[name="image[kind]"]').val(),
          legend: form.find('[name="image[legend]"]').val()
        }
      }),
      success: function(data) {
        $.notify('L’image a été ajoutée', 'success');
        form.find('.file-spinner').text('mise à jour…');
        $.ajax({
          url: pushUpRailsReloadImageListURL,
          type: 'GET',
          cache: false,
          success: function(data) {
            $('#list').html(data);
          },
          error: function(data) {
            $.notify('La liste des images n’a pas pu être rechargée', 'error');
          },
          complete: function(data) {
            files.find('.files').html('');
            submitButton.prop('disabled', false);
          }
        });
      },
      error: function(data) {
        $.notify('L’image n’a pas pu être ajoutée (pensez à désactiver les bloqueurs de publicité)', 'error');
      },
      complete: function(data) {
        $.ajax({
          url: pushUpRailsReloadUploadFormURL,
          type: 'GET',
          cache: false,
          success: function(data) {
            $('#js-upload-form-wrapper').html(data);
            bindUploadForm();
          },
          error: function(data) {
            $.notify('Le formulaire n’a pas pu être rechargé (pensez à désactiver les bloqueurs de publicité)', 'error');
          }
        });
      }
    });
  }).on('fileuploadfail', function(e, data) {
    //console.log('fail');
    /*
    $.each(data.files, function(index, file) {
      var error = $('<span class="text-danger"/>').text('File upload failed.');
      $(files.children()[index])
        .append('<br>')
        .append(error);
    });
    */
  }); //.prop('disabled', !$.support.fileInput).parent().addClass($.support.fileInput ? undefined : 'disabled');
}

$(document).ready(function() {
  bindUploadForm();
});

