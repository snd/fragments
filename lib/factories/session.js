// Generated by CoffeeScript 1.10.0
module.exports.fragments_RedisSessionStore = function(fragments_expressSession, fragments_connectRedis) {
  return fragments_connectRedis(fragments_expressSession);
};

module.exports.fragments_redisSessionStore = function(fragments_RedisSessionStore, fragments_redisClient) {
  return new fragments_RedisSessionStore({
    client: fragments_redisClient
  });
};

module.exports.fragments_sessionCookieName = function() {
  return 'session-id';
};

module.exports.fragments_sessionMiddleware = function(fragments_expressSession, fragments_config_sessionSecret, fragments_sessionCookieName, fragments_redisSessionStore, fragments_uuid) {
  return fragments_expressSession({
    secret: fragments_config_sessionSecret,
    store: fragments_redisSessionStore,
    genid: function() {
      return fragments_uuid.v4();
    },
    saveUninitialized: true,
    resave: false,
    name: fragments_sessionCookieName,
    cookie: {
      httpOnly: true
    }
  });
};

module.exports.fragments_session = function(fragments_sessionMiddleware, fragments_req, fragments_res, fragments_Promise) {
  if (fragments_req.session != null) {
    return fragments_req.session;
  }
  return new fragments_Promise(function(resolve, reject) {
    return fragments_sessionMiddleware(fragments_req, fragments_res, function(err) {
      if (err != null) {
        return reject(err);
      }
      return resolve(fragments_req.session);
    });
  });
};

module.exports.fragments_sessionID = function(fragments_req, fragments_session) {
  return fragments_req.sessionID;
};
