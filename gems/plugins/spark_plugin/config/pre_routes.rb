CanvasRails::Application.routes.draw do
  post "courses/:id/modules/spark-enablement" => "spark_plugin#enable_spark", as: "spark_enablement"
  get "courses/:id/modules/enable-spark-button" => "spark_plugin#render_enable_spark_button", as: "enable_spark_button"
end
