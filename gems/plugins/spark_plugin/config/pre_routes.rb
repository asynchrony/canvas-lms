CanvasRails::Application.routes.draw do
  post "courses/:course_id/enable-spark" => "spark_plugin#enable_spark", as: "enable_spark"
  post "courses/:course_id/modules/:module_id/import-whiteboard" => "spark_plugin#import_whiteboard", as: "import_whiteboard"
end
