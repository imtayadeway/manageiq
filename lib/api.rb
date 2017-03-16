module Api
  ApiError = Class.new(StandardError)
  AuthenticationError = Class.new(ApiError)
  ForbiddenError = Class.new(ApiError)
  BadRequestError = Class.new(ApiError)
  NotFoundError = Class.new(ApiError)
  UnsupportedMediaTypeError = Class.new(ApiError)
  ERROR_MAPPING = {
    StandardError                  => :internal_server_error,
    NoMethodError                  => :internal_server_error,
    ActiveRecord::RecordNotFound   => :not_found,
    ActiveRecord::StatementInvalid => :bad_request,
    JSON::ParserError              => :bad_request,
    MultiJson::LoadError           => :bad_request,
    MiqException::MiqEVMLoginError => :unauthorized,
    AuthenticationError            => :unauthorized,
    ForbiddenError                 => :forbidden,
    BadRequestError                => :bad_request,
    NotFoundError                  => :not_found,
    UnsupportedMediaTypeError      => :unsupported_media_type
  }.freeze
end
