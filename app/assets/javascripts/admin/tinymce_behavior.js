window.upgradeTinyMCE = function(editor) {
  // 1. Hook focus/blur on editors to propagate these events to their "render container"
  // so popovers can work on MCE's…
  tinymce.Editor.prototype.getRenderArea = function() {
    return $(this.getContainer()).find('table').first();
  };
/* TODO: JS errors :(
  editor.onInit.add(function(ed) {
    tinymce.dom.Event.add(ed.getWin(), 'focus', function() {
      return ed.getRenderArea().trigger('focus');
    });
    return tinymce.dom.Event.add(ed.getWin(), 'blur', function() {
      return ed.getRenderArea().trigger('blur');
    });
  });
*/
  // 2. Sync underlying textarea's whenever the content is detected as changed.
/*
  return editor.onChange.add(function(editor, description) {
    if (editor.isDirty()) {
      return $(editor.getElement()).val(description.content);
    }
  });
*/
};

