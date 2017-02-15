CanvasRails::Application.routes.draw do
  post "courses/:course_id/modules/spark-enablement" => "spark_plugin#enable_spark", as: "spark_enablement"
  get "courses/:course_id/modules/enable-spark-button" => "spark_plugin#render_enable_spark_button", as: "enable_spark_button"
  post "courses/:course_id/modules/:module_id/import-whiteboard" => "spark_plugin#import_whiteboard", as: "import_whiteboard"
end
