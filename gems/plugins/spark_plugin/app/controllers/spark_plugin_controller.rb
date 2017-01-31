require 'byebug'
class SparkPluginController < ApplicationController
  before_action
  def enable_spark
    puts 'Hit enable spark route'
    speedway_response = CanvasHttp.post("#{ENV["MICHELANGELO_URL"]}/flint")
    html_to_send = "#{speedway_response.code} "
    html_to_send << "Course ID: #{params[:id]}"

    render html: html_to_send.html_safe
  end

end
