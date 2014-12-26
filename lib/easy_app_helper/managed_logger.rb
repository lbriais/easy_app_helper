module EasyAppHelper

  Logger = EasyAppHelper::Logging::Initializer.build_logger

  def logger
    EasyAppHelper::Logger
  end

end
