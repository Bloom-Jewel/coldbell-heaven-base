module ColdbellHeaven
  class ApplicationController < Object::ApplicationController
    helper Engine.helpers
    protect_from_forgery with: :exception
    
    before_action do
      helpers.class.instance_exec do
        include Engine.routes.url_helpers
      end
    end
    after_action do
      response.body.gsub!(/>\s+</,'><')
      response.body.gsub!(/>\s+(\S)/,'>\1')
      response.body.gsub!(/(\S)\s+</,'\1<')
    end
    
    private
    def _safe_error
      yield
    rescue => e
      render html: "<h1>%s</h1><h2>%s</h2><ul>%s</ul>".html_safe % [
        'Internal Server Error',
        [e.class,e.message].map(&:to_s).reject(&:empty?).join(':'),
        e.backtrace.map { |bt| "<li>#{bt}</li>".html_safe }.join('').html_safe
      ],status: 500
    end
  end
end
