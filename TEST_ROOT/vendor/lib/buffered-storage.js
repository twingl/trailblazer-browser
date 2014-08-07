( function() {
  'use strict';

  window.BufferedStorage = window.BufferedStorage || {};

  /**
   * BufferedStorage [Singleton]
   *
   * This is a buffered storage adapter for interfacing with
   * chrome.storage.local storage API. The reason this is required is that when
   * many write operations are executed in quick succession,
   * chrome.storage.local fails silently resulting in write failures that the
   * programmer does not know about.
   *
   * NOTES
   *
   * The API for this adapter is slightly different to that of chrome.storage.*
   * Instead of dealing with whole objects ( {key: value} ) as the parameter of
   * read/write operations, this library breaks this out into separate
   * parameters ( key, value ).
   *
   * read(key, function(r) { log(r)} ) #=> { key: value } - chrome.storage
   * vs.
   * read(key, function(r) { log(r)} ) #=> value          - this library
   *
   * If `key` is an array, the behaviour will fall back to similar to chrome -
   * returning an object containing the responses. If any of these keys are not
   * in the cache, these misses will be accumulated and delegated back to
   * chrome.storage and merged into the response object.
   *
   * This implements a very very very simple caching strategy to address read
   * consistency. If something exists in the buffer, it'll get returned. This
   * is only for internal consistency, so if you have multiple contexts that
   * are writing to storage, they can possibly get out of sync. That was
   * already a possibility, but the probability has just increased a little
   * because of the buffer delay.
   *
   * Implements the singleton pattern, c.f.
   * http://stackoverflow.com/questions/1635800/javascript-best-singleton-pattern
   */

  BufferedStorage = function() {
    if (BufferedStorage.prototype._singletonInstance) {
      return BufferedStorage.prototype._singletonInstance;
    }
    BufferedStorage.prototype._singletonInstance = this;

    this._writeBuffer = {};
    this._flushTimeout;
    this._pendingCallbacks = [];

    this.afterWrite = function(cb) {
      if (Object.keys(BufferedStorage.prototype._singletonInstance._writeBuffer) > 0) {
        this._pendingCallbacks.push(cb);
      } else {
        cb();
      }
    };

    /**
     * Flush the buffer to chrome.storage.local
     * If data exists in the write buffer after the write is completed, it will
     * schedule another flush.
     */
    this._flush = function() {
      var buf           = this._writeBuffer;
      this._writeBuffer = {};
      chrome.storage.local.set(buf, function() {
        if (Object.keys(BufferedStorage.prototype._singletonInstance._writeBuffer) > 0) {
          BufferedStorage.prototype._singletonInstance._scheduleFlush();
        } else {
          _.map(BufferedStorage.prototype._singletonInstance._pendingCallbacks, function(cb) { cb(); });
        }
      });
      this._flushTimeout = undefined;
    };

    /**
     * Schedule a flush of the buffer into chrome.storage.local
     * Creates a timeout which calls _flush() if one is not already scheduled
     */
    this._scheduleFlush = function() {
      if (!this._flushTimeout) {
        this._flushTimeout = setTimeout(function() {
          BufferedStorage.prototype._singletonInstance._flush();
        }, 20);
      }
    };

    /**
     * Buffer a key:value pair for writing to chrome.storage.local
     */
    this.write = function(key, value, cb) {
      this._writeBuffer[key] = value;
      this._scheduleFlush();
      if (cb) cb(value);
    };

    /**
     * Read a value from the write buffer if it exists, otherwise delegate to
     * chrome.storage.local
     * Checks `key` - if it is an array, it hits the cache with each of the
     * keys and any misses are accumulated, delegated to chrome.storage and
     * merged into the result.
     */
    this.read = function(key, cb) {
      if (typeof key === "object" && key.length !== undefined) {
        // We have an array of keys to retrieve. First check the cache.
        var res    = {};
        var misses = [];
        for (var i = 0; i < key.length; i+=1) {
          if (this._writeBuffer[key[i]]) {
            res[key[i]] = this._writeBuffer[key[i]];
          } else { misses.push(key[i]); }
        }
        if (misses.length > 0) {
          chrome.storage.local.get(misses, function(r) {
            var k = Object.keys(r);
            for (var i = 0; i < k.length; i += 1) res[k[i]] = r[k[i]];
            cb(res);
          });
        } else { cb(res); }
      } else {
        if (this._writeBuffer[key]) {
          cb(this._writeBuffer[key]);
        } else {
          chrome.storage.local.get(key, function(r) {
            cb(r[key]);
          });
        }
      }
    };

    /**
     * Remove a value from the store.
     * If something exists in the buffer, remove it.
     */
    this.remove = function(key, cb) {
      delete this._writeBuffer[key];
      chrome.storage.local.remove(key, cb);
    };
  };

})();
