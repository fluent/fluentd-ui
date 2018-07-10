require "fluent/test/log"
require "serverengine"

module DummyLogger
  class << self
    def logger
      dl_opts = {log_level: ServerEngine::DaemonLogger::INFO}
      logdev = Fluent::Test::DummyLogDevice.new
      logger = ServerEngine::DaemonLogger.new(logdev, dl_opts)
      Fluent::Log.new(logger)
    end
  end
end
