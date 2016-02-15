module ResquePostgresDisconnect
  def after_perform_pg_fix(*)
    disconnect unless Resque.inline? || Rails.env.test?
  end

  def on_failure_pg_fix(*)
    disconnect unless Resque.inline? || Rails.env.test?
  end

  private

  def disconnect
    # Load all the models
    Rails.application.eager_load!
    models = ActiveRecord::Base.descendants

    # Disconnect any if connected
    models.each { |model| model.connection.disconnect! if model.connection.active? }
  end
end
