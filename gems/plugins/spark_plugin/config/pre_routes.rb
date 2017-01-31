CanvasRails::Application.routes.draw do
  post "courses/:id/enable-spark", controller: "spark_plugin", to: :enable_spark
end
