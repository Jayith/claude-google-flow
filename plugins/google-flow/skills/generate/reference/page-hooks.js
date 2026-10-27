// Run via javascript_tool once per page load, before uploading files.
//
// Uploads: Flow creates a detached <input type=file> and calls .click() on it, which would open
// a native file picker Claude can't drive. This keeps the input, attaches it to the DOM with a
// findable label ("claude upload target"), and skips the picker so file_upload can set the file.
//
// It also hides the File System Access pickers. Flow currently captures showSaveFilePicker at
// page load, so this alone doesn't stop the "flow.google.com wants to save" dialog — the
// browser-side "File editing: block" setting in the README does. Kept in case Flow starts
// checking for the API lazily.
if (!window.__flowHooks) {
  const orig = HTMLInputElement.prototype.click;
  HTMLInputElement.prototype.click = function () {
    if (this.type === 'file') {
      document.querySelectorAll('[data-claude-upload]').forEach(el => el !== this && el.removeAttribute('aria-label'));
      this.setAttribute('data-claude-upload', '1');
      this.setAttribute('aria-label', 'claude upload target');
      if (!this.isConnected) { this.style.display = 'none'; document.body.appendChild(this); }
      return;
    }
    return orig.call(this);
  };
  for (const api of ['showSaveFilePicker', 'showOpenFilePicker', 'showDirectoryPicker']) {
    try { delete window[api]; } catch {}
  }
  window.__flowHooks = true;
}
'hooks installed'
