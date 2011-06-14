require 'decent_exposure/railtie'

module DecentExposure
  def inherited(klass)
    closured_exposure = default_exposure
    klass.class_eval do
      default_exposure(&closured_exposure)
    end
    super
  end

  attr_accessor :_default_exposure

  def default_exposure(&block)
    self._default_exposure = block if block_given?
    _default_exposure
  end

  def generated_exposed_methods
    @generated_exposed_methods ||= Module.new.tap { |m| include(m) }
  end

  def expose(name, &block)
    closured_exposure = default_exposure
    generated_exposed_methods.module_eval do
      define_method name do
        @_resources       ||= {}
        return @_resources[name] if @_resources.key?(name) # instead of ||= . @_resources[name] can contain nil or false and not be evaluated many times.
        @_resources[name] = if block_given?
          instance_eval(&block)
        else
          instance_exec(name, &closured_exposure)
        end
      end
    end
    helper_method name if respond_to?(:helper_method)
    hide_action name if respond_to?(:hide_action)
  end
end
