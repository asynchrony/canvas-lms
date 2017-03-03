require 'jwt'

class SparkPluginController < ApplicationController

  def enable_spark
    response = SparkService.create_spark(course_id, enable_spark_params, user_email)
    handle_response(response)
  end

  def enable_spark_for_module
    response = SparkService.create_spark_for_module(course_id, module_id, enable_spark_for_module_params, user_email)
    handle_response(response)
  end

  def import_whiteboard
    response = SparkService.create_whiteboard_link(course_id, module_id, import_whiteboard_params, user_email)
    handle_response(response)
  end

  def disable_spark
    response = SparkService.delete_spark(course_id, user_email)
    handle_response(response)
  end

  def render_enable_spark_button
    @course_id = course_id
    @course_code = Course.find(@course_id).course_code

    response = JSON.parse(SparkService.get_spark(@course_id, user_email).body)

    @can_enable = false
    @can_enable = !response["enabled"] unless response["enabled"].nil?

    respond_to do |format|
      format.js
    end
  end

  def render_whiteboard_snapshots
    @module_id = module_id
    @course_id = course_id

    response = SparkService.get_whiteboards(@course_id, @module_id, user_email)
    status_code = response.code.to_i

    respond_to do |format|
      if status_code >= 200 && status_code < 300
        @whiteboards = JSON.parse(response.body)
        format.js
      else
        format.json { render json: response.body, status: status_code }
      end
    end
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

  def enable_spark_params
    { courseCode: course_code }
  end

  def enable_spark_for_module_params
    { moduleName: module_name }
  end

  def import_whiteboard_params
    { indent: indent, selectedSnapshot: selected_snapshot }
  end

  def course_code
    permitted_params[:course_code]
  end

  def module_name
    params[:module_name]
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

  def selected_snapshot
    params[:selected_snapshot]
  end

  def indent
    params[:indent]
  end

  def permitted_params
    strong_params.require(:course).permit(:course_code)
  end

end
