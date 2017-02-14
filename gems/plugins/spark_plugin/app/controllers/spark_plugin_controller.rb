require 'jwt'

class SparkPluginController < ApplicationController

  def enable_spark
    post_to_spark_service("enable-spark", enable_spark_params);
  end

  def import_whiteboard
    post_to_spark_service("whiteboard-snapshot", import_whiteboard_params);
  end

  def post_to_spark_service(endpoint, body)
    http = Net::HTTP.new(spark_service_url.host, spark_service_url.port)
    http.use_ssl = true
    response = http.post(
      "#{spark_service_url.path}#{endpoint}",
      JSON.dump(body),
      'Authorization' => 'Bearer ' + jwt,
      'Content-type' => 'application/json',
      'Accept' => 'text/json, application/json')

    respond_to do |format|
      format.html { redirect_to :back, notice: response_message(response.code)}
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
    { courseId: course_id, courseCode: course_code, email: user_email }
  end

  def import_whiteboard_params
    { courseId: course_id, moduleId: module_id }
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

  def response_message(code)
    status_code = code.to_i
    return "Processing request. Please refresh momentarily" if status_code == 202
    return "Success" if (status_code >= 200 && status_code < 300)
    "Failed (error code #{status_code})"
  end

  def spark_service_url
    URI.parse("#{ENV['SPARK_SERVICE_URL']}/canvas/")
  end

  def permitted_params
    strong_params.require(:course).permit(:course_code)
  end

end
