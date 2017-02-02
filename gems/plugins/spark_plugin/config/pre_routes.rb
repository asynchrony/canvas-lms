CanvasRails::Application.routes.draw do
  post "courses/:id/enable-spark" => "spark_plugin#enable_spark", as: "enable_spark"
end
