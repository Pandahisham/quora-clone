class QuestionsController < ApplicationController
  def index
    @user = current_user
    @topics = Topic.all
    if params.include?(:topic_id)
      @topic = Topic.find(params[:topic_id])
      @questions = @topic.questions
    elsif params.include?(:user_id)
      @params_user = User.find(params[:user_id])
      @questions = @params_user.questions
    else
      @questions = Question.all
    end

    respond_to do |format|
      format.html { render :index }
      format.json { render :json => @questions }
    end
  end

  def create
    @question = current_user.questions.build(params[:question])
    @question.save!
    respond_to do |format|
      format.json { render :json => @question }
    end
  end

  def show
    @user = current_user
    @question = Question.find(params[:id])
    @topics = @question.topics
    @answers = @question.answers.sort_by {|answer| answer.votes}.reverse
  end

  def update
    @question = Question.find(params[:id])
    new_topic_ids = params[:question]
    @question.topic_ids = @question.topic_ids.concat(new_topic_ids)
    @question.save!
    respond_to do |format|
      format.json { render :json => @question }
    end
  end

  def feed
    questions = current_user.questions
    current_user.topical_questions.each do |question|
      questions += [question] unless questions.include?(question)
    end
    current_user.followed_questions.each do |question|
      questions += [question] unless questions.include?(question)
    end
    @questions = questions.sort_by { |question| question.latest_update_time }
    @questions.reverse!
    respond_to do |format|
      format.json { render :json => @questions.to_json(:include => :comments) }
    end
  end

  def popular
    questions = Question.all :include => [:answers, :comments]
    @sorted = questions.sort_by { |q| q.answers.size + q.comments.size }.reverse
    respond_to do |format|
      format.json { render :json => @sorted.to_json(:include => [:comments, :answers])}
    end
  end


end
