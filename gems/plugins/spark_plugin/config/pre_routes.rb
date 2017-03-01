CanvasRails::Application.routes.draw do
  post "courses/:course_id/modules/spark-enablement" => "spark_plugin#enable_spark", as: "spark_enablement"
  post "courses/:course_id/modules/spark-disablement" => "spark_plugin#disable_spark", as: "spark_disablement"
  get "courses/:course_id/modules/enable-spark-button" => "spark_plugin#render_enable_spark_button", as: "enable_spark_button"
  post "courses/:course_id/modules/:module_id/import-whiteboard" => "spark_plugin#import_whiteboard", as: "import_whiteboard"
  post "courses/:course_id/modules/:module_id/spark-enablement" => "spark_plugin#enable_spark_for_module", as: "spark_enablement_for_module"
end
