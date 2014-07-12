( function() {
  'use strict';

  var S4   = function() { return (((1+Math.random())*0x10000)|0).toString(16).substring(1); };
  var uuid = function() { return (S4()+S4()+"-"+S4()+"-"+S4()+"-"+S4()+"-"+S4()+S4()+S4()); };

  chrome.storage.sync.get("uuid", function(r) {
    var updateLocal = function(uuid) { chrome.storage.local.set({"uuid": uuid}); }
    if (!r.uuid) {
      var id = uuid();
      chrome.storage.sync.set({"uuid": id}, function() { updateLocal(id); });
    } else { updateLocal(r.uuid); }
  });

  chrome.app.runtime.onLaunched.addListener(function() {
    chrome.app.window.create('window.html', {
      bounds: { width: 800, height: 600 },
      frame: "none"
    });
  });

})();
