class ServiceInterface
  attr_reader :result, :errors

  def initialize(*args, **kwargs, &block)
    @args = args
    @kwargs = kwargs
    @block = block
    @result = nil
  end

  def self.call(*args, **kwargs, &block)
    new(*args, **kwargs, &block).call
  end

  def call
    @errors = []
    run
    self
  end

  private

  attr_reader :args, :kwargs, :block
  attr_writer :result, :errors

  def run
    raise NotImplementedError, "Subclasses must implement the run method"
  end
end
