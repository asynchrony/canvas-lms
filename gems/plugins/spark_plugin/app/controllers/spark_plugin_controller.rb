require 'jwt'

class SparkPluginController < ApplicationController

  def enable_spark
    post_to_spark_service("enable-spark", enable_spark_params);
  end

  def import_whiteboard
    post_to_spark_service("whiteboard-snapshot", import_whiteboard_params);
  end

  def disable_spark
    delete_from_spark_service("enable-spark", disable_spark_params);
  end

  def render_enable_spark_button
    @course_id = course_id
    @course_code = Course.find(@course_id).course_code

    http = Net::HTTP.new(spark_service_url.host, spark_service_url.port)
    http.use_ssl = true if Rails.env.production?

    response = JSON.parse(http.get(
    "#{spark_service_url.path}enable-spark/#{@course_id}",
    'Authorization' => 'Bearer ' + jwt,
    'Content-type' => 'application/json',
    'Accept' => 'text/json, application/json').body)

    @can_enable = false
    @can_enable = !response["enabled"] unless response["enabled"].nil?

    respond_to do |format|
      format.js
    end
  end

  def delete_from_spark_service(endpoint, params)
    http = Net::HTTP.new(spark_service_url.host, spark_service_url.port)
    http.use_ssl = true if Rails.env.production?

    response = http.delete(
      "#{spark_service_url.path}#{endpoint}/#{params[:courseId]}",
      'Authorization' => 'Bearer ' + jwt,
      'Content-type' => 'application/json',
      'Accept' => 'text/json, application/json')

    handle_response(response)
  end

  def post_to_spark_service(endpoint, body)
    http = Net::HTTP.new(spark_service_url.host, spark_service_url.port)
    http.use_ssl = true if Rails.env.production?
    response = http.post(
      "#{spark_service_url.path}#{endpoint}",
      JSON.dump(body),
      'Authorization' => 'Bearer ' + jwt,
      'Content-type' => 'application/json',
      'Accept' => 'text/json, application/json')

    handle_response(response)
  end

  def handle_response(response)
    status_code = response.code.to_i

    respond_to do |format|
      format.html do
        if status_code >= 200 && status_code < 300
          redirect_to :back, notice: "Success"
        else
          flash[:error] = "Failed (error code #{status_code})"
          redirect_to :back
        end
      end
      format.json { render json: { status: status_code } }
    end
  end

  def jwt
    expiry = Time.zone.now + 5.minutes.to_i
    body = {
      sub: user_email,
      iss: ENV['SPARK_JWT_ISS'],
      jti: SecureRandom.uuid
    }
    Canvas::Security.create_jwt(body, expiry, ENV['SPARK_JWT_SECRET'])
  end

  def enable_spark_params
    { courseId: course_id, courseCode: course_code }
  end

  def disable_spark_params
    { courseId: course_id }
  end

  def import_whiteboard_params
    { courseId: course_id, moduleId: module_id, indent: indent }
  end

  def course_code
    permitted_params[:course_code]
  end

  def user_email
    @current_user.email
  end

  def course_id
    params[:course_id]
  end

  def module_id
    params[:module_id]
  end

  def indent
    params[:indent]
  end

  def spark_service_url
    URI.parse("#{ENV['SPARK_SERVICE_URL']}/canvas/")
  end

  def permitted_params
    strong_params.require(:course).permit(:course_code)
  end

end
