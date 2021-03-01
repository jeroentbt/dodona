class FeedbacksController < ApplicationController
  include SeriesHelper

  before_action :set_feedback, only: %i[show edit update]

  has_scope :by_filter, as: 'filter' do |_controller, scope, value|
    scope.by_filter(value, skip_user: true, skip_exercise: true)
  end

  has_scope :by_status, as: 'status'

  def show
    @crumbs = [
      [@feedback.evaluation.series.course.name, course_url(@feedback.evaluation.series.course)],
      [@feedback.evaluation.series.name, breadcrumb_series_path(@feedback.evaluation.series, current_user)],
      [I18n.t('evaluations.show.evaluation'), evaluation_path(@feedback.evaluation)],
      [I18n.t('feedbacks.show.feedback'), '#']
    ]
    @title = I18n.t('feedbacks.show.feedback')

    @score_map = @feedback.scores.index_by(&:score_item_id)
    # If we refresh all scores because of a conflict, we want to make
    # sure the user is aware the update was not successful. By setting
    # the score_item ID in the `warning` param, it will be rendered with
    # the bootstrap warning classes.
    @warning = params[:warning]
  end

  def edit
    @submissions = apply_scopes(Submission)
                   .in_series(@feedback.evaluation.series)
                   .where(user: @feedback.user, exercise: @feedback.exercise)
                   .paginate(page: parse_pagination_param(params[:page]))
    @crumbs = [
      [@feedback.evaluation.series.course.name, course_url(@feedback.evaluation.series.course)],
      [@feedback.evaluation.series.name, breadcrumb_series_path(@feedback.evaluation.series, current_user)],
      [I18n.t('evaluations.show.evaluation'), evaluation_path(@feedback.evaluation)],
      [I18n.t('feedbacks.edit.short_title'), '#']
    ]
    @title = I18n.t('feedbacks.edit.short_title')
  end

  def update
    attrs = permitted_attributes(@feedback)
    attrs['scores_attributes'].each { |s| s['last_updated_by_id'] = current_user.id } if attrs['scores_attributes'].present?

    @feedback.update(attrs)
    # We might have updated scores, so recalculate the map.
    @score_map = @feedback.scores.index_by(&:score_item_id)

    respond_to do |format|
      format.html { redirect_to evaluation_feedback_path(@feedback.evaluation, @feedback) }
      format.json { render :show, status: :ok, location: @feedback }
      format.js { render :show }
    end
  end

  private

  def set_feedback
    @feedback = Feedback.find(params[:id])
    authorize @feedback
    @score_map = @feedback.scores.index_by(&:score_item_id)
  end
end
