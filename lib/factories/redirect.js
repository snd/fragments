// Generated by CoffeeScript 1.10.0
module.exports.fragments_redirect = function(fragments_setHeaderLocation, fragments_endMovedTemporarily) {
  return function(location) {
    fragments_setHeaderLocation(location);
    return fragments_endMovedTemporarily();
  };
};

module.exports.fragments_redirectToReferer = function(fragments_redirect, fragments_headerReferer, fragments_url) {
  return function() {
    return fragments_redirect(fragments_headerReferer || fragments_url);
  };
};
