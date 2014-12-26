module EasyAppHelper

  ManagedLogger = EasyAppHelper::Logger::Initializer.build_logger

  def logger
    EasyAppHelper::ManagedLogger
  end

end
